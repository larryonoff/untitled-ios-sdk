import Dependencies
import Foundation

extension DependencyValues {
  public var instagram: InstagramClient {
    get { self[InstagramClient.self] }
    set { self[InstagramClient.self] = newValue }
  }
}

public struct InstagramClient {
  public var addToStory: @Sendable (AddToStoryRequest) async -> Void
}

public struct AddToStoryRequest {
  public enum BackgroundAsset {
    /// Data for an image asset in a supported format (JPG, PNG).
    /// Minimum dimensions 720x1280. Recommended image ratios 9:16 or 9:18.
    case image(Data)

    /// Data for video asset in a supported format (H.264, H.265, WebM).
    /// Videos can be 1080p and up to 20 seconds in duration.
    /// Under 50 MB recommended.
    case video(Data)
  }

  /// Data for an image or video asset
  /// You must pass the Instagram app a background asset (image or video), a sticker asset, or both.
  public let backgroundAsset: BackgroundAsset

  /// Data for an image asset in a supported format (JPG, PNG).
  /// Recommended dimensions: 640x480.
  /// This image appears as a sticker over the background.
  /// You must pass the Instagram app a background asset (image or video), a sticker asset, or both.
  public let stickerImage: Data?

  /// A hex string color value used in conjunction with the background layer bottom color value.
  /// If both values are the same, the background layer is a solid color. If they differ, they are used to generate a gradient.
  public let backgroundTopColor: String?

  /// A hex string color value used in conjunction with the background layer bottom color value.
  /// If both values are the same, the background layer is a solid color. If they differ, they are used to generate a gradient.
  public let backgroundBottomColor: String?

  public init(
    backgroundAsset: BackgroundAsset,
    stickerImage: Data? = nil,
    backgroundTopColor: String? = nil,
    backgroundBottomColor: String? = nil
  ) {
    self.backgroundAsset = backgroundAsset
    self.stickerImage = stickerImage
    self.backgroundTopColor = backgroundTopColor
    self.backgroundBottomColor = backgroundBottomColor
  }
}

extension AddToStoryRequest: Equatable {}

extension AddToStoryRequest: Hashable {}

extension AddToStoryRequest: Sendable {}

extension AddToStoryRequest.BackgroundAsset: Equatable {}

extension AddToStoryRequest.BackgroundAsset: Hashable {}

extension AddToStoryRequest.BackgroundAsset: Sendable {}
