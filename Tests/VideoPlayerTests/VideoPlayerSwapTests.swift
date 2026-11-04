#if canImport(UIKit)

import AVFoundation
import DuckTestSupport
import Observation
import SwiftUI
import Testing
import UIKit

@testable import DuckVideoPlayer

@MainActor
@Suite(.uiHosting, .timeLimit(.minutes(1)))
struct VideoPlayerSwapTests {
  @Test(arguments: [false, true])
  func `replacing the view releases its player without changing playback`(isPlaying: Bool) async throws {
    let url = try #require(Bundle.module.url(forResource: "video", withExtension: "mp4", subdirectory: "Fixtures"))
    let item = AVPlayerItem(url: url)
    let player = AVPlayer(playerItem: item)
    player.isMuted = true
    defer { player.pause() }
    try await waitUntil { item.status == .readyToPlay }
    await player.seek(to: CMTime(seconds: 0.25, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero)
    // Slow playback keeps this short fixture away from its end during the swaps.
    if isPlaying { player.playImmediately(atRate: 0.01) }
    let position = player.currentTime().seconds
    let branch = Branch()
    let controller = UIHostingController(rootView: SwapRoot(player: player, branch: branch))
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    window.rootViewController = controller
    window.makeKeyAndVisible()
    defer { window.isHidden = true; window.rootViewController = nil }

    for _ in 0..<4 {
      var outgoing: VideoPlayerView?
      try await waitUntil {
        controller.view.layoutIfNeeded()
        outgoing = playerView(in: controller.view)
        return outgoing?.window != nil
      }
      let previous = try #require(outgoing)
      branch.isSecond.toggle()
      try await waitUntil { controller.view.layoutIfNeeded(); return previous.window == nil }

      #expect(previous.player == nil)
      #expect(playerView(in: controller.view)?.player === player)
      #expect(player.currentItem === item)
      #expect(player.rate == (isPlaying ? 0.01 : 0))
      if isPlaying {
        #expect(player.currentTime().seconds >= position)
      } else {
        #expect(abs(player.currentTime().seconds - position) < 0.01)
      }
    }
  }

  @Test func `a removed view cannot resume its former player`() async throws {
    let player = AVPlayer()
    player.isMuted = true
    let branch = Branch()
    let controller = UIHostingController(rootView: SwapRoot(player: player, branch: branch))
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    window.rootViewController = controller
    window.makeKeyAndVisible()
    defer { window.isHidden = true; window.rootViewController = nil; player.pause() }
    var outgoing: VideoPlayerView?
    try await waitUntil { outgoing = playerView(in: controller.view); return outgoing?.window != nil }
    let previous = try #require(outgoing)
    // SwiftUI can dismantle an outgoing view before UIKit takes it out of its window.
    VideoPlayerRepresentable<EmptyView>.dismantleUIView(
      previous,
      coordinator: VideoPlayerRepresentable<EmptyView>.Coordinator()
    )
    #expect(previous.window != nil)
    NotificationCenter.default.post(
      name: AVPlayer.rateDidChangeNotification,
      object: player,
      userInfo: [AVPlayer.rateDidChangeReasonKey: AVPlayer.RateDidChangeReason.audioSessionInterrupted]
    )
    // An attached but dismantled layer must no longer answer the session's pause.
    #expect(player.rate == 0)
  }

  private func playerView(in view: UIView) -> VideoPlayerView? {
    if let player = view as? VideoPlayerView { return player }
    return view.subviews.lazy.compactMap { playerView(in: $0) }.first
  }

  @MainActor
  @Observable
  fileprivate final class Branch {
    var isSecond = false
  }

  private struct SwapRoot: View {
    let player: AVPlayer
    let branch: Branch

    var body: some View {
      if branch.isSecond {
        VStack { CustomVideoPlayer(player: player) }
      } else {
        CustomVideoPlayer(player: player)
          .videoInterruptionBehavior(.resumesMutedPlayback)
      }
    }
  }
}

#endif
