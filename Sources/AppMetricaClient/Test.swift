import Dependencies
import XCTestDynamicOverlay

extension AppMetricaClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = Self(
    deviceID: unimplemented("\(Self.self).deviceID"),
    reset: unimplemented("\(Self.self).reset")
  )
}

extension AppMetricaClient {
  public static let noop = Self(
    deviceID: { nil },
    reset: {}
  )
}
