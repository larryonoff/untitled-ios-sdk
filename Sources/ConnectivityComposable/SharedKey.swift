@_exported import DuckConnectivityClient
import Sharing

extension SharedReaderKey where Self == InMemoryKey<ConnectivityInfo>.Default {
  public static var connectivity: Self {
    Self[.inMemory("connectivity"), default: .init()]
  }
}
