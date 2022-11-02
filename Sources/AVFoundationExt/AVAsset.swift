import AVFoundation
import Foundation

extension AVAsset {
  public func mixed(
    withAudioOf audio: AVAsset,
    timeRange: CMTimeRange? = nil
  ) throws -> AVMutableComposition? {
    guard
      let audioTrack = audio.tracks(withMediaType: .audio).first,
      let videoTrack = tracks(withMediaType: .video).first
    else {
      return nil
    }

    let composition = AVMutableComposition()

    guard
      let compositionVideoTrack = composition.addMutableTrack(
        withMediaType: .video,
        preferredTrackID: 1
      ),
      let compositionAudioTrack = composition.addMutableTrack(
        withMediaType: .audio,
        preferredTrackID: 2
      )
    else {
      return nil
    }

    try compositionVideoTrack.insertTimeRange(
      CMTimeRange(start: .zero, duration: duration),
      of: videoTrack,
      at: .zero
    )

    try compositionAudioTrack.insertTimeRange(
      timeRange ?? CMTimeRange(start: .zero, duration: duration),
      of: audioTrack,
      at: .zero
    )

    return composition
  }

  public func removingAudio() async throws -> AVAsset {
    let composition = AVMutableComposition()

    try composition.insertTimeRange(
      CMTimeRange(
        start: .zero,
        duration: try await load(.duration)
      ),
      of: self,
      at: .zero
    )

    for track in try await composition.load(.tracks) where track.mediaType == .audio {
      composition.removeTrack(track)
    }

    return composition
  }
}
