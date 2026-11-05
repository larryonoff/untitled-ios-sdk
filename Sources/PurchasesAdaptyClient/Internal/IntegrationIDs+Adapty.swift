import Adapty
import DuckPurchasesClient

extension PurchasesClient.IntegrationIDs {
  var adaptyIdentifiers: [AdaptyIntegrationIdentifier] {
    let identifiers: [(String?, (String) -> AdaptyIntegrationIdentifier)] = [
      (adjustDeviceID, AdaptyIntegrationIdentifier.adjustDeviceId),
      (airbridgeDeviceID, AdaptyIntegrationIdentifier.airbridgeDeviceId),
      (amplitudeDeviceID, AdaptyIntegrationIdentifier.amplitudeDeviceId),
      (amplitudeUserID, AdaptyIntegrationIdentifier.amplitudeUserId),
      (appMetricaDeviceID, AdaptyIntegrationIdentifier.appmetricaDeviceId),
      (appMetricaProfileID, AdaptyIntegrationIdentifier.appmetricaProfileId),
      (appsFlyerID, AdaptyIntegrationIdentifier.appsflyerId),
      (branchID, AdaptyIntegrationIdentifier.branchId),
      (facebookAnonymousID, AdaptyIntegrationIdentifier.facebookAnonymousId),
      (firebaseAppInstanceID, AdaptyIntegrationIdentifier.firebaseAppInstanceId),
      (mixpanelUserID, AdaptyIntegrationIdentifier.mixpanelUserId),
      (oneSignalSubscriptionID, AdaptyIntegrationIdentifier.oneSignalSubscriptionId),
      (postHogDistinctUserID, AdaptyIntegrationIdentifier.posthogDistinctUserId),
      (pushwooshHWID, AdaptyIntegrationIdentifier.pushwooshHWID),
      (tenjinAnalyticsInstallationID, AdaptyIntegrationIdentifier.tenjinAnalyticsInstallationId)
    ]

    return identifiers.compactMap { value, makeIdentifier in
      value.map(makeIdentifier)
    }
  }
}
