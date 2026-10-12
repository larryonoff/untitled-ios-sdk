import ComposableArchitecture
import CustomDump
import DuckAnalyticsClient
import DuckPurchases
import DuckRemoteSettingsClient
import Foundation
import Testing
@testable import DuckPaywallReducer
@testable import DuckPurchasesCore

@MainActor
struct PaywallPurchaseOutcomeTests {
  @Test func pendingMainPurchaseIsNotSuccessAndLaterConfirmationIsSuccess() async {
    let events = LockIsolated<[[String: String]]>([])
    let dismissals = LockIsolated(0)
    let store = withDependencies {
      configure(&$0, events: events)
    } operation: {
      var state = PaywallReducer.State(target: .init(kind: .main, id: "main"), placement: "test")
      state.isPurchasing = true
      return Store(initialState: state) {
        CombineReducers {
          PaywallReducer()
          Reduce<PaywallReducer.State, PaywallReducer.Action> { _, action in
            if case .delegate(.dismiss) = action { dismissals.withValue { $0 += 1 } }
            return .none
          }
        }
      }
    }
    await store.send(.purchaseResponse(.success(.pending), .mockYear)).finish()
    #expect(!store.isPurchasing)
    expectNoDifference(dismissals.value, 0)
    expectNoDifference(events.value.map { $0["action"] }, ["pending"])
    expectNoDifference(events.value.first?["paywall_id"], "main")
    expectNoDifference(events.value.first?["placement"], "test")

    await store.send(.purchaseResponse(.success(.success(.init(isPremium: true))), .mockYear)).finish()
    expectNoDifference(events.value.map { $0["action"] }, ["pending", "success"])
    expectNoDifference(dismissals.value, 1)
  }

  @Test func pendingIntroOfferDoesNotReportPurchasedAndLaterConfirmationDoes() async {
    let events = LockIsolated<[[String: String]]>([])
    let purchases = LockIsolated(0)
    let store = withDependencies {
      configure(&$0, events: events)
    } operation: {
      var state = PostDeclineIntroOffer.State(paywallID: "main", placement: "test", product: .mockYear)
      state.isPurchasing = true
      return Store(initialState: state) {
        CombineReducers {
          PostDeclineIntroOffer()
          Reduce<PostDeclineIntroOffer.State, PostDeclineIntroOffer.Action> { _, action in
            if case .delegate(.purchased) = action { purchases.withValue { $0 += 1 } }
            return .none
          }
        }
      }
    }
    await store.send(.purchaseResponse(.success(.pending))).finish()
    #expect(!store.isPurchasing)
    expectNoDifference(purchases.value, 0)
    expectNoDifference(events.value.map { $0["action"] }, ["pending"])
    expectNoDifference(events.value.first?["paywall_id"], "main")
    expectNoDifference(events.value.first?["placement"], "test")

    await store.send(.purchaseResponse(.success(.success(.init(isPremium: true))))).finish()
    expectNoDifference(events.value.map { $0["action"] }, ["pending", "success"])
    expectNoDifference(purchases.value, 1)
  }

  private func configure(_ dependencies: inout DependencyValues, events: LockIsolated<[[String: String]]>) {
    dependencies.analytics = AnalyticsClient(
      logEvent: { name, parameters in
        guard name.rawValue == "product_action" else { return }
        let values = (parameters ?? [:]).reduce(into: [String: String]()) {
          $0[$1.key.rawValue] = String(describing: $1.value)
        }
        events.withValue { $0.append(values) }
      },
      setUserProperty: { _, _ in }
    )
    dependencies.date.now = Date(timeIntervalSince1970: 100)
    dependencies.purchases.purchases = { .init() }
    dependencies.purchases.purchasesUpdates = { .finished }
    dependencies.remoteSettings.boolForKey = { _ in nil }
  }
}
