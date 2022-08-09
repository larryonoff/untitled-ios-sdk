import AVFoundation

extension AVAssetExportSession {
  public func export() async {
    await withTaskCancellationHandler {
      self.cancelExport()
    } operation: {
      await withCheckedContinuation { continuation in
        self.exportAsynchronously {
          continuation.resume(returning: ())
        }
      }
    }
  }
}
