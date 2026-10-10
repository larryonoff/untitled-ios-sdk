import AVFoundation
import Foundation

extension AVMutableComposition {
  public func mix(
    withAudioOf audio: AVAsset,
    timeRange: CMTimeRange? = nil
  ) async throws {
    guard
      let sourceAudioTrack = try await audio.loadTracks(withMediaType: .audio)
        .first
    else {
      return
    }

    guard
      let audioTrack = addMutableTrack(
        withMediaType: .audio,
        preferredTrackID: kCMPersistentTrackID_Invalid
      )
    else {
      return
    }

    try audioTrack.insertTimeRange(
      timeRange ?? CMTimeRange(start: .zero, duration: duration),
      of: sourceAudioTrack,
      at: .zero
    )
  }
}
