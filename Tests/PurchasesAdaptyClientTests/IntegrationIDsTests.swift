import Adapty
import DuckPurchasesClient
import Testing

@testable import DuckPurchasesAdaptyClient

struct IntegrationIDsTests {
  @Test func `each identifier goes to Adapty under its own key`() {
    let identifiers = PurchasesClient.IntegrationIDs(
      adjustDeviceID: "adjust_device_id",
      airbridgeDeviceID: "airbridge_device_id",
      amplitudeDeviceID: "amplitude_device_id",
      amplitudeUserID: "amplitude_user_id",
      appMetricaDeviceID: "appmetrica_device_id",
      appMetricaProfileID: "appmetrica_profile_id",
      appsFlyerID: "appsflyer_id",
      branchID: "branch_id",
      facebookAnonymousID: "facebook_anonymous_id",
      firebaseAppInstanceID: "firebase_app_instance_id",
      mixpanelUserID: "mixpanel_user_id",
      oneSignalSubscriptionID: "one_signal_subscription_id",
      postHogDistinctUserID: "posthog_distinct_user_id",
      pushwooshHWID: "pushwoosh_hwid",
      tenjinAnalyticsInstallationID: "tenjin_analytics_installation_id"
    )

    let pairs = identifiers.adaptyIdentifiers.map { "\($0.key.rawValue)=\($0.value)" }

    #expect(pairs == [
      "adjust_device_id=adjust_device_id",
      "airbridge_device_id=airbridge_device_id",
      "amplitude_device_id=amplitude_device_id",
      "amplitude_user_id=amplitude_user_id",
      "appmetrica_device_id=appmetrica_device_id",
      "appmetrica_profile_id=appmetrica_profile_id",
      "appsflyer_id=appsflyer_id",
      "branch_id=branch_id",
      "facebook_anonymous_id=facebook_anonymous_id",
      "firebase_app_instance_id=firebase_app_instance_id",
      "mixpanel_user_id=mixpanel_user_id",
      "one_signal_subscription_id=one_signal_subscription_id",
      "posthog_distinct_user_id=posthog_distinct_user_id",
      "pushwoosh_hwid=pushwoosh_hwid",
      "tenjin_analytics_installation_id=tenjin_analytics_installation_id"
    ])
  }

  @Test func `a missing identifier is not sent`() {
    let identifiers = PurchasesClient.IntegrationIDs(firebaseAppInstanceID: "firebase")

    #expect(identifiers.adaptyIdentifiers.map(\.key.rawValue) == ["firebase_app_instance_id"])
  }
}
