import ComposableArchitecture
import DuckAnalyticsClient
import DuckPaywallReducer
import DuckPurchases
@testable import DuckPurchasesCore
import DuckRemoteSettingsClient
import Foundation
import Testing

@MainActor
struct PaywallAnalyticsTests {
  /// The view used to fire for a paywall without products, and again after a
  /// failed refetch was retried.
  @Test func viewIsLoggedOnceTheProductsShow() async {
    let events = LockIsolated<[String]>([])

    let store = TestStore(
      initialState: PaywallReducer.State(
        target: .init(kind: .main, id: "main"),
        placement: nil
      )
    ) {
      PaywallReducer()
    } withDependencies: {
      $0.analytics = AnalyticsClient(
        logEvent: { name, _ in events.withValue { $0.append(name.rawValue) } },
        setUserProperty: { _, _ in }
      )
      $0.date.now = Date(timeIntervalSinceReferenceDate: 1_000_000)
      $0.purchases.logPaywall = { _ in }
      // Read by the paywall's `@SharedReader`s.
      $0.purchases.purchases = { Purchases() }
      $0.purchases.purchasesUpdates = { .finished }
      $0.remoteSettings.boolForKey = { _ in nil }
    }
    store.exhaustivity = .off(showSkippedAssertions: false)

    let empty = Paywall(id: "main", products: [], remoteConfigString: nil)
    let full = Paywall(id: "main", products: [.mockYear], remoteConfigString: nil)

    await store.send(.fetchPaywallResponse(.success(empty)))
    #expect(events.value.isEmpty)

    await store.send(.fetchPaywallResponse(.success(full)))
    await store.send(.fetchPaywallResponse(.failure(CancellationError())))
    await store.send(.fetchPaywallResponse(.success(full)))

    #expect(events.value == ["paywall_main_view"])
  }
}
