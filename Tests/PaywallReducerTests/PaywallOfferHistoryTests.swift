import ComposableArchitecture
import DuckPaywallReducer
import DuckPurchases
import DuckRemoteSettingsClient
import Foundation
import Testing

@MainActor
struct PaywallOfferHistoryTests {
  let now = Date(timeIntervalSinceReferenceDate: 1_000_000)
  let limitedTimePaywall = Paywall(
    id: "lto",
    products: [],
    remoteConfigString: #"{"offer_duration": 3600}"#
  )

  @Test func limitedTimePaywallStartsTheCountdown() async {
    let store = makeStore(kind: .Offer.limitedTime)

    await store.send(.fetchPaywallResponse(.success(limitedTimePaywall)))

    #expect(store.state.offerHistory.countdowns == [.Offer.limitedTime: DateInterval(start: now, duration: 3_600)])
  }

  @Test func laterFetchesKeepTheOriginalStart() async {
    let store = makeStore(kind: .Offer.limitedTime)
    let startDate = now.addingTimeInterval(-60)
    store.state.$offerHistory.withLock {
      $0.startCountdown(for: .Offer.limitedTime, duration: 600, at: startDate)
    }

    await store.send(.fetchPaywallResponse(.success(limitedTimePaywall)))

    #expect(store.state.offerHistory.countdowns == [.Offer.limitedTime: DateInterval(start: startDate, duration: 600)])
  }

  @Test func zeroDurationDoesNotStartTheCountdown() async {
    let store = makeStore(kind: .Offer.limitedTime)
    let paywall = Paywall(id: "lto", products: [], remoteConfigString: #"{"offer_duration": 0}"#)

    await store.send(.fetchPaywallResponse(.success(paywall)))

    #expect(store.state.offerHistory.countdowns.isEmpty)
  }

  @Test func mainPaywallDisappearingCountsAsDismissed() async {
    let store = makeStore(kind: .main)

    await store.send(.onDisappear)

    #expect(store.state.offerHistory.dismissalDates == [.main: now])
  }

  @Test func onboardingPaywallDisappearingDoesNotCountAsMain() async {
    let store = makeStore(kind: .onboarding)

    await store.send(.onDisappear)

    #expect(store.state.offerHistory.dismissalDates == [.onboarding: now])
  }

  @Test func seasonalPaywallStartsNoCountdown() async {
    let store = makeStore(kind: .Offer.blackFriday)
    let paywall = Paywall(
      id: "bf",
      products: [],
      remoteConfigString: #"{"offer_duration": 3600, "offer_end_date": "20261130"}"#
    )

    await store.send(.fetchPaywallResponse(.success(paywall)))

    #expect(store.state.offerHistory.countdowns.isEmpty)
  }

  private func makeStore(kind: Paywall.Kind) -> TestStoreOf<PaywallReducer> {
    let store = TestStore(
      initialState: PaywallReducer.State(target: .init(kind: kind, id: "paywall"), placement: nil)
    ) {
      PaywallReducer()
    } withDependencies: {
      $0.date.now = now
      $0.purchases.logPaywall = { _ in }
      // Read by the paywall's `@SharedReader`s.
      $0.purchases.purchases = { Purchases() }
      $0.purchases.purchasesUpdates = { .finished }
      $0.remoteSettings.boolForKey = { _ in nil }
    }
    // Only the offer history is under test here, not the paywall's own state.
    store.exhaustivity = .off(showSkippedAssertions: false)
    return store
  }
}
