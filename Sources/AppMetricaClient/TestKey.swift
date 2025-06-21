import Dependencies

extension AppMetricaClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension AppMetricaClient {
  public static let noop = Self(
    deviceID: { nil },
    profileID: { nil },
    reportError: { _ in },
    reportExternalAttribution: { _, _ in },
    reset: {}
  )
}
