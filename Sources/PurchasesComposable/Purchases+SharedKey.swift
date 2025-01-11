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

  public typealias Value = Purchases

  public var id: PurchasesKeyID {
    PurchasesKeyID()
  }

  public func load(
    context: LoadContext<Value>,
    continuation: LoadContinuation<Value>
  ) {
    continuation.resume(with: .success(purchases.purchases()))
  }

  public func subscribe(
    context: LoadContext<Value>,
    subscriber: SharedSubscriber<Value>
  ) -> SharedSubscription {
    let task = Task {
      for await value in self.purchases.purchasesUpdates() {
        subscriber.yield(with: .success(value))
      }
    }

    return SharedSubscription {
      task.cancel()
    }
  }
}

public struct PurchasesKeyID: Hashable {}
