import Foundation

extension Paywall {
  public func eligibleOffers(
    for purchases: Purchases
  ) -> [Product.EligibleSubscriptionOffer] {
    products
      .compactMap { $0.eligibleOffer(for: purchases) }
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

  public func eligibleOffer(for purchases: Purchases) -> EligibleSubscriptionOffer? {
    if purchases.isEligibleForIntroductoryOffer {
      return subscription
        .flatMap { $0.introductoryOffer }
        .flatMap { EligibleSubscriptionOffer(product: self, offer: $0) }
    }

    return promoOffer.flatMap {
      EligibleSubscriptionOffer(product: self, offer: $0)
    }
  }
}
