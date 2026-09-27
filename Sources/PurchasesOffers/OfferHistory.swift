import DuckPurchasesCore
import Foundation
import Sharing

/// What has happened so far, as recorded by the paywall. Offers are derived
/// from it; it never stores an offer itself.
public struct OfferHistory: Equatable, Sendable {
  /// When each paywall kind was first dismissed. Offers become available
  /// once the main paywall has been.
  public private(set) var dismissalDates: [Paywall.Kind: Date] = [:]

  /// The countdown of each offer that runs for a fixed duration from the
  /// first time its paywall is shown. Captured at the start, so a later
  /// remote change can't stretch an offer that's already running.
  public private(set) var countdowns: [Paywall.Kind: DateInterval] = [:]

  public init() {}

  /// Records the first dismissal of a paywall kind; later ones are ignored.
  public mutating func recordDismissal(of kind: Paywall.Kind, at date: Date) {
    guard dismissalDates[kind] == nil else { return }
    dismissalDates[kind] = date
  }

  /// Starts the countdown of an offer the first time its paywall is shown;
  /// later calls, and a non-positive duration, are ignored.
  public mutating func startCountdown(
    for kind: Paywall.Kind,
    duration: TimeInterval,
    at date: Date
  ) {
    guard countdowns[kind] == nil, duration > 0 else { return }
    countdowns[kind] = DateInterval(start: date, duration: duration)
  }

  /// Ends a running countdown at `date`, as if it had run out, so the
  /// introductory offer can follow. Does nothing when the countdown hasn't
  /// started or has already ended.
  public mutating func expireCountdown(for kind: Paywall.Kind, at date: Date) {
    guard let countdown = countdowns[kind], date < countdown.end else { return }
    // `min`: a clock set back before the start would make an invalid interval.
    countdowns[kind] = DateInterval(start: min(countdown.start, date), end: date)
  }
}

extension OfferHistory: Codable {
  private enum CodingKeys: String, CodingKey {
    case countdowns
    case dismissalDates
  }

  // A missing key decodes as empty rather than failing, which would reset
  // the whole history when a field is added.
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    countdowns = try container.decodeIfPresent([Paywall.Kind: DateInterval].self, forKey: .countdowns) ?? [:]
    dismissalDates = try container.decodeIfPresent([Paywall.Kind: Date].self, forKey: .dismissalDates) ?? [:]
  }
}

extension SharedKey where Self == FileStorageKey<OfferHistory>.Default {
  public static var offerHistory: Self {
    Self[
      .fileStorage(
        .applicationSupportDirectory.appending(component: "PurchasesOffers_History.json")
      ),
      default: OfferHistory()
    ]
  }
}
