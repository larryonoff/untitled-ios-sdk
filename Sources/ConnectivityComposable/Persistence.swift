import ComposableArchitecture
import DuckConnectivityClient

extension PersistenceReaderKey where Self == InMemoryKey<ConnectivityInfo> {
  public static var connectivity: Self {
    inMemory("connectivity")
  }
}
