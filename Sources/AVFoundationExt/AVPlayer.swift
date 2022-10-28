import AVFoundation

extension AVPlayer {
  /**
    @abstract    Requests invocation of a block during playback to report changing time.
    @param      interval
      The interval of invocation of the block during normal playback, according to progress of the current time of the player.
    @discussion    The block is invoked periodically at the interval specified, interpreted according to the timeline of the current item.
            The block is also invoked whenever time jumps and whenever playback starts or stops.
            If the interval corresponds to a very short interval in real time, the player may invoke the block less frequently
            than requested. Even so, the player will invoke the block sufficiently often for the client to update indications
            of the current time appropriately in its end-user interface.
  */
  public func periodicTime(
    forInterval interval: CMTime
  ) -> AsyncStream<CMTime> {
    AsyncStream { continuation in
      let observer = addPeriodicTimeObserver(
        forInterval: interval,
        queue: nil,
        using: { continuation.yield($0) }
      )

      continuation.onTermination = { [weak self] _ in
        self?.removeTimeObserver(observer)
      }
    }
  }

  /**
    @abstract    Requests invocation of a block when specified times are traversed during normal playback.
    @param      times
      The times for which the observer requests notification, supplied as an array of NSValues carrying CMTimes.
    @param      queue
      The serial queue onto which block should be enqueued.  If you pass NULL, the main queue (obtained using dispatch_get_main_queue()) will be used.  Passing a
      concurrent queue to this method will result in undefined behavior.
    @param      block
      The block to be invoked when any of the specified times is crossed during normal playback.
  */
  public func boundaryTime(
    forTimes times: [CMTime]
  ) -> AsyncStream<Void> {
    guard !times.isEmpty else {
      return AsyncStream { $0.finish() }
    }

    return AsyncStream { continuation in
      let observer = addBoundaryTimeObserver(
        forTimes: times.map(NSValue.init(time:)),
        queue: nil,
        using: { continuation.yield(()) }
      )

      continuation.onTermination = { [weak self] _ in
        self?.removeTimeObserver(observer)
      }
    }
  }
}
