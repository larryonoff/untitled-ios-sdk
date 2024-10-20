import AVKit
import Foundation
import SwiftUI

@available(*, deprecated, renamed: "CustomVideoPlayer")
public typealias VideoPlayerX = CustomVideoPlayer

public struct CustomVideoPlayer<VideoOverlay> where VideoOverlay: View {
  @Environment(\.videoAlignment) var videoAlignment
  @Environment(\.videoContentMode) var videoContentMode

  private let player: AVPlayer?

  let videoOverlay: VideoOverlay?

  public init(player: AVPlayer?, videoOverlay: () -> VideoOverlay) {
    self.player = player
    self.videoOverlay = videoOverlay()
  }
}

extension CustomVideoPlayer<EmptyView> {
  public init(player: AVPlayer?) {
    self.player = player
    self.videoOverlay = nil
  }
}

// MARK: - UIViewRepresentable

extension CustomVideoPlayer: UIViewRepresentable {
  public final class Coordinator {
    var videoOverlayHostingController: UIHostingController<VideoOverlay>?
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator()
  }

  public func makeUIView(
    context: Context
  ) -> VideoPlayerView {
    let playerView = VideoPlayerView(player: player)
    playerView.videoContentMode = videoContentMode
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

  public func updateUIView(
    _ uiView: VideoPlayerView,
    context: Context
  ) {
    videoOverlay.flatMap {
      context.coordinator.videoOverlayHostingController?.rootView = $0
    }

    uiView.player = player
    uiView.videoAlignment = videoAlignment
    uiView.videoContentMode = videoContentMode

    uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    uiView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
  }
}
