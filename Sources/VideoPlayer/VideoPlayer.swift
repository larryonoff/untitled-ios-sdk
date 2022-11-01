import AVKit
import Foundation
import SwiftUI

public struct VideoPlayerX<VideoOverlay> where VideoOverlay: View {
  public enum Gravity: Equatable, Hashable {
    case resizeAspect
    case resizeAspectFill
    case resize

    var avLayerVideoGravity: AVLayerVideoGravity {
      switch self {
      case .resizeAspect:
        return .resizeAspect
      case .resizeAspectFill:
        return .resizeAspectFill
      case .resize:
        return .resize
      }
    }
  }

  var gravity: Gravity = .resizeAspect

  private let player: AVPlayer?

  let videoOverlay: VideoOverlay?

  public init(player: AVPlayer?, videoOverlay: () -> VideoOverlay) {
    self.player = player
    self.videoOverlay = videoOverlay()
  }

  public func gravity(_ gravity: Gravity) -> Self {
    var view = self
    view.gravity = gravity
    return view
  }
}

extension VideoPlayerX where VideoOverlay == EmptyView {
  public init(player: AVPlayer?) {
    self.player = player
    self.videoOverlay = nil
  }
}

// MARK: - UIViewRepresentable

extension VideoPlayerX: UIViewRepresentable {
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
    playerView.videoGravity = gravity.avLayerVideoGravity
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
    uiView.videoGravity = gravity.avLayerVideoGravity

    uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    uiView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
  }
}
