import Foundation

extension Paywall {
  /// Offers the user is eligible for, introductory first, otherwise in
  /// product order.
  public var eligibleOffers: [Product.EligibleSubscriptionOffer] {
    let offers = products.compactMap(\.eligibleOffer)
    return offers.filter { $0.offer.type == .introductory }
      + offers.filter { $0.offer.type != .introductory }
  }
}

extension Product {
  public struct EligibleSubscriptionOffer {
    public let product: Product
    public let offer: Product.SubscriptionOffer

    public var discount: Decimal? {
      offer.discount(comparingTo: product)
    }
  }

  public var eligibleOffer: EligibleSubscriptionOffer? {
    subscriptionOffer.flatMap {
      EligibleSubscriptionOffer(product: self, offer: $0)
    }
  }
}

extension Product.EligibleSubscriptionOffer: Equatable {}
extension Product.EligibleSubscriptionOffer: Hashable {}
extension Product.EligibleSubscriptionOffer: Sendable {}
