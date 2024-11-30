//import DuckPurchases
//import DuckPaywallDependencies
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
//        logger.info("calculate limited offer")
//
//        guard remoteSettings.isLimitedTimeOfferEnabled else {
//          logger.info("calculate limited offer complete", dump: [
//            "result": "limited offer remotely disabled"
//          ])
//          return nil
//        }
//
//        guard appStorage.wasMainPaywallDismissed else {
//          logger.info("calculate limited offer complete", dump: [
//            "result": "main paywall never dismissed"
//          ])
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
//            logger.info("calculate limited offer complete", dump: [
//              "result": "offer date is invalid"
//            ])
//            return nil
//          }
//
//          logger.info("calculate limited offer complete", dump: [
//            "isNew": false,
//            "activateTimer": activateTimer,
//            "result": offer
//          ])
//
//          return .limitedTime(offer)
//        }
//
//        guard !appStorage.isLimitedOfferDisabled else {
//          logger.info("calculate limited offer complete", dump: [
//            "result": "limited offer was presented before"
//          ])
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
//          logger.info("calculate limited offer complete", dump: [
//            "isNew": true,
//            "result": offer
//          ])
//
//          return .limitedTime(offer)
//        }
//
//        logger.info("calculate limited offer complete", dump: [
//          "result": "limited offer not available"
//        ])
//
//        return nil
//      }
//    )
//  }
//}
