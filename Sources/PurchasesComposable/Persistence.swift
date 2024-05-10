import ComposableArchitecture
@_exported import DuckPurchasesClient

extension PersistenceReaderKey where Self == PersistenceKeyDefault<PurchasesPersistenceKey> {
  public static var purchases: Self {
    PersistenceKeyDefault(PurchasesPersistenceKey(), .init())
  }
}

public struct PurchasesPersistenceKey: PersistenceReaderKey, Sendable {
  @Dependency(\.purchases) var purchases

  public init() {}

  public var id: AnyHashable {
    PurchasesPersistenceKeyID()
  }

  public func load(initialValue: Purchases?) -> Purchases? {
    purchases.purchases()
  }

  public func subscribe(
    initialValue: Purchases?,
    didSet: @escaping (Purchases?) -> Void
  ) -> Shared<Purchases>.Subscription {
    let task = Task {
      for await purchases in self.purchases.purchasesUpdates() {
        didSet(purchases)
      }
    }

    return Shared.Subscription {
      task.cancel()
    }
  }
}

private struct PurchasesPersistenceKeyID: Hashable {}
