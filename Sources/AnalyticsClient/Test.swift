import Dependencies
import XCTestDynamicOverlay

extension AnalyticsClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = Self(
    logEvent: unimplemented("\(Self.self).logEvent"),
    setUserProperty: unimplemented("\(Self.self).setUserProperty")
  )
}

extension AnalyticsClient {
  public static let noop = Self(
    logEvent: { _, _ in },
    setUserProperty: { _, _ in }
  )
}
