import ComposableArchitecture
import Dependencies
import Foundation
import XCTestDynamicOverlay

extension AppsFlyerClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = AppsFlyerClient(
    initialize: unimplemented("\(Self.self).initialize"),
    appContinueUserActivity: unimplemented("\(Self.self).applicationContinueUserActivity"),
    appOpenURL: unimplemented("\(Self.self).applicationOpenURL")
  )
}

extension AppsFlyerClient {
  public static let noop = AppsFlyerClient(
    initialize: { _ in },
    appContinueUserActivity: { _, _ in },
    appOpenURL: { _, _ in }
  )
}
