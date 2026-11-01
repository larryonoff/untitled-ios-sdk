import Synchronization

extension Notifications {
  /// Acknowledges the OS on its required executor, independently of the event consumer.
  final class Completion<Value: Sendable>: Sendable {
    private let handler: Mutex<(@MainActor @Sendable (Value) -> Void)?>

    init(_ handler: @escaping @MainActor @Sendable (Value) -> Void) {
      self.handler = Mutex(handler)
    }

    func callAsFunction(_ value: Value) {
      let handler = handler.withLock { stored in
        defer { stored = nil }
        return stored
      }
      guard let handler else { return }
      // This finite OS acknowledgement intentionally outlives consumer cancellation.
      // UIKit must receive it even when the host stops observing notification events.
      Task { @MainActor in handler(value) }
    }
  }
}
