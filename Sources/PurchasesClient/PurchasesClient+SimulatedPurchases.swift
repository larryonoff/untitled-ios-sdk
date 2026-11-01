import DuckConcurrency
import DuckPurchasesCore
import Synchronization

extension PurchasesClient {
  /// Uses memory for purchases without charging or changing persisted entitlements.
  public func simulatingPurchases() -> Self {
    var client = self
    let purchases = Mutex(Purchases())
    let updates = AsyncBroadcast(Purchases())
    client.purchases = { purchases.withLock { $0 } }
    client.purchasesUpdates = { updates.stream(bufferingPolicy: .bufferingNewest(1)) }
    client.purchase = { _ in
      purchases.withLock { state in
        state.isPremium = true
        updates.yield(state)
        return .success(state)
      }
    }
    client.restorePurchases = {
      try purchases.withLock { state in
        guard state.isPremium else { throw PurchasesError.premiumExpired }
        return .success(state)
      }
    }
    client.reset = {
      purchases.withLock { state in
        state = Purchases()
        updates.yield(state)
      }
    }
    client.transactionsUpdates = {
      let (stream, continuation) = AsyncStream<DuckTransaction>.makeStream()
      continuation.finish()
      return stream
    }
    return client
  }
}
