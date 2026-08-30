import Dependencies
import Foundation

extension InstagramSharingClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension InstagramSharingClient {
  public static let noop = Self(
    shareToFeed: { _ in false },
    shareToReels: { _ in false },
    shareToStories: { _ in false }
  )
}
