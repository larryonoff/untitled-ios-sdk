#if canImport(UIKit)

import AVKit
import Foundation
import SwiftUI

struct VideoPlayerRepresentable<VideoOverlay> where VideoOverlay: View {
  @Environment(\.videoAlignment) var videoAlignment
  @Environment(\.videoContentMode) var videoContentMode
  @Environment(\.videoInterruptionBehavior) var videoInterruptionBehavior

  private let player: AVPlayer?

  let videoOverlay: VideoOverlay?

  init(
    player: AVPlayer?,
    videoOverlay: VideoOverlay?
  ) {
    self.player = player
    self.videoOverlay = videoOverlay
  }
}

// MARK: - UIViewRepresentable

extension VideoPlayerRepresentable: UIViewRepresentable {
  final class Coordinator {
    var videoOverlayHostingController: UIHostingController<VideoOverlay>?
  }

  func makeCoordinator() -> Coordinator {
    Coordinator()
  }

  func makeUIView(
    context: Context
  ) -> VideoPlayerView {
    // The environment-driven properties are left to `updateUIView`, which
    // SwiftUI calls right after this.
    let playerView = VideoPlayerView(player: player)
    playerView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    playerView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    videoOverlay.flatMap {
      let videoOverlayController = UIHostingController(rootView: $0)
      let videoOverlayView = videoOverlayController.view!
      videoOverlayView.backgroundColor = .clear
      videoOverlayView.translatesAutoresizingMaskIntoConstraints = false
      videoOverlayView.clipsToBounds = true

      context.coordinator.videoOverlayHostingController = videoOverlayController

      playerView.contentOverlayView.addSubview(videoOverlayView)

      let constraints = [
        videoOverlayView.leadingAnchor
          .constraint(equalTo: playerView.videoRectLayoutGuide.leadingAnchor),
        videoOverlayView.trailingAnchor
          .constraint(equalTo: playerView.videoRectLayoutGuide.trailingAnchor),
        videoOverlayView.topAnchor
          .constraint(equalTo: playerView.videoRectLayoutGuide.topAnchor),
        videoOverlayView.bottomAnchor
          .constraint(equalTo: playerView.videoRectLayoutGuide.bottomAnchor)
      ]
      NSLayoutConstraint.activate(constraints)
    }

    return playerView
  }

  func updateUIView(
    _ uiView: VideoPlayerView,
    context: Context
  ) {
    videoOverlay.flatMap {
      context.coordinator.videoOverlayHostingController?.rootView = $0
    }

    uiView.player = player
    uiView.videoAlignment = videoAlignment
    uiView.videoContentMode = videoContentMode
    uiView.interruptionBehavior = videoInterruptionBehavior
  }

  static func dismantleUIView(_ uiView: VideoPlayerView, coordinator: Coordinator) {
    // A layout swap can attach the successor before this view leaves its window.
    // Detach only this layer; the owner keeps the player's item, position and intent.
    // Clearing the player also releases this view's interruption recovery.
    uiView.player = nil
  }
}

#endif
