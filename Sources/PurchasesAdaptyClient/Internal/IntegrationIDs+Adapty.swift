import Adapty
import DuckPurchasesClient

extension PurchasesClient.IntegrationIDs {
  var adaptyIdentifiers: [AdaptyIntegrationIdentifier] {
    let identifiers: [(String?, (String) -> AdaptyIntegrationIdentifier)] = [
      (adjustDeviceID, AdaptyIntegrationIdentifier.adjustDeviceId),
      (appMetricaDeviceID, AdaptyIntegrationIdentifier.appmetricaDeviceId),
      (appMetricaProfileID, AdaptyIntegrationIdentifier.appmetricaProfileId),
      (facebookAnonymousID, AdaptyIntegrationIdentifier.facebookAnonymousId),
      (firebaseAppInstanceID, AdaptyIntegrationIdentifier.firebaseAppInstanceId),
      (oneSignalSubscriptionID, AdaptyIntegrationIdentifier.oneSignalSubscriptionId),
      (pushwooshHWID, AdaptyIntegrationIdentifier.pushwooshHWID)
    ]

    return identifiers.compactMap { value, makeIdentifier in
      value.map(makeIdentifier)
    }
  }
}
