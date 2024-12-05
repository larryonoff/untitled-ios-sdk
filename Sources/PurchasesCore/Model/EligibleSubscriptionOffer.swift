import Foundation

extension Paywall {
  public var eligibleOffers: [Product.EligibleSubscriptionOffer] {
    products
      .compactMap { $0.eligibleOffer }
      .sorted { lhs, rhs in
        if lhs.offer.type == .introductory { return true }
        if rhs.offer.type == .introductory { return false }
        return false
      }
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
