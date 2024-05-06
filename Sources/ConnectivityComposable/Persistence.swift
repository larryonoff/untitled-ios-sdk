import ComposableArchitecture
@_exported import DuckConnectivityClient

extension PersistenceReaderKey where Self == PersistenceKeyDefault<InMemoryKey<ConnectivityInfo>> {
  public static var connectivity: Self {
    PersistenceKeyDefault(.inMemory("connectivity"), .init())
  }
}
