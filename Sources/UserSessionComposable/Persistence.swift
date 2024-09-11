import ComposableArchitecture
@_exported import DuckUserSessionClient

extension PersistenceReaderKey where Self == PersistenceKeyDefault<UserSessionPersistenceKey> {
  public static var userSession: Self {
    PersistenceKeyDefault(UserSessionPersistenceKey(), .init())
  }
}

public struct UserSessionPersistenceKey: PersistenceReaderKey, Sendable {
  @Dependency(\.userSession) var userSession

  public init() {}

  public var id: AnyHashable {
    UserSessionPersistenceKeyID()
  }

  public func load(initialValue: UserSessionMetrics?) -> UserSessionMetrics? {
    userSession.metrics()
  }

  public func subscribe(
    initialValue: UserSessionMetrics?,
    didSet: @escaping (UserSessionMetrics?) -> Void
  ) -> Shared<UserSessionMetrics>.Subscription {
    let task = Task {
      for await metrics in self.userSession.metricsChanges() {
        didSet(metrics)
      }
    }

    return Shared.Subscription {
      task.cancel()
    }
  }
}

private struct UserSessionPersistenceKeyID: Hashable {}
