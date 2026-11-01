import ComposableArchitecture
import DuckAnalyticsClient
import DuckFeedbackClient
import DuckPaywallReducer
import DuckPurchases
import DuckRemoteSettingsClient
import Foundation
import Testing
@testable import DuckPurchasesCore

@Suite(.serialized)
@MainActor
struct PaywallLoadingTests {
  @Test func cachedProductsAreReadyWithoutWaitingForATimer() async {
    await withMainSerialExecutor {
      let store = makeStore()
      let appearance = store.send(.onAppear)
      await Task.megaYield()

      #expect(store.products.map(\.id) == [.mockYear, .mockMonth])
      #expect(store.productSelected?.id == .mockYear)
      #expect(!store.isFetchingPaywall)
      appearance.cancel()
    }
  }

  @Test(arguments: [false, true])
  func loadedProductCanBePurchasedImmediately(changesSelection: Bool) async {
    await withMainSerialExecutor {
      let requests = LockIsolated<[PurchaseRequest]>([])
      let store = makeStore(requests: requests)
      let appearance = store.send(.onAppear)
      await Task.megaYield()

      if changesSelection {
        await store.send(.setSelectedProductID(.mockMonth)).finish()
      }
      await store.send(.purchase).finish()

      let product = changesSelection ? Product.mockMonth : .mockYear
      #expect(store.productSelected == product)
      #expect(requests.value == [.request(product: product, paywallID: "main")])
      #expect(!store.isPurchasing)
      appearance.cancel()
    }
  }

  private func makeStore(
    requests: LockIsolated<[PurchaseRequest]> = LockIsolated([])
  ) -> StoreOf<PaywallReducer> {
    Store(
      initialState: PaywallReducer.State(target: .init(kind: .main, id: "main"), placement: nil)
    ) {
      PaywallReducer()
    } withDependencies: {
      $0.analytics = .noop
      $0.date.now = Date(timeIntervalSinceReferenceDate: 1_000_000)
      $0.feedback = .noop
      $0.purchases.logPaywall = { _ in }
      $0.purchases.paywallByID = { _ in
        let stream = AsyncThrowingStream<Paywall?, any Error>.makeStream()
        stream.continuation.yield(Paywall(id: "main", products: [.mockYear, .mockMonth]))
        stream.continuation.finish()
        return stream.stream
      }
      $0.purchases.purchase = { request in
        requests.withValue { $0.append(request) }
        return .userCancelled
      }
      $0.purchases.purchases = { Purchases() }
      $0.purchases.purchasesUpdates = { .finished }
      $0.remoteSettings.boolForKey = { _ in nil }
    }
  }
}
