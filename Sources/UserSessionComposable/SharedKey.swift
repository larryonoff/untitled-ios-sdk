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

  public func load(initialValue: UserSessionMetrics?) -> UserSessionMetrics? {
    userSession.metrics()
  }

  public func subscribe(
    initialValue: Value?,
    didSet receiveValue: @escaping @Sendable (Value?) -> Void
  ) -> SharedSubscription {
    let task = Task {
      for await metrics in self.userSession.metricsChanges() {
        receiveValue(metrics)
      }
    }

    return SharedSubscription {
      task.cancel()
    }
  }
}

public struct UserSessionKeyID: Hashable {}
