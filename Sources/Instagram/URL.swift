import Foundation

extension URL {
  public static let instagram = URL(string: "instagram://app")!

  public static func addToStory(
    facebookAppID: String
  ) -> Self {
    Self(string: "instagram-stories://share?source_application=\(facebookAppID)")!
  }

  public static func instagramReelsAudio(
    byAudioID id: String
  ) -> Self {
    Self(string: "https://www.instagram.com/reels/audio/\(id)/")!
  }

  public static func instagramMedia(
    byMediaID id: String
  ) -> Self {
    Self(string: "instagram://media?id=\(id)")!
  }

  public static func instagramUser(
    byUsername username: String
  ) -> Self {
    Self(string: "instagram://user?username=\(username)")!
  }
}
