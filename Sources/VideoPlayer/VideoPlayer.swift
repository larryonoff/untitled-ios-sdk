import AVKit
import Foundation
import SwiftUI

public struct CustomVideoPlayer<VideoOverlay>: View where VideoOverlay: View {
  private let player: AVPlayer?
  private let videoOverlay: VideoOverlay?

  public init(
    player: AVPlayer?,
    @ViewBuilder videoOverlay: () -> VideoOverlay
  ) {
    self.player = player
    self.videoOverlay = videoOverlay()
  }

  public var body: some View {
    VideoPlayerRepresentable(
      player: player,
      videoOverlay: videoOverlay
    )
  }
}

extension CustomVideoPlayer<EmptyView> {
  public init(player: AVPlayer?) {
    self.player = player
    self.videoOverlay = nil
  }
}
