import AVKit
import Foundation
import SwiftUI

public struct VideoPlayerX<VideoOverlay> where VideoOverlay: View {
  public enum Gravity: Equatable, Hashable {
    case fit
    case fill
    case resize

    var avLayerVideoGravity: AVLayerVideoGravity {
      switch self {
      case .fit:
        return .resizeAspect
      case .fill:
        return .resizeAspectFill
      case .resize:
        return .resize
      }
    }
  }

  var videoAlignment: Alignment = .center
  var videoGravity: Gravity = .fit

  private let player: AVPlayer?

  let videoOverlay: VideoOverlay?

  public init(player: AVPlayer?, videoOverlay: () -> VideoOverlay) {
    self.player = player
    self.videoOverlay = videoOverlay()
  }

  public func videoGravity(_ gravity: Gravity) -> Self {
    var view = self
    view.videoGravity = gravity
    return view
  }

  public func videoAlignment(_ alignment: Alignment) -> Self {
    var view = self
    view.videoAlignment = alignment
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
    playerView.videoGravity = videoGravity.avLayerVideoGravity
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
    uiView.videoGravity = videoGravity.avLayerVideoGravity

    uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    uiView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
  }
}
