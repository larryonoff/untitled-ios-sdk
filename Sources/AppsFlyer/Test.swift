import ComposableArchitecture
import Dependencies
import Foundation
import XCTestDynamicOverlay

extension AppsFlyerClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = AppsFlyerClient(
    initialize: XCTUnimplemented("\(Self.self).initialize")
  )
}

extension AppsFlyerClient {
  public static let noop = AppsFlyerClient(
    initialize: { _ in }
  )
}
