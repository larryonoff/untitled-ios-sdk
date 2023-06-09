import Foundation

extension NotificationCenter {
  /// Fixes: notifications sequence not cancelled when underlying task is cancelled
  ///
  /// Returns an asynchronous sequence of notifications produced by this center for a given notification name and optional source object.
  @available(iOS, deprecated: 16.0)
  @available(macOS, deprecated: 13.0)
  @available(tvOS, deprecated: 16.0)
  @available(watchOS, deprecated: 9.0)
  public func _notifications(
    named name: Notification.Name,
    object: AnyObject? = nil
  ) -> AsyncStream<Notification> {
    AsyncStream { continuation in
      let observer = self.addObserver(
        forName: name,
        object: object,
        queue: nil,
        using: { continuation.yield($0) }
      )

      continuation.onTermination = { _ in
        self.removeObserver(observer)
      }
    }
  }
}
