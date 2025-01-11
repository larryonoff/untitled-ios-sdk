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
    let task = Task {
      for await value in userSession.metricsChanges() {
        subscriber.yield(with: .success(value))
      }
    }

    return SharedSubscription {
      task.cancel()
    }
  }
}

public struct UserSessionKeyID: Hashable {}
