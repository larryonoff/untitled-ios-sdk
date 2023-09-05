import Dependencies
import Foundation
import XCTestDynamicOverlay

extension InstagramSharingClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = Self(
    shareToFeed: unimplemented("\(Self.self).shareToFeed"),
    shareToStories: unimplemented("\(Self.self).shareToStories")
  )
}

extension InstagramSharingClient {
  public static let noop = Self(
    shareToFeed: { _ in },
    shareToStories: { _ in }
  )
}
