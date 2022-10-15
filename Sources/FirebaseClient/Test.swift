import ComposableArchitecture
import Dependencies
import Foundation
import XCTestDynamicOverlay

extension FirebaseClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = Self(
    initialize: XCTUnimplemented("\(Self.self).initialize")
  )
}

extension FirebaseClient {
  public static let noop = Self(
    initialize: {}
  )
}
