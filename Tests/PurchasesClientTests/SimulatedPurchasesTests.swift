import DuckPurchasesClient
import Synchronization
import Testing

@testable import DuckPurchasesCore

struct SimulatedPurchasesTests {
  @Test func `simulated purchases restore and reset without touching persistent operations`() async throws {
    let writes = Mutex(0)
    var live = PurchasesClient()
    live.purchase = { _ in writes.withLock { $0 += 1 }; return .success(.init()) }
    live.restorePurchases = { writes.withLock { $0 += 1 }; return .success(.init()) }
    live.reset = { writes.withLock { $0 += 1 } }
    let client = live.simulatingPurchases()
    #expect(!client.purchases().isPremium)
    let result = try await client.purchase(.request(product: .mockYear, paywallID: "test"))
    #expect(result == .success(.init(isPremium: true)))
    var updates = client.purchasesUpdates().makeAsyncIterator()
    let replay = await updates.next()
    #expect(replay?.isPremium == true)
    let restored = try await client.restorePurchases()
    #expect(restored == .success(.init(isPremium: true)))
    try await client.reset()
    #expect(!client.purchases().isPremium)
    #expect(writes.withLock { $0 } == 0)
  }
}

extension SimulatedPurchasesTests {
  @Test(arguments: [false, true])
  func `restoring without a simulated entitlement does not report success`(afterReset: Bool) async throws {
    let client = PurchasesClient().simulatingPurchases()
    if afterReset {
      _ = try await client.purchase(.request(product: .mockYear, paywallID: "test"))
      try await client.reset()
    }
    do {
      _ = try await client.restorePurchases()
      Issue.record("Restoring an empty entitlement must fail")
    } catch PurchasesError.premiumExpired {
      #expect(!client.purchases().isPremium)
    }
  }
}
