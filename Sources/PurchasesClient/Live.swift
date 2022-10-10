import Adapty
import Analytics
import Combine
import ComposableArchitecture
import Foundation
import FoundationExt
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
    AsyncStream(_purchases.values.compactMap { $0 })
  }

  func initialize() async {
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
        case let .didReceiveUpdatedPurchaserInfo(purchaserInfo):
          let purchases = self.updatePurchases(purchaserInfo)

          logger.info("delegate: did receive updated purchases", dump: [
            "purchases": purchases
          ])
        case let .didReceivePromo(promo):
          logger.info("delegate: did receive promo", dump: [
            "promo": promo
          ])
        case .didReceivePaywallsForConfig:
          break
        }
      }
    }

    Adapty.activate(
      apiKey,
      customerUserId: userIdentifier().uuidString
    )

    logger.info("initialize success")
  }

  func paywall(by id: Paywall.ID) async throws -> Paywall? {
    do {
      logger.info("get paywall", dump: [
        "id": id
      ])

      let paywall = try await _paywall(by: id)
        .flatMap(Paywall.init)

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
        let product = paywall.products
          .first(where: { $0.vendorProductId == request.product.id.rawValue })
      else {
        assertionFailure()
        throw PurchasesError.productUnavailable
      }

      let result = try await Adapty.makePurchase(
        product: product,
        offerID: product.promotionalOfferId
      )

      let purchases = updatePurchases(result.purchaserInfo)

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

      let result = try await Adapty.restorePurchases()
      let purchases = updatePurchases(result.purchaserInfo)

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
  ) async throws -> PaywallModel? {
    let result = try await Adapty.getPaywalls(forceUpdate: false)
    return (result.paywalls ?? [])
      .first { $0.developerId == id.rawValue }
  }

  @discardableResult
  nonisolated private func updatePurchases(
    _ purchaserInfo: PurchaserInfoModel?
  ) -> Purchases {
    let purchases = Purchases(purchaserInfo)
    _purchases.value = purchases

    return purchases
  }
}

// MARK: - Adapty

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

  // AdaptyDelegate

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


private let logger = Logger(
  subsystem: ".SDK.purchases-client",
  category: "Purchases"
)
