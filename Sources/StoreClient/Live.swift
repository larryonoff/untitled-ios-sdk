import Adapty
import Analytics
import AsyncCompatibilityKit
import Combine
import ComposableArchitecture
import Foundation
import FoundationExt
import StoreKit

extension StoreClient {
  public static func live(
    analytics: Analytics
  ) -> Self {
    StoreClient(
      initialize: {
        guard _adaptyDelegate == nil else { return }

        let bundle = Bundle.main
        guard let apiKey = bundle.adaptyAPIKey else {
          assertionFailure()
          return
        }

        _adaptyDelegate = _AdaptyDelegate(
            subscriber: _adaptyDelegateSubject,
            analytics: analytics
        )
        Adapty.delegate = _adaptyDelegate

        Adapty.activate(apiKey)

        _ = Task.detached(priority: .high) {
          try await Paywall.paywalls()
        }
      },
      paywalByID: { id in
        try await Paywall.paywalls()
          .first(where: { $0.id == id })
      },
      purchase: { request in
        do {
          guard let _product = request.product._adaptyProduct else {
            assertionFailure()
            return .userCancelled
          }

          let result = try await Adapty.makePurchase(
            product: _product,
            offerID: request.offerID
          )
          let purchases = Purchases(result.purchaserInfo)

          _purchases.value = purchases

          analytics.logPurchase(request)

          return .success(purchases)
        } catch {
          analytics.logPurchaseFailed(
            with: error,
            request: request
          )

          if error.isPaymentCancelled {
            return .userCancelled
          }
          throw error
        }
      },
      purchases: {
        _purchases.value
      },
      purchasesChange: {
        _purchases.values
      },
      restorePurhases: {
        do {
          let result = try await Adapty.restorePurchases()
          let purchases = Purchases(result.purchaserInfo)

          _purchases.value = purchases

          if !purchases.isPremium {
            throw StoreError.premiumExpired
          }

          return .success(purchases)
        } catch {
          if error.isPaymentCancelled {
            return .userCancelled
          }
          throw error
        }
      },
      logPaywall: { paywall in
        guard
          let adaptyPaywall = _adaptyPaywalls
            .first(where: { $0.developerId == paywall.id.rawValue })
        else {
          return
        }
        try await Adapty.logShowPaywall(adaptyPaywall)
      }
    )
  }
}

// MARK: - Dependencies

private let dataDecoder = JSONDecoder()
private let dataEncoder = JSONEncoder()
private let userDefaults = UserDefaults.standard

// MARK: - Paywall

extension Paywall {
  static func paywalls() async throws -> [Paywall] {
    if !_adaptyPaywalls.isEmpty {
      return _adaptyPaywalls.map(Paywall.init)
    }

    do {
      let result = try await Adapty.getPaywalls(forceUpdate: true)
      _adaptyPaywalls = result.paywalls ?? []
      return _adaptyPaywalls.map(Paywall.init)
    } catch {
      _adaptyPaywalls = []
      throw error
    }
  }
}

// MARK: - Adapty

private var _adaptyDelegate: _AdaptyDelegate?
private let _adaptyDelegateSubject = PassthroughSubject<Void, Never>()
private var _adaptyPaywalls: [PaywallModel] = []

private final class _AdaptyDelegate: AdaptyDelegate {
  private let analytics: Analytics
  private let subscriber: PassthroughSubject<Void, Never>

  init(
    subscriber: PassthroughSubject<Void, Never>,
    analytics: Analytics
  ) {
    self.analytics = analytics
    self.subscriber = subscriber
  }

  func didReceiveUpdatedPurchaserInfo(
    _ purchaserInfo: PurchaserInfoModel
  ) {
    let purchases = Purchases(purchaserInfo)
    purchases.save()

    _purchases.value = purchases

    analytics.set(
      purchases.isPremium,
      for: .isPremium
    )
  }

  func didReceivePromo(_ promo: PromoModel) {}
}

// MARK: - Purchases

private let _purchases = CurrentValueSubject<Purchases, Never>(Purchases.load())

extension Purchases {
  static let purchasesKey = "axiom.store-client.purchases"

  func save() {
    userDefaults.set(
      self,
      forKey: Self.purchasesKey,
      using: dataEncoder
    )
  }

  static func load() -> Self {
    userDefaults.object(
      forKey: Self.purchasesKey,
      using: dataDecoder
    ) ?? Purchases()
  }
}

extension Analytics {
  func logPurchase(
    _ request: PurchaseRequest
  ) {
    log(
      .event(
        eventName: .subscriptionPurchased,
        parameters: [
          .subscriptionPeriod: request
            .product
            .subscriptionInfo?
            .subscriptionPeriod
            .analyticsValue
        ].compactMapValues { $0 }
      )
    )
  }

  func logPurchaseFailed(
    with error: Error,
    request: PurchaseRequest
  ) {
    let nsError = error as NSError

    var parameters: [ParameterName: Any] = [
      .errorCode: nsError.code,
      .errorDomain: nsError.domain,
      .errorDescription: nsError.localizedDescription
    ]
    parameters[.subscriptionPeriod] = request
      .product
      .subscriptionInfo?
      .subscriptionPeriod
      .analyticsValue

    log(
      .event(
        eventName: .subscriptionFailed,
        parameters: parameters
      )
    )
  }
}
