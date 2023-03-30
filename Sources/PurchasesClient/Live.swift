import Adapty
import AnalyticsClient
import Combine
import ComposableArchitecture
import Foundation
import FoundationSupport
import LoggingSupport
import os.log
import StoreKit
import UIKit
import UserIdentifier

extension PurchasesClient {
  public static func live(
    analytics: Analytics,
    userIdentifier: UserIdentifierGenerator
  ) -> Self {
    let impl = PurchasesClientImpl(
      analytics: analytics,
      userIdentifier: userIdentifier
    )

    return PurchasesClient(
      initialize: {
        try await impl.initialize()
      },
      paywalByID: { id in
        try await impl.paywall(by: id)
      },
      purchase: { request in
        try await impl.purchase(request)
      },
      restorePurhases: {
        try await impl.restorePurchases()
      },
      purchases: {
        impl.purchases
      },
      purchasesUpdates: {
        impl.purchasesUpdates
      },
      receipt: {
        let bundle = Bundle.main

        return try bundle.appStoreReceiptURL.flatMap { receiptURL in
          let fileManager = FileManager.default
          guard fileManager.fileExists(atPath: receiptURL.path) else {
            return nil
          }
          return try Data(contentsOf: receiptURL)
        }
      },
      requestReview: {
        let application = await UIApplication.shared
        var activeScene: UIWindowScene?

        for scene in await application.connectedScenes {
          guard
            await scene.activationState == .foregroundActive,
            let scene = scene as? UIWindowScene
          else {
            continue
          }

          activeScene = scene
          break
        }

        if let activeScene {
          await SKStoreReviewController.requestReview(in: activeScene)

          logger.info("requestReview success", dump: [
            "WARNING": "dialog may not appear, Apple doesn't provide developers any control"
          ])
        } else {
          logger.error("requestReview failure", dump: [
            "error": "Active `UIWindowScene` not available"
          ])
        }
      },
      reset: {
        try await impl.reset()
      },
      setFallbackPaywalls: {
        try await impl.setFallbackPaywalls($0)
      },
      logPaywall: { paywall in
        try await impl.log(paywall)
      }
    )
  }
}

final actor PurchasesClientImpl {
  private var adaptyDelegate: _AdaptyDelegate?

  private let _purchases = CurrentValueSubject<Purchases, Never>(.load())

  private var _paywalls: [Paywall.ID: Paywall] = [:]

  private let analytics: Analytics
  private let userIdentifier: UserIdentifierGenerator

  init(
    analytics: Analytics,
    userIdentifier: UserIdentifierGenerator
  ) {
    self.analytics = analytics
    self.userIdentifier = userIdentifier
  }

  nonisolated var purchases: Purchases {
    _purchases.value
  }

  nonisolated var purchasesUpdates: AsyncStream<Purchases> {
    AsyncStream(_purchases.removeDuplicates().values)
  }

  func initialize() async throws {
    do {
      logger.info("initialize")

      guard self.adaptyDelegate == nil else {
        logger.info("Adapty already configured")
        return
      }

      let bundle = Bundle.main
      guard let apiKey = bundle.adaptyAPIKey else {
        assertionFailure("Cannot find a valid Adapty settings")

        logger.error("initialize", dump: [
          "error": "Cannot find a valid Adapty settings"
        ])

        return
      }

      let adaptyDelegate = _AdaptyDelegate()
      self.adaptyDelegate = adaptyDelegate
      Adapty.delegate = adaptyDelegate

      _ = Task.detached(priority: .high) { [weak self] in
        for await event in adaptyDelegate.stream {
          switch event {
          case let .didLoadLatestProfile(profile):
            guard let self else { break }

            let purchases = self.updatePurchases(profile)

            logger.info("purchases updated", dump: [
              "purchases": purchases
            ])
          }
        }
      }

      try await Adapty.activate(
        apiKey,
        customerUserId: userIdentifier().uuidString
      )

      if
        let fallbackURL = Bundle.main.url(
          forResource: "fallback_paywalls",
          withExtension: "json"
        ),
        let fallbackData = try? Data(contentsOf: fallbackURL)
      {
        try? await setFallbackPaywalls(fallbackData)
      }

      logger.info("initialize success")
    } catch {
      logger.info("initialize failure", dump: [
        "error": error.localizedDescription
      ])
    }
  }

  nonisolated
  func paywall(by id: Paywall.ID) async throws -> Paywall? {
    do {
      logger.info("get paywall", dump: [
        "id": id
      ])

      if let paywall = await _paywalls[id] {
        logger.info("get paywall success", dump: [
          "id": id,
          "paywall": paywall,
          "isFromCache": true
        ])

        return paywall
      }

      guard let _paywall = try await _paywall(by: id) else {
        logger.info("get paywall success", dump: [
          "id": id,
          "paywall": "nil",
          "isFromCache": false
        ])

        return nil
      }

      let paywall = Paywall(
        _paywall,
        products: try await _paywallProducts(for: _paywall)
      )

      await cache(paywall)

      logger.info("get paywall success", dump: [
        "id": id,
        "paywall": paywall,
        "isFromCache": false
      ])

      return paywall
    } catch {
      logger.error("get paywall failed", dump: [
        "id": id,
        "failure": error.localizedDescription
      ])

      throw error._map()
    }
  }

  func purchase(
    _ request: PurchaseRequest
  ) async throws -> PurchaseResult {
    do {
      logger.info("purchase", dump: [
        "request": request
      ])

      guard
        let paywall = try await _paywall(by: request.paywallID),
        let products = try await _paywallProducts(for: paywall),
        let product = products
          .first(where: { $0.vendorProductId == request.product.id.rawValue })
      else {
        assertionFailure()
        throw PurchasesError.productUnavailable
      }

      let profile = try await Adapty.makePurchase(product: product)
      let purchases = updatePurchases(profile)

      logger.info("purchase success", dump: [
        "purchases": purchases,
        "request": request
      ])

      return .success(purchases)
    } catch {
      logger.error("purchase failure", dump: [
        "error": error.localizedDescription,
        "request": request
      ])

      let newError = error._map()

      if newError.isPaymentCancelled {
        return .userCancelled
      }

      throw newError
    }
  }

  func restorePurchases() async throws -> RestorePurchasesResult {
    do {
      logger.info("restore purchases")

      let profile = try await Adapty.restorePurchases()
      let purchases = updatePurchases(profile)

      if !purchases.isPremium {
        throw PurchasesError.premiumExpired
      }

      logger.info("restore purchases success", dump: [
        "purchases": purchases
      ])

      return .success(purchases)
    } catch {
      logger.error("restore purchases failure", dump: [
        "error": error.localizedDescription
      ])

      let newError = error._map()

      if newError.isPaymentCancelled {
        return .userCancelled
      }

      throw newError
    }
  }

  nonisolated
  func setFallbackPaywalls(_ data: Data) async throws {
    do {
      logger.info("set fallback paywalls")

      try await Adapty.setFallbackPaywalls(data)

      logger.info("set fallback paywalls success")
    } catch {
      logger.error("set fallback paywalls failure", dump: [
        "error": error.localizedDescription
      ])
      throw error
    }
  }

  nonisolated
  func log(_ paywall: Paywall) async throws {
    do {
      logger.info("log show paywall", dump: [
        "paywall": paywall
      ])

      guard
        let adaptyPaywall = try await _paywall(by: paywall.id)
      else {
        return
      }

      try await Adapty.logShowPaywall(adaptyPaywall)

      logger.info("log show paywall success")
    } catch {
      logger.error("log show paywall failure", dump: [
        "paywall": paywall,
        "error": error.localizedDescription
      ])

      throw error
    }
  }

  func reset() async throws {
    do {
      logger.info("reset")

      try await Adapty.logout()
      try await Adapty.identify(
        userIdentifier().uuidString
      )

      _purchases.value = Purchases()

      logger.info("reset success")
    } catch {
      logger.error("reset failure", dump: [
        "error": error.localizedDescription
      ])

      throw error
    }
  }

  nonisolated
  private func _paywall(
    by id: Paywall.ID
  ) async throws -> AdaptyPaywall? {
    try await Adapty.getPaywall(id.rawValue)
  }

  nonisolated
  private func _paywallProducts(
    for paywall: AdaptyPaywall
  ) async throws -> [AdaptyPaywallProduct]? {
    try await Adapty.getPaywallProducts(
      paywall: paywall,
      fetchPolicy: .default
    )
  }

  private func cache(_ paywall: Paywall) async {
    _paywalls[paywall.id] = paywall
  }

  @discardableResult
  nonisolated
  private func updatePurchases(
    _ profile: AdaptyProfile?
  ) -> Purchases {
    let purchases = Purchases(profile)
    _purchases.value = purchases

    return purchases
  }
}

// MARK: - Adapty

enum AdaptyDelegateEvent: Equatable {
  case didLoadLatestProfile(AdaptyProfile)
}

final class _AdaptyDelegate: AdaptyDelegate {
  private let pipe = AsyncStream<AdaptyDelegateEvent>.streamWithContinuation()

  init() {}

  var stream: AsyncStream<AdaptyDelegateEvent> {
    AsyncStream(pipe.stream)
  }

  // AdaptyDelegate

  func didLoadLatestProfile(
    _ profile: AdaptyProfile
  ) {
    pipe.continuation.yield(
      .didLoadLatestProfile(profile)
    )

    logger.info("delegate: didLoadLatestProfile", dump: [
      "profile": profile
    ])
  }

  func shouldAddStorePayment(
    for product: AdaptyDeferredProduct,
    defermentCompletion makeDeferredPurchase: @escaping (AdaptyResultCompletion<AdaptyProfile>?) -> Void
  ) -> Bool {
    logger.info("delegate: shouldAddStorePayment", dump: [
      "product": product
    ])

    return true
  }
}

private let logger = Logger(
  subsystem: ".SDK.purchases-client",
  category: "Purchases"
)
