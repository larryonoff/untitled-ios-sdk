import Dependencies

extension DependencyValues {
  public var connectivity: ConnectivityClient {
    get { self[ConnectivityClient.self] }
    set { self[ConnectivityClient.self] = newValue }
  }
}

public struct ConnectivityClient {
  public var updates: @Sendable () -> AsyncStream<ConnectivityInfo>
}
