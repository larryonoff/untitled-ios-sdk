#if canImport(UIKit)

import AVFoundation

extension VideoPlayerView {
  /// Plays a muted player again the moment the audio session pauses it.
  ///
  /// Only then: the owner wanted it playing a moment ago, and that is the one
  /// time this is known. `pause()` on a paused player posts nothing, so an
  /// owner's decision after an interruption can't be seen, and a route loss
  /// never ends at all.
  ///
  /// Holding one is what watches `player`; letting go of it stops.
  @MainActor
  final class InterruptionRecovery {
    let player: AVPlayer

    // SAFETY: the token is opaque — only handed back to `removeObserver`, which
    // is thread-safe — and is written once, in `init`.
    private nonisolated(unsafe) var observer: (any NSObjectProtocol)?

    /// When a pause was last answered with `play()`.
    private var lastResume: ContinuousClock.Instant?

    init(player: AVPlayer) {
      self.player = player

      // Read here, on the main actor: the SDK isolates the key to it, and the
      // observer below runs on whichever thread posted.
      let reasonKey = AVPlayer.rateDidChangeReasonKey

      // No queue: a rate change posted on the main thread is answered before
      // `post` returns, rather than a turn later.
      observer = NotificationCenter.default.addObserver(
        forName: AVPlayer.rateDidChangeNotification,
        object: player,
        queue: nil
      ) { [weak self] notification in
        let reason = notification.userInfo?[reasonKey] as? AVPlayer.RateDidChangeReason
        onMainActor { self?.playerRateDidChange(reason: reason) }
      }
    }

    // Not `isolated deinit`: before Swift 6.2's runtime (iOS 18) it can free a
    // task-local scope it never allocated when released inside
    // `TaskLocal.withValue`.
    deinit {
      if let observer { NotificationCenter.default.removeObserver(observer) }
    }

    /// `.setRateFailed` would fail again and `.appBackgrounded` would be paused
    /// again; answering either would loop.
    private func playerRateDidChange(reason: AVPlayer.RateDidChangeReason?) {
      guard
        reason == .audioSessionInterrupted,
        player.rate == 0,
        player.isMuted
      else { return }

      // A session still interrupted may take the player back straight away
      // rather than refuse `play()`; answering that at notification rate loops.
      let now = ContinuousClock.now
      if let lastResume, now - lastResume < .seconds(1) { return }
      lastResume = now

      player.play()
    }
  }
}

#endif
