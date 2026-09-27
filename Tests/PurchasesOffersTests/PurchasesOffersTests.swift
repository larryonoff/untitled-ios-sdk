import CustomDump
import ComposableArchitecture
import DuckPaywallTargeting
import DuckPurchasesClient
@testable import DuckPurchasesCore
import DuckPurchasesOffers
import DuckRemoteSettingsClient
import Foundation
import Testing

@MainActor
struct PurchasesOffersTests {
  @Test func refreshPublishesAvailability() async {
    let paywall = Paywall(
      id: "offer",
      products: [.mockYear],
      remoteConfigString: #"{"offer_duration": 3600}"#
    )
    let store = TestStore(initialState: PurchasesOffers.State()) {
      PurchasesOffers()
    } withDependencies: {
      $0.paywallTargeting.paywallForKind = { .init(kind: $0, id: "offer") }
      $0.purchases.paywallByID = { _ in .paywall(paywall) }
      $0.remoteSettings.boolForKey = { _ in nil }
      $0.remoteSettings.fetch = { _ in }
      $0.remoteSettings.stringForKey = { _ in nil }
    }

    await store.send(.refresh)
    await store.receive(\.refreshResponse) {
      $0.$availability.withLock {
        $0 = OfferAvailability(
          introductory: .available(.mock),
          special: .available(
            SpecialOffer(
              kind: .Offer.limitedTime,
              discount: Product.EligibleSubscriptionOffer.mock.discount,
              expiration: .afterFirstShown(3_600)
            )
          )
        )
      }
    }
  }

  @Test func remotelyDisabledOffersAreUnavailable() async {
    let store = TestStore(initialState: PurchasesOffers.State()) {
      PurchasesOffers()
    } withDependencies: {
      $0.remoteSettings.boolForKey = { key in
        switch key {
        case RemoteSettingsClient.isIntroductoryOfferEnabledKey,
             RemoteSettingsClient.isLimitedTimeOfferEnabledKey:
          false
        default:
          nil
        }
      }
      $0.remoteSettings.fetch = { _ in }
      $0.remoteSettings.stringForKey = { _ in nil }
    }

    await store.send(.refresh)
    await store.receive(\.refreshResponse) {
      $0.$availability.withLock {
        $0 = OfferAvailability(introductory: .unavailable, special: .unavailable)
      }
    }
  }

  @Test func offlineLeavesAvailabilityUnknown() async {
    let store = TestStore(initialState: PurchasesOffers.State()) {
      PurchasesOffers()
    } withDependencies: {
      $0.paywallTargeting.paywallForKind = { .init(kind: $0, id: "offer") }
      $0.purchases.paywallByID = { _ in .failure(URLError(.notConnectedToInternet)) }
      $0.remoteSettings.boolForKey = { _ in nil }
      $0.remoteSettings.fetch = { _ in throw URLError(.notConnectedToInternet) }
      $0.remoteSettings.stringForKey = { _ in nil }
    }

    await store.send(.refresh)
    // `.unknown` for both is the initial value, so nothing changes.
    await store.receive(\.refreshResponse)
  }

  @Test func remoteSeasonalOfferReplacesTheLimitedTimeOne() async {
    let paywall = Paywall(
      id: "offer",
      products: [.mockYear],
      remoteConfigString: #"{"offer_end_date": "20261130"}"#
    )
    let store = TestStore(initialState: PurchasesOffers.State()) {
      PurchasesOffers()
    } withDependencies: {
      $0.paywallTargeting.paywallForKind = { .init(kind: $0, id: "offer") }
      $0.purchases.paywallByID = { _ in .paywall(paywall) }
      $0.remoteSettings.boolForKey = { _ in nil }
      $0.remoteSettings.fetch = { _ in }
      $0.remoteSettings.stringForKey = { key in
        key == RemoteSettingsClient.paywallSpecialOfferKey ? "black_friday" : nil
      }
    }
    store.exhaustivity = .off(showSkippedAssertions: false)

    await store.send(.refresh)
    await store.receive(\.refreshResponse)

    expectNoDifference(
      store.state.availability.special,
      .available(
        SpecialOffer(
          kind: .Offer.blackFriday,
          discount: Product.EligibleSubscriptionOffer.mock.discount,
          expiration: .at(paywall.offerEndDate!)
        )
      )
    )
  }

  @Test func offlineRefreshKeepsKnownAvailability() async {
    let known = OfferAvailability(introductory: .available(.mock), special: .unavailable)
    let store = TestStore(initialState: PurchasesOffers.State()) {
      PurchasesOffers()
    }
    store.state.$availability.withLock { $0 = known }

    await store.send(.refreshResponse(OfferAvailability()))
    #expect(store.state.availability == known)
  }
}

private extension AsyncThrowingStream<Paywall?, any Error> {
  static func paywall(_ paywall: Paywall) -> Self {
    let (stream, continuation) = makeStream()
    continuation.yield(paywall)
    continuation.finish()
    return stream
  }

  static func failure(_ error: any Error) -> Self {
    let (stream, continuation) = makeStream()
    continuation.finish(throwing: error)
    return stream
  }
}
