import Adapty
import Analytics
import Combine
import ComposableArchitecture
import Foundation
import FoundationExt
import LoggerExt
import os.log
import StoreKit

extension PurchasesClient {
  public static func live(
    analytics: Analytics
  ) -> Self {
    let impl = PurchasesClientImpl(
      analytics: analytics
    )

    return PurchasesClient(
      initialize: {
        await impl.initialize()
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
      logPaywall: { paywall in
        try await impl.log(paywall)
      }
    )
  }
}

final actor PurchasesClientImpl {
  private var adaptyDelegate: _AdaptyDelegate?
  private let adaptyDelegatePipe = AsyncStream<AdaptyDelegateEvent>.streamWithContinuation()
  private nonisolated let adaptyPaywalls: ActorIsolated<[PaywallModel]> = .init([])

  private let _purchases = CurrentValueSubject<Purchases?, Never>(nil)

  private let analytics: Analytics

  init(analytics: Analytics) {
    self.analytics = analytics
  }

  nonisolated var purchases: Purchases {
    _purchases.value ?? .init()
  }

  nonisolated var purchasesUpdates: AsyncStream<Purchases> {
    AsyncStream(_purchases.values.compactMap { $0 })
  }

  func initialize() async {
    guard self.adaptyDelegate == nil else {
      return
    }

    let bundle = Bundle.main
    guard let apiKey = bundle.adaptyAPIKey else {
      assertionFailure()

      logger.error(
        "initialize",
        dump: ["error": "Adapty API key not set"]
      )

      return
    }

    self.adaptyDelegate = _AdaptyDelegate()
    Adapty.delegate = self.adaptyDelegate

    Adapty.activate(apiKey)

    _ = Task.detached(priority: .high) { [weak self] in
      guard
        let self = self,
        let adaptyDelegate = await self.adaptyDelegate
      else {
        return
      }

      for await event in adaptyDelegate.stream {
        switch event {
        case let .didReceiveUpdatedPurchaserInfo(purchaserInfo):
          let purchases = Purchases(purchaserInfo)
          self._purchases.value = purchases

          self.analytics.set(
            purchases.isPremium,
            for: .isPremium
          )

          logger.info(
            "purchases updated",
            dump: ["purchases": purchases]
          )
        case .didReceivePromo:
          break
        case let .didReceivePaywallsForConfig(paywalls):
          await self.adaptyPaywalls.setValue(paywalls)
        }
      }
    }
  }

  func paywalls() async throws -> [Paywall] {
    logger.info("fetch paywalls started")

    if await !adaptyPaywalls.isEmpty {
      let paywalls = await adaptyPaywalls.value.map(Paywall.init)

      logger.info(
        "fetch paywalls response",
        dump: [
          "isCached": true,
          "paywalls": paywalls
        ]
      )

      return paywalls
    }

    do {
      let result = try await Adapty.getPaywalls(forceUpdate: false)
      await adaptyPaywalls.setValue(result.paywalls ?? [])
      let paywalls = await adaptyPaywalls.value.map(Paywall.init)

      logger.info(
        "fetch paywalls response",
        dump: [
          "isCached": false,
          "paywalls": paywalls
        ]
      )

      return paywalls
    } catch {
      logger.error(
        "fetch paywalls failed",
        dump: [
          "error": error.localizedDescription
        ]
      )

      await adaptyPaywalls.setValue([])
      throw error
    }
  }

  func paywall(by id: Paywall.ID) async throws -> Paywall? {
    try await paywalls()
      .first { $0.id == id }
  }

  func purchase(
    _ request: PurchaseRequest
  ) async throws -> PurchaseResult {
    do {
      logger.info(
        "purchase",
        dump: [
          "request": request
        ]
      )

      guard
        let paywall = await adaptyPaywalls.value
          .first(where: { $0.developerId == request.paywallID.rawValue }),
        let product = paywall.products
          .first(where: { $0.vendorProductId == request.product.id.rawValue })
      else {
        assertionFailure()
        throw PurchasesError.productUnavailable
      }

      let result = try await Adapty.makePurchase(
        product: product,
        offerID: nil
      )
      let purchases = Purchases(result.purchaserInfo)

      self._purchases.value = purchases

      logger.info(
        "purchase response",
        dump: [
          "purchases": purchases,
          "request": request
        ]
      )

      analytics.logPurchase(request)

      return .success(purchases)
    } catch {
      logger.error(
        "purchase failed",
        dump: [
          "error": error.localizedDescription,
          "request": request
        ]
      )

      analytics.logPurchaseFailed(
        with: error,
        request: request
      )

      if error.isPaymentCancelled {
        return .userCancelled
      }

      throw error
    }
  }

  func restorePurchases() async throws -> RestorePurchasesResult {
    do {
      logger.info("restore purchases")

      let result = try await Adapty.restorePurchases()
      let purchases = Purchases(result.purchaserInfo)

      self._purchases.value = purchases

      if !purchases.isPremium {
        throw PurchasesError.premiumExpired
      }

      logger.info(
        "restore purchases",
        dump: [
          "purchases": purchases
        ]
      )

      return .success(purchases)
    } catch {
      logger.error(
        "restore purchases failed",
        dump: [
          "error": error.localizedDescription
        ]
      )

      if error.isPaymentCancelled {
        return .userCancelled
      }

      throw error
    }
  }

  func log(_ paywall: Paywall) async throws {
    do {
      logger.info(
        "log show paywall",
        dump: ["paywall": paywall]
      )

      guard
        let adaptyPaywall = await adaptyPaywalls.value
          .first(where: { $0.developerId == paywall.id.rawValue })
      else {
        return
      }

      try await Adapty.logShowPaywall(adaptyPaywall)

      logger.info("log show paywall response")
    } catch {
      logger.error(
        "log show paywall",
        dump: [
          "paywall": paywall,
          "error": error.localizedDescription
        ]
      )

      throw error
    }
  }
}

// MARK: - Adapty

extension PurchasesClientImpl {
  enum AdaptyDelegateEvent: Equatable {
    case didReceiveUpdatedPurchaserInfo(PurchaserInfoModel)
    case didReceivePromo(PromoModel)
    case didReceivePaywallsForConfig([PaywallModel])
  }

  final class _AdaptyDelegate: AdaptyDelegate {
    private let pipe = AsyncStream<AdaptyDelegateEvent>.streamWithContinuation()

    init() {}

    var stream: AsyncStream<AdaptyDelegateEvent> {
      AsyncStream(pipe.stream)
    }

    func didReceiveUpdatedPurchaserInfo(
      _ purchaserInfo: PurchaserInfoModel
    ) {
      pipe.continuation.yield(
        .didReceiveUpdatedPurchaserInfo(purchaserInfo)
      )
    }

    func didReceivePromo(_ promo: PromoModel) {
      pipe.continuation.yield(
        .didReceivePromo(promo)
      )
    }

    func didReceivePaywallsForConfig(paywalls: [PaywallModel]) {
      pipe.continuation.yield(
        .didReceivePaywallsForConfig(paywalls)
      )
    }
  }
}

private let logger = Logger(
  subsystem: ".SDK.purchases-client",
  category: "Purchases"
)
