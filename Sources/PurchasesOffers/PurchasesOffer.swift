import DuckPurchasesCore
import Foundation

/// An offer surfaced to a non-premium user through a banner and a dedicated
/// paywall.
///
/// Never stored: derive it with
/// ``OfferHistory/activeOffer(availability:isPremium:at:)`` whenever it's read,
/// so it can't outlive its end date or a remote kill-switch.
public enum PurchasesOffer: Equatable, Sendable {
  case introductory(Product.EligibleSubscriptionOffer)
  /// `endDate` is `nil` until the countdown of an offer that expires
  /// ``SpecialOffer/Expiration/afterFirstShown(_:)`` starts.
  case special(SpecialOffer, endDate: Date?)

  public var paywallKind: Paywall.Kind {
    switch self {
    case .introductory: .Offer.introductory
    case let .special(offer, _): offer.kind
    }
  }
}

/// The one limited-time or seasonal offer remote config runs at a time.
public struct SpecialOffer: Equatable, Sendable {
  public enum Expiration: Equatable, Sendable {
    /// Runs for a duration from the first time its paywall is shown, e.g. the
    /// limited-time offer.
    case afterFirstShown(TimeInterval)
    /// Ends at a fixed date, e.g. Black Friday.
    case at(Date)
  }

  public var kind: Paywall.Kind
  /// `nil` when the terms couldn't be fetched (e.g. offline): show no badge.
  public var discount: Decimal?
  public var expiration: Expiration

  public init(kind: Paywall.Kind, discount: Decimal?, expiration: Expiration) {
    self.kind = kind
    self.discount = discount
    self.expiration = expiration
  }
}
