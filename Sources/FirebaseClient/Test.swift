import Dependencies
import XCTestDynamicOverlay

extension FirebaseClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = Self(
    initialize: unimplemented("\(Self.self).initialize"),
    reset: unimplemented("\(Self.self).reset")
  )
}

extension FirebaseClient {
  public static let noop = Self(
    initialize: {},
    reset: {}
  )
}
