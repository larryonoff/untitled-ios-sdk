extension PurchasesClient {
  /// The app's identifiers in its other integrations.
  public struct IntegrationIDs: Hashable, Sendable {
    public var adjustDeviceID: String?
    public var appMetricaDeviceID: String?
    public var appMetricaProfileID: String?
    public var facebookAnonymousID: String?
    public var firebaseAppInstanceID: String?
    public var oneSignalSubscriptionID: String?
    public var pushwooshHWID: String?

    public init(
      adjustDeviceID: String? = nil,
      appMetricaDeviceID: String? = nil,
      appMetricaProfileID: String? = nil,
      facebookAnonymousID: String? = nil,
      firebaseAppInstanceID: String? = nil,
      oneSignalSubscriptionID: String? = nil,
      pushwooshHWID: String? = nil
    ) {
      self.adjustDeviceID = adjustDeviceID
      self.appMetricaDeviceID = appMetricaDeviceID
      self.appMetricaProfileID = appMetricaProfileID
      self.facebookAnonymousID = facebookAnonymousID
      self.firebaseAppInstanceID = firebaseAppInstanceID
      self.oneSignalSubscriptionID = oneSignalSubscriptionID
      self.pushwooshHWID = pushwooshHWID
    }
  }
}
