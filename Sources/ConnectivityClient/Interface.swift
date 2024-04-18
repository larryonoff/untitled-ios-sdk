import Dependencies
import DependenciesMacros

extension DependencyValues {
  public var connectivity: ConnectivityClient {
    get { self[ConnectivityClient.self] }
    set { self[ConnectivityClient.self] = newValue }
  }
}

@DependencyClient
public struct ConnectivityClient: Sendable {
  public var connectivityInfo: @Sendable (
  ) async -> ConnectivityInfo = { .init(isConnected: false , state: .disconnected) }

  public var updates: @Sendable () -> AsyncStream<ConnectivityInfo> = { .finished }
}
