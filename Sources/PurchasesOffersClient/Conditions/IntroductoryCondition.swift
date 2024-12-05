import DuckPaywallDependencies
import DuckPurchasesClient
import DuckRemoteSettingsClient
import Foundation

extension PurchasesOfferCondition {
  static func introductory(
    appStorage: UserDefaults,
    paywallID: PaywallIDGenerator,
    purchases: PurchasesClient,
    remoteSettings: RemoteSettingsClient
  ) -> Self {
    Self(
      calculateOffer: { _, _ -> PurchasesOffer? in
        logger.info("calculate intoductory offer")

        guard purchases.purchases().isEligibleForIntroductoryOffer else {
          logger.info("calculate intoductory offer complete", dump: [
            "result": "not eligible fot intro offer"
          ])
          return nil
        }

        logger.info("calculate intoductory offer complete", dump: [
          "result": "eligible"
        ])

        return .introductory
      }
    )
  }
}
