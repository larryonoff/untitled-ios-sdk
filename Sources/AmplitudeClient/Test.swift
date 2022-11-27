import ComposableArchitecture
import Dependencies
import Foundation
import XCTestDynamicOverlay

extension AmplitudeClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = Self(
    initialize: unimplemented("\(Self.self).initialize")
  )
}

extension AmplitudeClient {
  public static let noop = Self(
    initialize: {}
  )
}
