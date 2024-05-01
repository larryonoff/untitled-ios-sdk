import ComposableArchitecture
import DuckPurchasesClient

extension PersistenceReaderKey where Self == InMemoryKey<Purchases> {
  public static var purchases: Self {
    inMemory("purchases")
  }
}
