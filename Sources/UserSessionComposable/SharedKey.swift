import Dependencies
@_exported import DuckUserSessionClient
import Sharing

extension SharedReaderKey where Self == UserSessionKey.Default {
  public static var userSession: Self {
    Self[UserSessionKey(), default: .init()]
  }
}

public struct UserSessionKey: SharedReaderKey, Sendable {
  @Dependency(\.userSession) var userSession

  public init() {}

  public var id: UserSessionKeyID {
    UserSessionKeyID()
  }

  public typealias Value = UserSessionMetrics

  public func load(
    context: LoadContext<Value>,
    continuation: LoadContinuation<Value>
  ) {
    continuation.resume(with: .success(userSession.metrics()))
  }

  public func subscribe(
    context: LoadContext<Value>,
    subscriber: SharedSubscriber<Value>
  ) -> SharedSubscription {
    // Subscribed synchronously, before the task runs: waiting for the task to be
    // scheduled would let a change land in between, and the subscriber has no other
    // source for it.
    let values = userSession.metricsChanges()

    let task = Task {
      for await value in values {
        subscriber.yield(with: .success(value))
      }
    }

    return SharedSubscription {
      task.cancel()
    }
  }
}

public struct UserSessionKeyID: Hashable {}
