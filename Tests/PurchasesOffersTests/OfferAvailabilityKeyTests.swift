import CustomDump
import Dependencies
import DuckPaywallTargeting
import DuckPurchasesClient
@testable import DuckPurchasesCore
@testable import DuckPurchasesOffers
import DuckRemoteSettingsClient
import Foundation
import Testing

struct OfferAvailabilityKeyTests {
  @Test func fetchPublishesAvailability() async {
    let paywall = Paywall(
      id: "offer",
      products: [.mockYear],
      remoteConfigString: #"{"offer_duration": 3600}"#
    )
    let availability = await fetch {
      $0.paywallTargeting.paywallForKind = { .init(kind: $0, id: "offer") }
      $0.purchases.paywallByID = { _ in .paywall(paywall) }
      $0.remoteSettings.boolForKey = { _ in nil }
      $0.remoteSettings.fetch = { _ in }
      $0.remoteSettings.stringForKey = { _ in nil }
    }

    expectNoDifference(
      availability,
      OfferAvailability(
        introductory: .available(.mock),
        special: .available(
          SpecialOffer(
            kind: .Offer.limitedTime,
            discount: Product.EligibleSubscriptionOffer.mock.discount,
            expiration: .afterFirstShown(3_600)
          )
        )
      )
    )
  }

  @Test func remotelyDisabledOffersAreUnavailable() async {
    let availability = await fetch {
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

    #expect(availability == OfferAvailability(introductory: .unavailable, special: .unavailable))
  }

  @Test func offlineLeavesAvailabilityUnknown() async {
    let availability = await fetch {
      $0.paywallTargeting.paywallForKind = { .init(kind: $0, id: "offer") }
      $0.purchases.paywallByID = { _ in .failure(URLError(.notConnectedToInternet)) }
      $0.remoteSettings.boolForKey = { _ in nil }
      $0.remoteSettings.fetch = { _ in throw URLError(.notConnectedToInternet) }
      $0.remoteSettings.stringForKey = { _ in nil }
    }

    #expect(availability == OfferAvailability())
  }

  @Test func remoteSeasonalOfferReplacesTheLimitedTimeOne() async {
    let paywall = Paywall(
      id: "offer",
      products: [.mockYear],
      remoteConfigString: #"{"offer_end_date": "20261130"}"#
    )
    let availability = await fetch {
      $0.paywallTargeting.paywallForKind = { .init(kind: $0, id: "offer") }
      $0.purchases.paywallByID = { _ in .paywall(paywall) }
      $0.remoteSettings.boolForKey = { _ in nil }
      $0.remoteSettings.fetch = { _ in }
      $0.remoteSettings.stringForKey = { key in
        key == RemoteSettingsClient.paywallSpecialOfferKey ? "black_friday" : nil
      }
    }

    expectNoDifference(
      availability.special,
      .available(
        SpecialOffer(
          kind: .Offer.blackFriday,
          discount: Product.EligibleSubscriptionOffer.mock.discount,
          expiration: .at(paywall.offerEndDate!)
        )
      )
    )
  }

  @Test func offlineRefreshKeepsKnownAvailability() {
    let known = OfferAvailability(introductory: .available(.mock), special: .unavailable)
    var availability = known
    availability.merge(OfferAvailability())
    #expect(availability == known)
  }

  private func fetch(
    _ updateValues: (inout DependencyValues) -> Void
  ) async -> OfferAvailability {
    // The key reads its clients when it's created, so it's created here.
    let key = withDependencies(updateValues) { OfferAvailabilityKey() }
    return await key.fetch()
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
