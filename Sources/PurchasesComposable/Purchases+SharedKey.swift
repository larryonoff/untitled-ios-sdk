import Dependencies
@_exported import DuckPurchasesClient
import Sharing

extension SharedReaderKey where Self == PurchasesKey.Default {
  public static var purchases: Self {
    Self[PurchasesKey(), default: .init()]
  }
}

public struct PurchasesKey: SharedReaderKey, Sendable {
  @Dependency(\.purchases) var purchases

  public init() {}

  public var id: PurchasesKeyID {
    PurchasesKeyID()
  }

  public func load(initialValue: Purchases?) -> Purchases? {
    purchases.purchases()
  }

  public func subscribe(
    initialValue: Value?,
    didSet receiveValue: @escaping @Sendable (_ newValue: Value?) -> Void
  ) -> SharedSubscription {
    let task = Task {
      for await purchases in self.purchases.purchasesUpdates() {
        receiveValue(purchases)
      }
    }

    return SharedSubscription {
      task.cancel()
    }
  }
}

public struct PurchasesKeyID: Hashable {}
