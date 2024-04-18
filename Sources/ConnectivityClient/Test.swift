import Dependencies

extension ConnectivityClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension ConnectivityClient {
  public static let noop = Self(
    connectivityInfo: { .init(isConnected: true, state: .otherWithInternet) },
    updates: { .finished }
  )
}
