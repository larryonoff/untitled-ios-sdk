import ComposableArchitecture
import DuckPurchasesClient

extension PersistenceReaderKey where Self == PurchasesPersistenceKey {
  public static var purchases: Self {
    PurchasesPersistenceKey()
  }
}

public struct PurchasesPersistenceKey: PersistenceReaderKey, Hashable, Sendable {
  @Dependency(\.purchases) var purchases

  public init() {}

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

  public static func == (lhs: Self, rhs: Self) -> Bool {
    true
  }

  public func hash(into hasher: inout Hasher) {}
}
