import AVFoundation

extension AVAsset {
  public func mixed(withAudio audio: AVAsset) throws -> AVAsset? {
    guard
      let audioTrack = audio.tracks(withMediaType: .audio).first,
      let videoTrack = tracks(withMediaType: .video).first
    else {
      return nil
    }

    let composition = AVMutableComposition()

    guard
      let videoComposition = composition.addMutableTrack(
        withMediaType: .video,
        preferredTrackID: CMPersistentTrackID(1)
      ),
      let audioComposition = composition.addMutableTrack(
        withMediaType: .audio,
        preferredTrackID: CMPersistentTrackID(2)
      )
    else {
      return nil
    }

    try videoComposition.insertTimeRange(
      CMTimeRangeMake(start: .zero, duration: duration),
      of: videoTrack,
      at: .zero
    )

    try audioComposition.insertTimeRange(
      CMTimeRangeMake(start: .zero, duration: duration),
      of: audioTrack,
      at: .zero
    )

    return composition
  }
}
