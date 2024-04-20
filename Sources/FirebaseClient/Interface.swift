import Dependencies
import DependenciesMacros

extension DependencyValues {
  public var firebase: FirebaseClient {
    get { self[FirebaseClient.self] }
    set { self[FirebaseClient.self] = newValue }
  }
}

@DependencyClient
public struct FirebaseClient: Sendable {
  public var initialize: @Sendable () -> Void

  @DependencyEndpoint(method: "record")
  public var recordError: @Sendable (
    _ _: Error,
    _ userInfo: [String: Any]?
  ) async -> Void

  public var reset: @Sendable () -> Void
}
