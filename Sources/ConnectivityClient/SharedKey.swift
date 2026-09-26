import Dependencies
import Sharing

extension SharedReaderKey where Self == ConnectivityKey.Default {
  /// A shared, read-only view of the device's network connectivity.
  ///
  /// Reads the current value immediately and stays subscribed to network path changes for
  /// as long as the shared reference is held — every observer sees the same value without
  /// opening its own monitor.
  public static var connectivity: Self {
    Self[ConnectivityKey(), default: .init()]
  }
}

public struct ConnectivityKey: SharedReaderKey, Sendable {
  @Dependency(\.connectivity) private var connectivity

  public typealias Value = Connectivity

  public var id: ConnectivityKeyID {
    ConnectivityKeyID()
  }

  public func load(
    context: LoadContext<Value>,
    continuation: LoadContinuation<Value>
  ) {
    continuation.resume(returning: connectivity.value())
  }

  public func subscribe(
    context: LoadContext<Value>,
    subscriber: SharedSubscriber<Value>
  ) -> SharedSubscription {
    // Subscribed synchronously, before the task runs: waiting for the task to be
    // scheduled would let a change land in between, and the subscriber has no other
    // source for it.
    let values = connectivity.values()

    let task = Task {
      for await value in values {
        subscriber.yield(value)
      }
    }

    return SharedSubscription {
      task.cancel()
    }
  }
}

public struct ConnectivityKeyID: Hashable {}
