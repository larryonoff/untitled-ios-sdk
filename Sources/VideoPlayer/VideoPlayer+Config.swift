public enum VideoDisappearBehavior: Equatable, Hashable, Sendable {
  case reset
  case pause

  public static let `default`: Self = .reset
}

/// What a video does after the audio session pauses it.
///
/// AVFoundation pauses every `AVPlayer` when the audio route loses its device,
/// such as AirPods switching to a Mac or headphones unplugged, muted or not. An
/// owner that doesn't watch the player's rate never notices, and a looping
/// preview stops for good.
public struct VideoInterruptionBehavior: Hashable, Sendable {
  /// Leaves the session's pause in place. The default, matching `AVPlayer`.
  public static let pauses = Self(resumes: false)

  /// Plays the player again the moment the session pauses it, when its
  /// `isMuted` is `true`. A player with sound stays paused, so what came
  /// through the headphones doesn't carry on out of the speaker.
  ///
  /// Only the pause itself is answered, not the end of an interruption such as
  /// a call: by then the owner may have paused the player, and pausing a paused
  /// player leaves no trace to tell. An owner that tracks the rate itself keeps
  /// ``pauses``.
  public static let resumesMutedPlayback = Self(resumes: true)

  /// Whether a muted player the session paused is played again.
  let resumes: Bool
}

public enum VideoPauseBehavior: Equatable, Hashable, Sendable {
  case reset
  case pause

  public static let `default`: Self = .reset
}
