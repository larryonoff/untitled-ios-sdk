import Adapty
import Combine
import Dependencies
import DuckAnalyticsClient
import DuckFoundation
import DuckLogging
import DuckUserIdentifierClient
import Foundation
import OSLog
import StoreKit
#if canImport(UIKit)
import UIKit
#endif

extension PurchasesClient {
  public static func live(
    analytics: AnalyticsClient,
    userIdentifier: UserIdentifierGenerator
  ) -> Self {
    let impl = PurchasesClientImpl(
      analytics: analytics,
      userIdentifier: userIdentifier
    )

    return PurchasesClient(
      initialize: {
        impl.initialize()
      },
      paywallByID: { id in
        impl.paywall(by: id)
      },
      purchase: {
        try await impl.purchase($0)
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
        try impl.receipt()
      },
      requestReview: {
        await impl.requestReview()
      },
      reset: {
        try await impl.reset()
      },
      setFallbackPaywalls: {
        try await impl.setFallbackPaywalls(fileURL: $0)
      },
      logPaywall: {
        try await impl.log($0)
      }
    )
  }
}

final class PurchasesClientImpl {
  private let lock = NSRecursiveLock()

  private var adaptyDelegate: _AdaptyDelegate?

  private let _purchases = CurrentValueSubject<Purchases, Never>(.load())

  private var _paywalls: LockIsolated<[Paywall.ID: Paywall]> = .init([:])

  private let analytics: AnalyticsClient
  private let userIdentifier: UserIdentifierGenerator

  init(
    analytics: AnalyticsClient,
    userIdentifier: UserIdentifierGenerator
  ) {
    self.analytics = analytics
    self.userIdentifier = userIdentifier
  }

  var purchases: Purchases {
    _purchases.value
  }

  var purchasesUpdates: AsyncStream<Purchases> {
    _purchases.removeDuplicates().values.eraseToStream()
  }

  func initialize() {
    lock.lock(); defer { lock.unlock() }

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

    let config = AdaptyConfiguration.builder(withAPIKey: apiKey)
      .with(customerUserId: userIdentifier().uuidString)
      .build()

    Adapty.activate(with: config) { error in
      if let error {
        logger.info("initialize failure", dump: [
          "error": error
        ])
      }
    }

    Task { [weak self] in
      if
        let fallbackURL = Bundle.main.url(
          forResource: "fallback_paywalls",
          withExtension: "json"
        )
      {
        try? await self?.setFallbackPaywalls(fileURL: fallbackURL)
      }
    }

    logger.info("initialize success")
  }

  func paywall(
    by id: Paywall.ID
  ) -> AsyncThrowingStream<Paywall?, any Error> {
    AsyncThrowingStream { [weak self] continuation in
      let task = Task { [weak self] in
        do {
          logger.info("get paywall", dump: [
            "id": id
          ])

          var prevPaywall = self?._paywalls[id]

          if let prevPaywall {
            logger.info("get paywall success", dump: [
              "id": id,
              "paywall": paywall,
              "isFromCache": true
            ])

            continuation.yield(prevPaywall)
          }

          guard let _paywall = try await Self.adaptyPaywall(by: id) else {
            logger.info("get paywall success", dump: [
              "id": id,
              "paywall": "nil",
              "isFromCache": false
            ])

            continuation.yield(nil)
            continuation.finish()

            return
          }

          var paywall = Paywall(_paywall, products: nil)

          let adaptyProducts = try await Self.adaptyProducts(for: _paywall)

          if let adaptyProducts {
            paywall.products = _paywall.vendorProductIds
              .compactMap { vendorProductId in
                adaptyProducts
                  .first { $0.vendorProductId == vendorProductId }
                  .flatMap { .init($0) }
              }
          }

          if prevPaywall != paywall {
            prevPaywall = paywall
            continuation.yield(paywall)
            await self?.cache(paywall)
          }

          continuation.finish()

          logger.info("get paywall success", dump: [
            "id": id,
            "paywall": paywall,
            "isFromCache": false
          ])
        } catch {
          logger.error("get paywall failed", dump: [
            "id": id,
            "failure": error
          ])

          continuation.finish(throwing: error)
        }
      }

      continuation.onTermination = { _ in task.cancel() }
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
        let paywall = try await Self.adaptyPaywall(by: request.paywallID),
        let products = try await Self.adaptyProducts(for: paywall),
        let product = products
          .first(where: { $0.vendorProductId == request.product.id.rawValue })
      else {
        assertionFailure()
        throw PurchasesError.productUnavailable
      }

      let purchaseResult = try await Adapty.makePurchase(product: product)

      switch purchaseResult {
      case .pending:
        logger.info("purchase pending", dump: [
          "request": request
        ])
        return .pending
      case let .success(profile: profile, transaction: _):
        let purchases = updatePurchases(profile)

        logger.info("purchase success", dump: [
          "request": request,
          "purchases": purchases
        ])

        return .success(purchases)
      case .userCancelled:
        logger.info("purchase userCancelled", dump: [
          "request": request
        ])
        return .userCancelled
      }
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

  func setFallbackPaywalls(fileURL: URL) async throws {
    do {
      logger.info("set fallback paywalls")

      try await Adapty.setFallbackPaywalls(fileURL: fileURL)

      logger.info("set fallback paywalls success")
    } catch {
      logger.error("set fallback paywalls failure", dump: [
        "error": error.localizedDescription
      ])
      throw error
    }
  }

  func log(_ paywall: Paywall) async throws {
    do {
      logger.info("log show paywall", dump: [
        "paywall": paywall
      ])

      guard
        let adaptyPaywall = try await Self.adaptyPaywall(by: paywall.id)
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

  func receipt() throws -> Data? {
    let bundle = Bundle.main

    return try bundle.appStoreReceiptURL.flatMap { receiptURL in
      let fileManager = FileManager.default
      guard fileManager.fileExists(atPath: receiptURL.path) else {
        return nil
      }
      return try Data(contentsOf: receiptURL)
    }
  }

  func requestReview() async {
#if canImport(UIKit)
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
#endif
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

  private static func adaptyPaywall(
    by id: Paywall.ID
  ) async throws -> AdaptyPaywall? {
    try await Adapty.getPaywall(placementId: id.rawValue)
  }

  private static func adaptyProducts(
    for paywall: AdaptyPaywall
  ) async throws -> [AdaptyPaywallProduct]? {
    try await Adapty
      .getPaywallProducts(paywall: paywall)
  }

  private func cache(_ paywall: Paywall) async {
    _paywalls.withValue {
      $0[paywall.id] = paywall
    }
  }

  @discardableResult
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
  private lazy var pipe = AsyncStream<AdaptyDelegateEvent>.makeStream()

  init() {}

  var stream: AsyncStream<AdaptyDelegateEvent> {
    pipe.stream.eraseToStream()
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
  subsystem: ".SDK.PurchasesClient",
  category: "Purchases"
)
