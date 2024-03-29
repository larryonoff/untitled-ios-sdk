import Dependencies
import XCTestDynamicOverlay

extension FirebaseClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = Self(
    initialize: unimplemented("\(Self.self).initialize"),
    recordError: unimplemented("\(Self.self).recordError"),
    reset: unimplemented("\(Self.self).reset")
  )
}

extension FirebaseClient {
  public static let noop = Self(
    initialize: {},
    recordError: { _, _ in },
    reset: {}
  )
}
