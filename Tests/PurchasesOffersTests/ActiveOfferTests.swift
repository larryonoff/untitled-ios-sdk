import CustomDump
@testable import DuckPurchasesCore
import DuckPurchasesOffers
import Foundation
import Testing

struct ActiveOfferTests {
  let now = Date(timeIntervalSinceReferenceDate: 1_000_000)
  let limitedTime = SpecialOffer(kind: .Offer.limitedTime, discount: 0.5, expiration: .afterFirstShown(3_600))

  @Test func premiumGetsNoOffer() {
    let availability = OfferAvailability(introductory: .available(.mock), special: .available(limitedTime))

    #expect(OfferHistory.mainDismissed.activeOffer(availability: availability, isPremium: true, at: now) == nil)
  }

  @Test func nothingBeforeTheMainPaywallIsDismissed() {
    let availability = OfferAvailability(introductory: .available(.mock), special: .available(limitedTime))

    #expect(OfferHistory().activeOffer(availability: availability, isPremium: false, at: now) == nil)
  }

  @Test func limitedTimeWaitsForItsPaywallToStart() {
    let availability = OfferAvailability(special: .available(limitedTime))

    expectNoDifference(
      OfferHistory.mainDismissed.activeOffer(availability: availability, isPremium: false, at: now),
      .special(limitedTime, endDate: nil)
    )
  }

  @Test func introductoryFollowsWhenThereIsNoSpecialOffer() {
    let availability = OfferAvailability(introductory: .available(.mock), special: .unavailable)

    expectNoDifference(
      OfferHistory.mainDismissed.activeOffer(availability: availability, isPremium: false, at: now),
      .introductory(.mock)
    )
  }

  @Test func nothingNewWhileOffline() {
    #expect(
      OfferHistory.mainDismissed.activeOffer(availability: OfferAvailability(), isPremium: false, at: now) == nil
    )
  }

  @Test func expiredLimitedTimeGivesWayToIntroductory() {
    var history = OfferHistory.started(at: now.addingTimeInterval(-60), duration: 600)
    history.expireCountdown(for: .Offer.limitedTime, at: now)
    let availability = OfferAvailability(introductory: .available(.mock), special: .available(limitedTime))

    expectNoDifference(
      history.activeOffer(availability: availability, isPremium: false, at: now),
      .introductory(.mock)
    )
  }

  @Test func runningLimitedTimeKeepsItsCapturedEnd() {
    let history = OfferHistory.started(at: now.addingTimeInterval(-60), duration: 600)
    // Remote config has since changed the duration; the running offer keeps its own.
    let availability = OfferAvailability(special: .available(limitedTime))

    expectNoDifference(
      history.activeOffer(availability: availability, isPremium: false, at: now),
      .special(limitedTime, endDate: now.addingTimeInterval(540))
    )
  }

  @Test func runningLimitedTimeSurvivesOfflineWithoutDiscount() {
    let history = OfferHistory.started(at: now.addingTimeInterval(-60), duration: 600)

    expectNoDifference(
      history.activeOffer(availability: OfferAvailability(), isPremium: false, at: now),
      .special(
        SpecialOffer(kind: .Offer.limitedTime, discount: nil, expiration: .afterFirstShown(600)),
        endDate: now.addingTimeInterval(540)
      )
    )
  }

  @Test func killSwitchStopsARunningLimitedTimeOffer() {
    let history = OfferHistory.started(at: now.addingTimeInterval(-60), duration: 600)
    let availability = OfferAvailability(introductory: .unavailable, special: .unavailable)

    #expect(history.activeOffer(availability: availability, isPremium: false, at: now) == nil)
  }

  @Test func introductoryFollowsAnExpiredLimitedTimeOffer() {
    let history = OfferHistory.started(at: now.addingTimeInterval(-600), duration: 600)
    let availability = OfferAvailability(introductory: .available(.mock), special: .available(limitedTime))

    expectNoDifference(
      history.activeOffer(availability: availability, isPremium: false, at: now),
      .introductory(.mock)
    )
  }

  @Test func expiredLimitedTimeNeverComesBack() {
    let history = OfferHistory.started(at: now.addingTimeInterval(-600), duration: 600)
    // A user who already used the trial: Adapty attaches no introductory offer.
    let availability = OfferAvailability(introductory: .unavailable, special: .available(limitedTime))

    #expect(history.activeOffer(availability: availability, isPremium: false, at: now) == nil)
  }

  @Test func relaunchAfterExpiryShowsNothingStale() {
    let history = OfferHistory.started(at: now.addingTimeInterval(-3_600), duration: 600)

    #expect(history.activeOffer(availability: OfferAvailability(), isPremium: false, at: now) == nil)
  }

  @Test func clockSetBackEndsARunningOffer() {
    let history = OfferHistory.started(at: now.addingTimeInterval(60), duration: 600)
    let availability = OfferAvailability(introductory: .available(.mock), special: .available(limitedTime))

    expectNoDifference(
      history.activeOffer(availability: availability, isPremium: false, at: now),
      .introductory(.mock)
    )
  }

  @Test func seasonalRunsUntilItsEndDate() {
    let blackFriday = SpecialOffer(kind: .Offer.blackFriday, discount: 0.3, expiration: .at(now.addingTimeInterval(60)))
    let availability = OfferAvailability(introductory: .available(.mock), special: .available(blackFriday))

    expectNoDifference(
      OfferHistory.mainDismissed.activeOffer(availability: availability, isPremium: false, at: now),
      .special(blackFriday, endDate: now.addingTimeInterval(60))
    )
    expectNoDifference(
      OfferHistory.mainDismissed.activeOffer(availability: availability, isPremium: false, at: now.addingTimeInterval(60)),
      .introductory(.mock)
    )
  }

  @Test func seasonalWaitsForTheMainPaywallToBeDismissed() {
    let blackFriday = SpecialOffer(kind: .Offer.blackFriday, discount: 0.3, expiration: .at(now.addingTimeInterval(60)))

    #expect(
      OfferHistory().activeOffer(
        availability: OfferAvailability(special: .available(blackFriday)),
        isPremium: false,
        at: now
      ) == nil
    )
  }

  @Test func historyRecordsOnlyTheFirstOfEach() {
    var history = OfferHistory()
    history.recordDismissal(of: .main, at: now)
    history.recordDismissal(of: .main, at: now.addingTimeInterval(1))
    history.startCountdown(for: .Offer.limitedTime, duration: 0, at: now)
    history.startCountdown(for: .Offer.limitedTime, duration: 600, at: now)
    history.startCountdown(for: .Offer.limitedTime, duration: 60, at: now.addingTimeInterval(1))

    #expect(history.dismissalDates == [.main: now])
    #expect(history.countdowns == [.Offer.limitedTime: DateInterval(start: now, duration: 600)])
  }

  @Test func historyDecodesMissingFieldsAsEmpty() throws {
    let history = try JSONDecoder().decode(OfferHistory.self, from: Data("{}".utf8))
    #expect(history == OfferHistory())
  }

  @Test func historyRoundTripsThroughJSON() throws {
    let history = OfferHistory.started(at: now, duration: 600)
    let data = try JSONEncoder().encode(history)
    #expect(try JSONDecoder().decode(OfferHistory.self, from: data) == history)
  }
}

private extension OfferHistory {
  static var mainDismissed: Self {
    var history = OfferHistory()
    history.recordDismissal(of: .main, at: Date(timeIntervalSinceReferenceDate: 0))
    return history
  }

  static func started(at startDate: Date, duration: TimeInterval) -> Self {
    var history = mainDismissed
    history.startCountdown(for: .Offer.limitedTime, duration: duration, at: startDate)
    return history
  }
}

extension Product.EligibleSubscriptionOffer {
  static let mock = Product.EligibleSubscriptionOffer(
    product: .mockYear,
    offer: .init(
      id: "year-intro-offer",
      type: .introductory,
      price: 0,
      displayPrice: "0",
      period: .day(3),
      periodCount: 1,
      paymentMode: .freeTrial
    )
  )
}
