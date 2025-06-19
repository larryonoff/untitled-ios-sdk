import Dependencies

extension AnalyticsClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension AnalyticsClient {
  public static let noop = Self(
    logEvent: { _, _ in },
    setUserProperty: { _, _ in }
  )
}
