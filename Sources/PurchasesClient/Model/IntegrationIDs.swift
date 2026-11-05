extension PurchasesClient {
  /// The app's identifiers in its other integrations.
  public struct IntegrationIDs: Hashable, Sendable {
    public var adjustDeviceID: String?
    public var airbridgeDeviceID: String?
    public var amplitudeDeviceID: String?
    public var amplitudeUserID: String?
    public var appMetricaDeviceID: String?
    public var appMetricaProfileID: String?
    public var appsFlyerID: String?
    public var branchID: String?
    public var facebookAnonymousID: String?
    public var firebaseAppInstanceID: String?
    public var mixpanelUserID: String?
    public var oneSignalSubscriptionID: String?
    public var postHogDistinctUserID: String?
    public var pushwooshHWID: String?
    public var tenjinAnalyticsInstallationID: String?

    public init(
      adjustDeviceID: String? = nil,
      airbridgeDeviceID: String? = nil,
      amplitudeDeviceID: String? = nil,
      amplitudeUserID: String? = nil,
      appMetricaDeviceID: String? = nil,
      appMetricaProfileID: String? = nil,
      appsFlyerID: String? = nil,
      branchID: String? = nil,
      facebookAnonymousID: String? = nil,
      firebaseAppInstanceID: String? = nil,
      mixpanelUserID: String? = nil,
      oneSignalSubscriptionID: String? = nil,
      postHogDistinctUserID: String? = nil,
      pushwooshHWID: String? = nil,
      tenjinAnalyticsInstallationID: String? = nil
    ) {
      self.adjustDeviceID = adjustDeviceID
      self.airbridgeDeviceID = airbridgeDeviceID
      self.amplitudeDeviceID = amplitudeDeviceID
      self.amplitudeUserID = amplitudeUserID
      self.appMetricaDeviceID = appMetricaDeviceID
      self.appMetricaProfileID = appMetricaProfileID
      self.appsFlyerID = appsFlyerID
      self.branchID = branchID
      self.facebookAnonymousID = facebookAnonymousID
      self.firebaseAppInstanceID = firebaseAppInstanceID
      self.mixpanelUserID = mixpanelUserID
      self.oneSignalSubscriptionID = oneSignalSubscriptionID
      self.postHogDistinctUserID = postHogDistinctUserID
      self.pushwooshHWID = pushwooshHWID
      self.tenjinAnalyticsInstallationID = tenjinAnalyticsInstallationID
    }
  }
}
