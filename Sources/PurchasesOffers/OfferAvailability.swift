import DuckPurchasesCore
import Foundation
import Sharing

/// What remote config and the purchases provider make available in this
/// session. Written only by ``PurchasesOffers``.
public struct OfferAvailability: Equatable, Sendable {
  public enum Status<Value: Equatable & Sendable>: Equatable, Sendable {
    /// Not fetched yet, or the fetch failed (e.g. offline).
    case unknown
    /// Remotely disabled, or the user isn't eligible.
    case unavailable
    case available(Value)
  }

  public var introductory: Status<Product.EligibleSubscriptionOffer>
  public var special: Status<SpecialOffer>

  public init(
    introductory: Status<Product.EligibleSubscriptionOffer> = .unknown,
    special: Status<SpecialOffer> = .unknown
  ) {
    self.introductory = introductory
    self.special = special
  }

  /// Takes the newer statuses, keeping a known one where the newer is
  /// `.unknown`, so an offline refresh doesn't drop a running offer's badge.
  mutating func merge(_ newer: Self) {
    if newer.introductory != .unknown { introductory = newer.introductory }
    if newer.special != .unknown { special = newer.special }
  }
}

extension SharedKey where Self == InMemoryKey<OfferAvailability>.Default {
  public static var offerAvailability: Self {
    Self[.inMemory("PurchasesOffers_Availability"), default: OfferAvailability()]
  }
}
