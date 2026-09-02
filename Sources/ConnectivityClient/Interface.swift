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
  /// The current connectivity, returned immediately from the most recent network path.
  public var value: @Sendable () -> Connectivity = { Connectivity() }

  /// A stream of connectivity values, beginning with the current one and then every change.
  public var values: @Sendable () -> AsyncStream<Connectivity> = { .finished }
}

extension ConnectivityClient {
  /// Throws ``ConnectivityError/notConnected`` when there is no connectivity,
  /// returning normally otherwise.
  ///
  /// Mirrors `Task.checkCancellation()`: call it at a point where the work
  /// should not proceed offline, and let the thrown error abort the operation.
  public func checkConnectivity() throws {
    guard value().status == .satisfied else {
      throw ConnectivityError.notConnected
    }
  }
}

extension ConnectivityClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension ConnectivityClient {
  public static let noop = Self(
    value: { .init(status: .satisfied) },
    values: { .finished }
  )
}
