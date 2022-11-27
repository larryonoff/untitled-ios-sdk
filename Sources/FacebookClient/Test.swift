import ComposableArchitecture
import Dependencies
import Foundation
import XCTestDynamicOverlay

extension FacebookClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = FacebookClient(
    appDidFinishLaunching: unimplemented("\(Self.self).appDidFinishLaunching"),
    appOpenURL: unimplemented("\(Self.self).appOpenURL")
  )
}

extension FacebookClient {
  public static let noop = FacebookClient(
    appDidFinishLaunching: { _ in },
    appOpenURL: { _, _ in }
  )
}
