import AVFoundation

extension AVAssetWriter {
  public func finishWriting() async {
    await withCheckedContinuation { continuation in
      self.finishWriting {
        continuation.resume(returning: ())
      }
    }
  }
}
