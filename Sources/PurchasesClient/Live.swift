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
    PurchasesClient(
      initialize: {
        guard _adaptyDelegate == nil else { return }

        logger.info("initialize")

        let bundle = Bundle.main
        guard let apiKey = bundle.adaptyAPIKey else {
          assertionFailure()

          logger.error(
            "initialize",
            dump: ["error": "Adapty API key not set"]
          )

          return
        }

        _adaptyDelegate = _AdaptyDelegate(
            analytics: analytics
        )
        Adapty.delegate = _adaptyDelegate

        Adapty.activate(apiKey)

        _ = Task.detached(priority: .high) {
          do {
            logger.info("initialize: prefetch paywalls")

            try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            _ = try await Paywall.paywalls()

            logger.info("initialize: prefetch paywalls response")
          } catch {
            logger.error(
              "initialize: prefetch paywalls failed",
              dump: ["error": error.localizedDescription]
            )
          }
        }
      },
      paywalByID: { id in
        try await Paywall
          .paywalls()
          .first { $0.id == id }
      },
      purchase: { request in
        do {
          logger.info(
            "purchase",
            dump: [
              "request": request
            ]
          )

          guard
            let paywall = _adaptyPaywalls
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

          _purchases.value = purchases

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
      },
      purchases: {
        _purchases.value ?? .init()
      },
      purchasesUpdates: {
        AsyncStream(
          _purchases.values.compactMap { $0 }
        )
      },
      restorePurhases: {
        do {
          logger.info("restore purchases")

          let result = try await Adapty.restorePurchases()
          let purchases = Purchases(result.purchaserInfo)

          _purchases.value = purchases

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
      },
      logPaywall: { paywall in
        do {
          logger.info(
            "log show paywall",
            dump: ["paywall": paywall]
          )

          guard
            let adaptyPaywall = _adaptyPaywalls
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
    logger.info("fetch paywalls started")

    if !_adaptyPaywalls.isEmpty {
      let paywalls = _adaptyPaywalls.map(Paywall.init)

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
      let result = try await Adapty.getPaywalls(forceUpdate: true)
      _adaptyPaywalls = result.paywalls ?? []
      let paywalls = _adaptyPaywalls.map(Paywall.init)

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

      _adaptyPaywalls = []
      throw error
    }
  }
}

// MARK: - Adapty

private var _adaptyDelegate: _AdaptyDelegate?
private var _adaptyPaywalls: [PaywallModel] = []

private final class _AdaptyDelegate: AdaptyDelegate {
  private let analytics: Analytics

  init(
    analytics: Analytics
  ) {
    self.analytics = analytics
  }

  func didReceiveUpdatedPurchaserInfo(
    _ purchaserInfo: PurchaserInfoModel
  ) {
    let purchases = Purchases(purchaserInfo)
    _purchases.value = purchases

    analytics.set(
      purchases.isPremium,
      for: .isPremium
    )

    logger.info(
      "purchases updated",
      dump: ["purchases": purchases]
    )
  }

  func didReceivePromo(_ promo: PromoModel) {}
}

// MARK: - Purchases

private let _purchases = CurrentValueSubject<Purchases?, Never>(nil)

private let logger = Logger(
  subsystem: ".SDK.purchases-client",
  category: "Purchases"
)
