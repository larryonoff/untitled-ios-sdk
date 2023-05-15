import Dependencies
import XCTestDynamicOverlay

extension ConnectivityClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = Self(
    updates: unimplemented("\(Self.self).updates", placeholder: .finished)
  )
}

extension ConnectivityClient {
  public static let noop = Self(
    updates: { .finished }
  )
}
