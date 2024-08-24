import Dependencies
import DependenciesMacros

extension DependencyValues {
  public var userSession: UserSessionClient {
    get { self[UserSessionClient.self] }
    set { self[UserSessionClient.self] = newValue }
  }
}

@DependencyClient
public struct UserSessionClient: Sendable {
  public var activate: @Sendable () -> Void

  public var metrics: @Sendable (
  ) -> UserSessionMetrics = { .never }

  public var metricsChanges: @Sendable (
  ) -> AsyncStream<UserSessionMetrics> = { .finished }

  public var reset: @Sendable () -> Void
}
