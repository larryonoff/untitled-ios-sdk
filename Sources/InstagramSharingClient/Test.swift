import Dependencies
import Foundation
import XCTestDynamicOverlay

extension InstagramSharingClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
    shareToFeed: unimplemented("\(Self.self).shareToFeed", placeholder: false),
    shareToReels: unimplemented("\(Self.self).shareToReels", placeholder: false),
    shareToStories: unimplemented("\(Self.self).shareToStories", placeholder: false)
  )
}

extension InstagramSharingClient {
  public static let noop = Self(
    shareToFeed: { _ in false },
    shareToReels: { _ in false },
    shareToStories: { _ in false }
  )
}
