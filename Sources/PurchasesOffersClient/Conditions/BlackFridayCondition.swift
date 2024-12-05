import Dependencies
import DuckPaywallDependencies
import DuckPurchasesClient
import DuckRemoteSettingsClient
import Foundation

extension PurchasesOfferCondition {
  static func blackFriday(
    appStorage: UserDefaults,
    paywallID: PaywallIDGenerator,
    purchases: PurchasesClient,
    remoteSettings: RemoteSettingsClient
  ) -> Self {
    Self(
      calculateOffer: { date, paywallType -> PurchasesOffer? in
        logger.info("calculate black friday")

        guard remoteSettings.paywallSpecialOfferType == .blackFriday else {
          logger.info("calculate black friday complete", dump: [
            "result": "black friday remotely disabled"
          ])
          return nil
        }

        guard appStorage.wasMainPaywallDismissed else {
          logger.info("calculate black friday complete", dump: [
            "result": "main paywall never dismissed"
          ])
          return nil
        }

        if case let .blackFriday(offer) = appStorage.purchasesOffer {
          logger.info("calculate black friday complete", dump: [
            "isNew": false,
            "result": offer
          ])

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
            logger.info("calculate black friday complete", dump: [
              "result": "offer date is invalid"
            ])
            return nil
          }

          logger.info("calculate black friday complete", dump: [
            "isNew": false,
            "result": offer
          ])

          return .blackFriday(offer)
        }

        logger.info("calculate black friday complete", dump: [
          "result": "black friday offer not available"
        ])

        return nil
      }
    )
  }
}
