import Adapty
import DuckPurchasesClient
import Testing

@testable import DuckPurchasesAdaptyClient

struct IntegrationIDsTests {
  @Test func `each identifier goes to Adapty under its own key`() {
    let identifiers = PurchasesClient.IntegrationIDs(
      adjustDeviceID: "adjust",
      appMetricaDeviceID: "appmetrica-device",
      appMetricaProfileID: "appmetrica-profile",
      facebookAnonymousID: "facebook",
      firebaseAppInstanceID: "firebase",
      oneSignalSubscriptionID: "onesignal",
      pushwooshHWID: "pushwoosh"
    )

    let pairs = identifiers.adaptyIdentifiers.map { "\($0.key.rawValue)=\($0.value)" }

    #expect(pairs == [
      "adjust_device_id=adjust",
      "appmetrica_device_id=appmetrica-device",
      "appmetrica_profile_id=appmetrica-profile",
      "facebook_anonymous_id=facebook",
      "firebase_app_instance_id=firebase",
      "one_signal_subscription_id=onesignal",
      "pushwoosh_hwid=pushwoosh"
    ])
  }

  @Test func `a missing identifier is not sent`() {
    let identifiers = PurchasesClient.IntegrationIDs(firebaseAppInstanceID: "firebase")

    #expect(identifiers.adaptyIdentifiers.map(\.key.rawValue) == ["firebase_app_instance_id"])
  }
}
