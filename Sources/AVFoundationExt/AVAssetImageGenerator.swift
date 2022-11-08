import AVFoundation

extension AVAssetImageGenerator {
  @available(iOS, introduced: 4.0, obsoleted: 16.0)
  @available(macCatalyst, introduced: 13.1, obsoleted: 16.0)
  @available(macOS, introduced: 10.7, obsoleted: 13.0)
  @available(tvOS, introduced: 9.0, obsoleted: 16.0)
  public func images(
    for times: [CMTime]
  ) -> AsyncThrowingStream<(image: CGImage, actualTime: CMTime), Error> {
    AsyncThrowingStream { continuation in
      do {
        for time in times {
          try Task.checkCancellation()

          var actualTime: CMTime = time
          let image = try self.copyCGImage(
            at: time,
            actualTime: &actualTime
          )

          continuation.yield((image, actualTime))
        }

        continuation.finish()
      } catch {
        continuation.finish(throwing: error)
      }
    }
  }
}
