import Dependencies
import XCTestDynamicOverlay

extension AmplitudeClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = Self(
    initialize: unimplemented("\(Self.self).initialize"),
    deviceID: unimplemented("\(Self.self).deviceID", placeholder: nil)
  )
}

extension AmplitudeClient {
  public static let noop = Self(
    initialize: {},
    deviceID: { nil }
  )
}
