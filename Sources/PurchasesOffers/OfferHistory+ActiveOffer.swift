import DuckPurchasesCore
import Foundation

extension OfferHistory {
  /// The offer to show at `now`, or `nil`.
  ///
  /// Nothing shows before the main paywall is dismissed. The special offer
  /// comes first and runs once; the introductory offer follows once it has
  /// ended, or straight away when there's no special offer.
  public func activeOffer(
    availability: OfferAvailability,
    isPremium: Bool,
    at now: Date
  ) -> PurchasesOffer? {
    guard !isPremium, dismissalDates[.main] != nil else { return nil }

    switch availability.special {
    case let .available(offer):
      switch offer.expiration {
      case let .at(endDate):
        if now < endDate { return .special(offer, endDate: endDate) }
      case .afterFirstShown:
        guard let countdown = countdowns[offer.kind] else {
          return .special(offer, endDate: nil)
        }
        // A clock set back before the start counts as ended too.
        if countdown.isRunning(at: now) { return .special(offer, endDate: countdown.end) }
      }

    case .unknown:
      // Offline: keep a running countdown; the discount is unknown.
      if let running = countdowns.first(where: { $0.value.isRunning(at: now) }) {
        return .special(
          SpecialOffer(kind: running.key, discount: nil, expiration: .afterFirstShown(running.value.duration)),
          endDate: running.value.end
        )
      }
      // Whether a special offer comes first isn't known yet.
      if countdowns.isEmpty { return nil }

    case .unavailable:
      // Remote kill-switch: stop a running offer now.
      break
    }

    guard case let .available(offer) = availability.introductory else { return nil }
    return .introductory(offer)
  }
}

private extension DateInterval {
  /// Half-open, unlike `contains(_:)`: an offer has ended at its end date.
  func isRunning(at date: Date) -> Bool {
    start <= date && date < end
  }
}
