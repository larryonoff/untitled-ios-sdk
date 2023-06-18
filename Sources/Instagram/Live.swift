import Dependencies
import Foundation
import UIKit

extension InstagramClient {
  public static func live() -> Self {
    Self(
      addToStory: { request in
        guard let facebookAppID = Bundle.main.facebookAppID else {
          assertionFailure("Facebook App ID not set")
          return
        }

        guard
          Bundle.main.applicationQueriesSchemes.contains(.QueryScheme.instagramStories)
        else {
          assertionFailure(
            "Main Bundle doesn't contain `\(String.QueryScheme.instagramStories)` query scheme"
          )
          return
        }

        @Dependency(\.date) var date
        @Dependency(\.openURL) var openURL

        var shareItem: [String: Any] = [:]

        switch request.backgroundAsset {
        case let .image(data):
          shareItem[.backgroundImage] = data
        case let .video(data):
          shareItem[.backgroundVideo] = data
        }

        shareItem[.stickerImage] = request.stickerImage
        shareItem[.backgroundTopColor] = request.backgroundTopColor
        shareItem[.backgroundBottomColor] = request.backgroundBottomColor

        UIPasteboard.general.setItems(
          [shareItem],
          options: [
            .expirationDate:  date().addingTimeInterval(60 * 5)
          ]
        )

        await openURL(.addToStory(facebookAppID: facebookAppID))
      }
    )
  }
}

extension Bundle {
  var facebookAppID: String? {
    self.infoDictionary?["FacebookAppID"] as? String
  }

  var applicationQueriesSchemes: [String] {
    (self.infoDictionary?["LSApplicationQueriesSchemes"] as? [String]) ?? []
  }
}

private extension String {
  static let backgroundImage = "com.instagram.sharedSticker.backgroundImage"
  static let backgroundVideo = "com.instagram.sharedSticker.backgroundVideo"
  static let stickerImage = "com.instagram.sharedSticker.stickerImage"
  static let backgroundTopColor = "com.instagram.sharedSticker.backgroundTopColor"
  static let backgroundBottomColor = "com.instagram.sharedSticker.backgroundBottomColor"

  enum QueryScheme {
    static let instagramStories = "instagram-stories"
  }
}
