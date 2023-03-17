import Dependencies

extension DependencyValues {
  public var firebase: FirebaseClient {
    get { self[FirebaseClient.self] }
    set { self[FirebaseClient.self] = newValue }
  }
}

public struct FirebaseClient {
  public var initialize: @Sendable () -> Void
}
