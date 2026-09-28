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

  @Test func firstOfferIsTheLimitedTimeOneEvenDuringASeason() async {
    let seasonal = Paywall(
      id: "seasonal",
      products: [.mockYear],
      remoteConfigString: #"{"offer_end_date": "20261130"}"#
    )
    let limitedTime = Paywall(
      id: "lto",
      products: [.mockYear],
      remoteConfigString: #"{"offer_duration": 3600}"#
    )
    let availability = await fetch {
      $0.date.now = seasonal.offerEndDate!.addingTimeInterval(-1)
      $0.paywallTargeting.paywallForKind = { .init(kind: $0, id: $0 == .Offer.limitedTime ? "lto" : "seasonal") }
      $0.purchases.paywallByID = { .paywall($0 == "lto" ? limitedTime : seasonal) }
      $0.remoteSettings.boolForKey = { _ in nil }
      $0.remoteSettings.fetch = { _ in }
      $0.remoteSettings.stringForKey = { key in
        key == RemoteSettingsClient.paywallSpecialOfferKey ? "black_friday" : nil
      }
    }

    #expect(availability.special.kind == .Offer.limitedTime)
  }

  @Test func runningLimitedTimeOfferKeepsItsPlaceWhenASeasonStarts() async {
    let seasonal = Paywall(
      id: "seasonal",
      products: [.mockYear],
      remoteConfigString: #"{"offer_end_date": "20261130"}"#
    )
    let limitedTime = Paywall(
      id: "lto",
      products: [.mockYear],
      remoteConfigString: #"{"offer_duration": 3600}"#
    )
    let now = seasonal.offerEndDate!.addingTimeInterval(-1)
    var history = OfferHistory()
    history.startCountdown(for: .Offer.limitedTime, duration: 3_600, at: now.addingTimeInterval(-60))

    let availability = await fetch(history: history) {
      $0.date.now = now
      $0.paywallTargeting.paywallForKind = { .init(kind: $0, id: $0 == .Offer.limitedTime ? "lto" : "seasonal") }
      $0.purchases.paywallByID = { .paywall($0 == "lto" ? limitedTime : seasonal) }
      $0.remoteSettings.boolForKey = { _ in nil }
      $0.remoteSettings.fetch = { _ in }
      $0.remoteSettings.stringForKey = { key in
        key == RemoteSettingsClient.paywallSpecialOfferKey ? "black_friday" : nil
      }
    }

    #expect(availability.special.kind == .Offer.limitedTime)
  }

  @Test func switchedOffLimitedTimeOfferLeavesTheFirstOfferToTheSeason() async {
    let seasonal = Paywall(
      id: "seasonal",
      products: [.mockYear],
      remoteConfigString: #"{"offer_end_date": "20261130"}"#
    )
    let availability = await fetch {
      $0.date.now = seasonal.offerEndDate!.addingTimeInterval(-1)
      $0.paywallTargeting.paywallForKind = { .init(kind: $0, id: "seasonal") }
      $0.purchases.paywallByID = { _ in .paywall(seasonal) }
      $0.remoteSettings.boolForKey = { key in
        key == RemoteSettingsClient.isLimitedTimeOfferEnabledKey ? false : nil
      }
      $0.remoteSettings.fetch = { _ in }
      $0.remoteSettings.stringForKey = { key in
        key == RemoteSettingsClient.paywallSpecialOfferKey ? "black_friday" : nil
      }
    }

    #expect(availability.special.kind == .Offer.blackFriday)
  }

  @Test func remoteSeasonalOfferReplacesTheLimitedTimeOne() async {

    let paywall = Paywall(
      id: "offer",
      products: [.mockYear],
      remoteConfigString: #"{"offer_end_date": "20261130"}"#
    )
    let availability = await fetch(history: .afterAnOffer) {
      $0.date.now = paywall.offerEndDate!.addingTimeInterval(-1)
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

  @Test func endedSeasonalOfferFallsBackToTheLimitedTimeOne() async {
    let seasonal = Paywall(
      id: "seasonal",
      products: [.mockYear],
      remoteConfigString: #"{"offer_end_date": "20241209"}"#
    )
    let limitedTime = Paywall(
      id: "lto",
      products: [.mockYear],
      remoteConfigString: #"{"offer_duration": 3600}"#
    )
    let availability = await fetch(history: .afterAnOffer) {
      $0.date.now = seasonal.offerEndDate!.addingTimeInterval(1)
      $0.paywallTargeting.paywallForKind = { .init(kind: $0, id: $0 == .Offer.limitedTime ? "lto" : "seasonal") }
      $0.purchases.paywallByID = { .paywall($0 == "lto" ? limitedTime : seasonal) }
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
          kind: .Offer.limitedTime,
          discount: Product.EligibleSubscriptionOffer.mock.discount,
          expiration: .afterFirstShown(3_600)
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
    history: OfferHistory = OfferHistory(),
    _ updateValues: (inout DependencyValues) -> Void
  ) async -> OfferAvailability {
    // The key reads its clients when it's created, so it's created here.
    let key = withDependencies(updateValues) { OfferAvailabilityKey() }
    return await key.fetch(history: history)
  }
}

private extension OfferHistory {
  /// A user who has already been shown an offer.
  static var afterAnOffer: Self {
    var history = OfferHistory()
    history.recordDismissal(of: .Offer.limitedTime, at: .distantPast)
    return history
  }
}

private extension OfferAvailability.Status<SpecialOffer> {
  var kind: Paywall.Kind? {
    guard case let .available(offer) = self else { return nil }
    return offer.kind
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
