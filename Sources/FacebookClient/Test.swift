import Dependencies
import XCTestDynamicOverlay

extension FacebookClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
    appDidFinishLaunching: unimplemented("\(Self.self).appDidFinishLaunching"),
    appOpenURL: unimplemented("\(Self.self).appOpenURL"),
    anonymousID: unimplemented("\(Self.self).userID", placeholder: ""),
    userID: unimplemented("\(Self.self).userID", placeholder: nil)
  )
}

extension FacebookClient {
  public static let noop = Self(
    appDidFinishLaunching: { _ in },
    appOpenURL: { _, _ in },
    anonymousID: { "" },
    userID: { nil }
  )
}
