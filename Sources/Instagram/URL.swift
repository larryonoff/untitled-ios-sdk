import Foundation

extension URL {
  public static let instagram = URL(string: "instagram://app")!

  public static func instagramReelsAudio(
    byAudioID id: String
  ) -> Self {
    .init(string: "https://www.instagram.com/reels/audio/\(id)/")!
  }

  public static func instagramMedia(
    byMediaID id: String
  ) -> Self {
    .init(string: "instagram://media?id=\(id)")!
  }

  public static func instagramUser(
    byUsername username: String
  ) -> Self {
    .init(string: "instagram://user?username=\(username)")!
  }
}
