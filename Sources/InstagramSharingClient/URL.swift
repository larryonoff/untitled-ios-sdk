import Foundation

extension URL {
  public static var instagram: Self { URL(string: "instagram://app")! }

  public enum Instagram {
    public static func shareToFeed(
      phAssetID: String
    ) -> URL {
      URL(string: "instagram://library?LocalIdentifier=\(phAssetID)")!
    }

    public static func shareToReels(
      facebookAppID: String
    ) -> URL {
      URL(string: "instagram-reels://share?source_application=\(facebookAppID)")!
    }

    public static func shareToStories(
      facebookAppID: String
    ) -> URL {
      URL(string: "instagram-stories://share?source_application=\(facebookAppID)")!
    }

    public static func reelsAudio(
      byAudioID id: String
    ) -> URL {
      URL(string: "https://www.instagram.com/reels/audio/\(id)/")!
    }

    public static func media(
      byMediaID id: String
    ) -> URL {
      URL(string: "instagram://media?id=\(id)")!
    }

    public static func user(
      byUsername username: String
    ) -> URL {
      URL(string: "instagram://user?username=\(username)")!
    }
  }
}
