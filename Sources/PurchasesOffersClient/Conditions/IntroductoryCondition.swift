import DuckLogging
import DuckPaywallDependencies
import DuckPurchasesClient
import DuckRemoteSettingsClient
import Foundation
import OSLog

extension PurchasesOfferCondition {
  static func introductory(
    appStorage: UserDefaults,
    paywallID: PaywallIDGenerator,
    purchases: PurchasesClient,
    remoteSettings: RemoteSettingsClient
  ) -> Self {
    Self(
      calculateOffer: { _, _ -> PurchasesOffer? in
        logger.info("offers.evaluate-introductory")

        guard purchases.purchases().isEligibleForIntroductoryOffer else {
          logger.info("offers.evaluate-introductory skipped | reason: not-eligible")
          return nil
        }

        logger.info("offers.evaluate-introductory success | is_eligible: true")

        return .introductory
      }
    )
  }
}
