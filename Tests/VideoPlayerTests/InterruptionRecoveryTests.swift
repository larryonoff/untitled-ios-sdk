#if canImport(UIKit)

import AVFoundation
import SwiftUI
import Testing

@testable import DuckVideoPlayer

/// Playing a muted video again the moment the audio session pauses it.
///
/// The session's pause is posted by hand: a route change can't be staged in a
/// test. The player's own notifications for the rate it is then given report
/// `.setRateCalled`, which is left alone.
@MainActor
@Suite("Interruption recovery")
struct InterruptionRecoveryTests {
  @Test("The session's pause is left in place by default")
  func pausesByDefault() {
    #expect(EnvironmentValues().videoInterruptionBehavior == .pauses)
  }

  @Test("A muted player plays again as soon as the session pauses it")
  func resumesMutedPlayer() {
    let player = mutedPlayer()
    withExtendedLifetime(VideoPlayerView.InterruptionRecovery(player: player)) {
      postRateChange(of: player)

      #expect(player.rate == 1)
    }
  }

  @Test("A player with sound stays paused")
  func leavesAudiblePlayerPaused() {
    let player = mutedPlayer()
    player.isMuted = false
    withExtendedLifetime(VideoPlayerView.InterruptionRecovery(player: player)) {
      postRateChange(of: player)

      #expect(player.rate == 0)
    }
  }

  @Test(
    "A pause the session didn't make stays",
    arguments: [AVPlayer.RateDidChangeReason.setRateCalled, .setRateFailed, .appBackgrounded]
  )
  func leavesOtherPausesAlone(reason: AVPlayer.RateDidChangeReason) {
    let player = mutedPlayer()
    withExtendedLifetime(VideoPlayerView.InterruptionRecovery(player: player)) {
      postRateChange(of: player, reason: reason)

      #expect(player.rate == 0)
    }
  }

  @Test("Another player's pause leaves this one alone")
  func ignoresOtherPlayers() {
    let player = mutedPlayer()
    withExtendedLifetime(VideoPlayerView.InterruptionRecovery(player: player)) {
      postRateChange(of: mutedPlayer())

      #expect(player.rate == 0)
    }
  }

  @Test("Letting go of the recovery stops it")
  func stopsWhenReleased() {
    let player = mutedPlayer()
    _ = VideoPlayerView.InterruptionRecovery(player: player)

    postRateChange(of: player)

    #expect(player.rate == 0)
  }

  @Test("A session pausing again straight away isn't answered again")
  func doesNotLoop() {
    let player = mutedPlayer()
    withExtendedLifetime(VideoPlayerView.InterruptionRecovery(player: player)) {
      postRateChange(of: player)
      #expect(player.rate == 1)

      player.pause()
      postRateChange(of: player)

      #expect(player.rate == 0)
    }
  }

  /// A muted player at rate zero — where the session leaves one it paused.
  private func mutedPlayer() -> AVPlayer {
    let player = AVPlayer(playerItem: AVPlayerItem(asset: AVURLAsset(url: URL(filePath: "/dev/null"))))
    player.isMuted = true

    return player
  }

  private func postRateChange(
    of player: AVPlayer,
    reason: AVPlayer.RateDidChangeReason = .audioSessionInterrupted
  ) {
    NotificationCenter.default.post(
      name: AVPlayer.rateDidChangeNotification,
      object: player,
      userInfo: [AVPlayer.rateDidChangeReasonKey: reason]
    )
  }
}

#endif
