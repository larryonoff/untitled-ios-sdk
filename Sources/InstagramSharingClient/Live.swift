import Dependencies
import DuckUIKit
import Foundation
import OSLog
import UIKit

private var _documentController: UIDocumentInteractionController?

extension InstagramSharingClient: DependencyKey {
  public static let liveValue = Self.live()
}

extension InstagramSharingClient {
  static func live() -> Self {
    Self(
      shareToFeed: { request in
        guard
          Bundle.main.applicationQueriesSchemes.contains(
            .URLScheme.instagram
          )
        else {
          assertionFailure(
            "Main Bundle doesn't contain `\(String.URLScheme.instagram)` query scheme"
          )
          return
        }

        @Dependency(\.openURL) var openURL

        if let caption = request.caption {
          let pasteboard = UIPasteboard.general
          pasteboard.string = caption
        }

        await openURL(
          .Instagram.shareToFeed(
            phAssetID: request.phAssetID
          )
        )
      },
      shareToStories: { request in
        guard let facebookAppID = Bundle.main.facebookAppID else {
          assertionFailure("Facebook App ID not set")
          return
        }

        guard
          Bundle.main.applicationQueriesSchemes.contains(
            .URLScheme.instagramStories
          )
        else {
          assertionFailure(
            "Main Bundle doesn't contain `\(String.URLScheme.instagramStories)` query scheme"
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

        await openURL(
          .Instagram.shareToStories(
            facebookAppID: facebookAppID
          )
        )
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

  enum URLScheme {
    static let instagram = "instagram"
    static let instagramStories = "instagram-stories"
  }
}

private let logger = Logger(
  subsystem: ".SDK.InstagramExport",
  category: "Instagram"
)
