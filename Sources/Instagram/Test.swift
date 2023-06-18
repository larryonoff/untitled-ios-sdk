import Dependencies
import Foundation
import XCTestDynamicOverlay

extension InstagramClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = Self(
    addToStory: unimplemented("\(Self.self).addToStory")
  )
}

extension InstagramClient {
  public static let noop = Self(
    addToStory: { _ in }
  )
}
