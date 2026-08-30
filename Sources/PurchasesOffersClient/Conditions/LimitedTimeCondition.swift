//import DuckPaywallDependencies
//import DuckPurchasesClient
//import DuckRemoteSettingsClient
//import Foundation
//
//extension PurchasesOfferCondition {
//  static func blackFriday(
//    appStorage: UserDefaults,
//    paywallID: PaywallIDGenerator,
//    purchases: PurchasesClient,
//    remoteSettings: RemoteSettingsClient
//  ) -> Self {
//    Self(
//      calculateOffer: { date, paywallType -> PurchasesOffer? in
//        logger.info("offers.evaluate-limited-time")
//
//        guard remoteSettings.isLimitedTimeOfferEnabled else {
//          logger.info("offers.evaluate-limited-time skipped | reason: remotely-disabled")
//          return nil
//        }
//
//        guard appStorage.wasMainPaywallDismissed else {
//          logger.info("offers.evaluate-limited-time skipped | reason: main-paywall-never-dismissed")
//          return nil
//        }
//
//        let activateTimer = paywallType == .Offer.limitedTime
//
//        if case var .limitedTime(offer) = appStorage.purchasesOffer {
//          if activateTimer, offer.startDate == nil {
//            offer.startDate = date
//          }
//
//          guard offer.isValid(for: date) else {
//            logger.info("offers.evaluate-limited-time skipped | reason: offer-date-invalid")
//            return nil
//          }
//
//          logger.info(
//            """
//            offers.evaluate-limited-time success | \
//            is_new: false \
//            should_activate_timer: \(activateTimer, privacy: .public)
//            offer: \(String(describing: offer), privacy: .public)
//            """
//          )
//
//          return .limitedTime(offer)
//        }
//
//        guard !appStorage.isLimitedOfferDisabled else {
//          logger.info("offers.evaluate-limited-time skipped | reason: already-presented")
//
//          return nil
//        }
//
//        let paywall = try? await self.purchases
//          .prefetch(paywallByID: paywallID(.Offer.limitedTime))
//
//        if
//          let paywall,
//          let duration = paywall.offerDuration,
//          let eligibleOffer = paywall.eligibleOffers.first,
//        {
//          let discount = eligibleOffer.discount ?? 0.5
//
//          let offer = PurchasesOffer.LimitedTime(
//            discount: discount,
//            startDate: activateTimer ? date : nil,
//            duration: duration
//          )
//
//          logger.info(
//            """
//            offers.evaluate-limited-time success | is_new: true
//            offer: \(String(describing: offer), privacy: .public)
//            """
//          )
//
//          return .limitedTime(offer)
//        }
//
//        logger.info("offers.evaluate-limited-time skipped | reason: offer-unavailable")
//
//        return nil
//      }
//    )
//  }
//}
