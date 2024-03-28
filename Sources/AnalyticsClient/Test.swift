import Dependencies
import XCTestDynamicOverlay

extension AnalyticsClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = Self()
}

extension AnalyticsClient {
  public static let noop = Self(
    logEvent: { _, _ in },
    setUserProperty: { _, _ in }
  )
}
