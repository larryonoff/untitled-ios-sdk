import Dependencies
import XCTestDynamicOverlay

extension AppMetricaClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension AppMetricaClient {
  public static let noop = Self(
    deviceID: { nil },
    reset: {}
  )
}
