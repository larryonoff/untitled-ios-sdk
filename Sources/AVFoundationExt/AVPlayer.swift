import AVFoundation

extension AVPlayer {
  public func periodicTime(
    forInterval interval: CMTime
  ) -> AsyncStream<CMTime> {
    AsyncStream { continuation in
      let observer = addPeriodicTimeObserver(
        forInterval: interval,
        queue: nil,
        using: {
          continuation.yield($0)
        }
      )

      continuation.onTermination = { [weak self] _ in
        self?.removeTimeObserver(observer)
      }
    }
  }

  public func boundaryTime(
    forTimes times: [NSValue]
  ) -> AsyncStream<Void> {
    AsyncStream { continuation in
      let observer = addBoundaryTimeObserver(
        forTimes: times,
        queue: nil,
        using: {
          continuation.yield(())
        }
      )

      continuation.onTermination = { [weak self] _ in
        self?.removeTimeObserver(observer)
      }
    }
  }
}
