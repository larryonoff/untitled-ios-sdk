import Adapty
import Analytics
import Combine
import ComposableArchitecture
import Foundation
import FoundationSupport
import LoggingSupport
import os.log
import StoreKit
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
      purchases: {
        impl.purchases
      },
      purchasesUpdates: {
        impl.purchasesUpdates
      },
      restorePurhases: {
        try await impl.restorePurchases()
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
        return
      }

      let bundle = Bundle.main
      guard let apiKey = bundle.adaptyAPIKey else {
        assertionFailure()

        logger.error("initialize failure", dump: [
          "error": "Adapty API key not set"
        ])

        return
      }

      let adaptyDelegate = _AdaptyDelegate()
      self.adaptyDelegate = adaptyDelegate
      Adapty.delegate = adaptyDelegate

      _ = Task.detached(priority: .high) { [weak self] in
        guard let self = self else {
          return
        }

        for await event in adaptyDelegate.stream {
          switch event {
          case let .didLoadLatestProfile(profile):
            let purchases = self.updatePurchases(profile)

            logger.info("delegate: did receive updated purchases", dump: [
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
        let fallbackURL = Bundle.main.url(forResource: "fallback_paywalls", withExtension: "json"),
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

  func paywall(by id: Paywall.ID) async throws -> Paywall? {
    do {
      logger.info("get paywall", dump: [
        "id": id
      ])

      let paywall: Paywall? = try await { () async throws -> Paywall? in
        guard let _paywall = try await _paywall(by: id) else {
          return nil
        }

        return Paywall(
          _paywall,
          products: try await _paywallProducts(for: _paywall)
        )
      }()

      logger.info("get paywall success", dump: [
        "id": id,
        "paywall": paywall as Any
      ])

      return paywall
    } catch {
      logger.error("get paywall failed", dump: [
        "id": id,
        "failure": error.localizedDescription
      ])

      throw error
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

      if error.isPaymentCancelled {
        return .userCancelled
      }

      throw error
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

      if error.isPaymentCancelled {
        return .userCancelled
      }

      throw error
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

  private nonisolated func _paywall(
    by id: Paywall.ID
  ) async throws -> AdaptyPaywall? {
    try await Adapty.getPaywall(id.rawValue)
  }

  private nonisolated func _paywallProducts(
    for paywall: AdaptyPaywall
  ) async throws -> [AdaptyPaywallProduct]? {
    try await Adapty.getPaywallProducts(
      paywall: paywall,
      fetchPolicy: .default
    )
  }

  @discardableResult
  nonisolated private func updatePurchases(
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
  }

  func paymentQueue(
    shouldAddStorePaymentFor product: AdaptyDeferredProduct,
    defermentCompletion makeDeferredPurchase: @escaping (AdaptyResultCompletion<AdaptyProfile>?) -> Void
  ) {}
}


private let logger = Logger(
  subsystem: ".SDK.purchases-client",
  category: "Purchases"
)
