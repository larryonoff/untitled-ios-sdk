import Dependencies
import Photos

extension PHPhotoLibrary {
  public var changes: AsyncStream<PHChange> {
    AsyncStream<PHChange> { continuation in
      let sink = PhotoLibraryChangeObserverSink()

      let task = Task {
        self.register(sink)

        for await element in sink.pipe.stream {
          continuation.yield(element)
        }
        continuation.finish()
      }

      continuation.onTermination = { _ in
        self.unregisterChangeObserver(sink)
        task.cancel()
      }
    }
  }
}


// SAFETY: the sink only forwards change notifications into a thread-safe
// AsyncStream continuation; it holds no other mutable state.
private final class PhotoLibraryChangeObserverSink: NSObject, @unchecked Sendable {
  fileprivate let pipe = AsyncStream.makeStream(of: PHChange.self)
}

extension PhotoLibraryChangeObserverSink: PHPhotoLibraryChangeObserver {
  func photoLibraryDidChange(_ changeInstance: PHChange) {
    pipe.continuation.yield(changeInstance)
  }
}
