import Dependencies
import XCTestDynamicOverlay

extension FacebookClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension FacebookClient {
  public static let noop = Self(
    continueUserActivity: { _ in false },
    didFinishLaunching: { _ in false },
    openURL: { _, _ in false },
    anonymousID: { "" },
    userID: { nil }
  )
}
