import ComposableArchitecture
import DuckAnalyticsClient
@testable import DuckPaywallReducer
import DuckPurchases
@testable import DuckPurchasesCore
import DuckRemoteSettingsClient
import Foundation
import Testing

@MainActor
struct PostDeclineIntroOfferAnalyticsTests {
  /// The trial sold after a declined paywall used to leave no `product_action`.
  @Test func trialPurchaseLogsProductAction() async {
    let events = LockIsolated<[[String: String]]>([])

    let store = TestStore(
      initialState: PostDeclineIntroOffer.State(
        paywallID: "onboarding",
        placement: "onboarding",
        product: .mockYear
      )
    ) {
      PostDeclineIntroOffer()
    } withDependencies: {
      $0.analytics = AnalyticsClient(
        logEvent: { name, parameters in
          guard name == "product_action" else { return }
          events.withValue {
            $0.append((parameters ?? [:]).reduce(into: [:]) {
              $0[$1.key.rawValue] = String(describing: $1.value)
            })
          }
        },
        setUserProperty: { _, _ in }
      )
      $0.purchases.purchase = { _ in .success(.init()) }
    }
    store.exhaustivity = .off(showSkippedAssertions: false)

    await store.send(.purchaseTapped)
    await store.receive(\.purchaseResponse)
    await store.receive(\.delegate)

    #expect(events.value.map { $0["action"] } == ["attempt", "success"])
    #expect(events.value.allSatisfy {
      $0["content_id"] == "year"
        && $0["offer_type"] == "free_trial"
        && $0["offer_price"] == "0"
        && $0["paywall_id"] == "onboarding"
        && $0["placement"] == "onboarding"
    })
  }

  /// Swiping the offer away used to close the paywall without a close event.
  @Test func swipingTheOfferAwayLogsDecline() async {
    let now = Date(timeIntervalSinceReferenceDate: 1_000_000)
    let events = LockIsolated<[(String, [String: String])]>([])

    // Built in `initialState`, whose `@SharedReader`s read the dependencies below.
    let store = TestStore(
      initialState: {
        var state = PaywallReducer.State(
          target: .init(kind: .onboarding, id: "onboarding"),
          placement: "onboarding"
        )
        state.viewedAt = now.addingTimeInterval(-30)
        state.destination = .postDeclineIntroOffer(
          .init(paywallID: "onboarding", placement: "onboarding", product: .mockYear)
        )
        return state
      }()
    ) {
      PaywallReducer()
    } withDependencies: {
      $0.analytics = AnalyticsClient(
        logEvent: { name, parameters in
          events.withValue {
            $0.append((name.rawValue, (parameters ?? [:]).reduce(into: [:]) {
              $0[$1.key.rawValue] = String(describing: $1.value)
            }))
          }
        },
        setUserProperty: { _, _ in }
      )
      $0.date.now = now
      // Read by the paywall's `@SharedReader`s.
      $0.purchases.purchases = { Purchases() }
      $0.purchases.purchasesUpdates = { .finished }
      $0.remoteSettings.boolForKey = { _ in nil }
    }
    store.exhaustivity = .off(showSkippedAssertions: false)

    await store.send(.destination(.dismiss))
    await store.receive(\.delegate)

    #expect(events.value.map(\.0) == ["paywall_onboarding_action"])
    #expect(events.value.first?.1["action"] == "intro_offer_declined")
    #expect(events.value.first?.1["seconds_on_screen"] == "30")
  }
}
