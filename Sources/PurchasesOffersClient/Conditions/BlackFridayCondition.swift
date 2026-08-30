import Dependencies
import DuckLogging
import DuckPaywallDependencies
import DuckPurchasesClient
import DuckRemoteSettingsClient
import Foundation
import OSLog

extension PurchasesOfferCondition {
  static func blackFriday(
    appStorage: UserDefaults,
    paywallID: PaywallIDGenerator,
    purchases: PurchasesClient,
    remoteSettings: RemoteSettingsClient
  ) -> Self {
    // SAFETY: UserDefaults is thread-safe; it just isn't annotated `Sendable`.
    nonisolated(unsafe) let appStorage = appStorage

    return Self(
      calculateOffer: { date, paywallType -> PurchasesOffer? in
        logger.info("offers.evaluate-black-friday")

        guard remoteSettings.paywallSpecialOfferType == .blackFriday else {
          logger.info("offers.evaluate-black-friday skipped | reason: remotely-disabled")
          return nil
        }

        guard appStorage.wasMainPaywallDismissed else {
          logger.info("offers.evaluate-black-friday skipped | reason: main-paywall-never-dismissed")
          return nil
        }

        if case let .blackFriday(offer) = appStorage.purchasesOffer {
          logger.info(
            """
            offers.evaluate-black-friday success | is_new: false
            offer: \(String(describing: offer), privacy: .public)
            """
          )

          return .blackFriday(offer)
        }

        let paywall = await purchases
          .prefetch(paywallByID: paywallID(.Offer.blackFriday))

        if
          let paywall,
          let eligibleOffer = paywall.eligibleOffers.first,
          let endDate = paywall.offerEndDate
        {
          @Dependency(\.calendar) var calendar

          var components = calendar.dateComponents([.year, .month, .day], from: endDate)
          components.day = components.day.flatMap { $0 + 1 }
          components.second = -1

          let localEndDate = calendar.date(from: components) ?? endDate

          let discount = eligibleOffer.discount ?? 0.5

          let offer = PurchasesOffer.BlackFriday(
            discount: discount,
            startDate: date,
            endDate: localEndDate
          )

          guard offer.isValid(for: date) else {
            logger.info("offers.evaluate-black-friday skipped | reason: offer-date-invalid")
            return nil
          }

          logger.info(
            """
            offers.evaluate-black-friday success | is_new: false
            offer: \(String(describing: offer), privacy: .public)
            """
          )

          return .blackFriday(offer)
        }

        logger.info("offers.evaluate-black-friday skipped | reason: offer-unavailable")

        return nil
      }
    )
  }
}
