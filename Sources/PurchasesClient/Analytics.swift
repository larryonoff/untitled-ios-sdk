import DuckAnalyticsClient
import Foundation

extension AnalyticsClient.UserPropertyName {
  public static var isPremium: Self { "is_premium" }
}

extension Dictionary<AnalyticsClient.EventParameterName, any Sendable> {
  mutating
  public func insertOrUpdate(_ product: Product) {
    var params: [AnalyticsClient.EventParameterName: any Sendable] = [:]
    params[.contentID] = product.id
    params["currency"] = product.priceLocale.currency?.identifier
    params["offer_type"] = product.subscriptionOffer.analyticsValue
    params["price"] = product.price

    // What the user pays first when an offer applies, e.g. 0 for a free trial.
    if let offer = product.subscriptionOffer {
      params["offer_price"] = offer.price
    }

    if
      let subscription = product.subscription
    {
      params["subs_period"] = subscription.subscriptionPeriod.analyticsValue
      params["subs_period_unit"] = subscription.subscriptionPeriod.unit.analyticsValue

      if let introductoryOffer = subscription.introductoryOffer {
        params["subs_intro_offer_type"] = introductoryOffer.type.rawValue
        params["subs_intro_offer_payment_mode"] = introductoryOffer.paymentMode.rawValue
      }
    }

    merge(params) { (_, new) in new }
  }
}

extension Optional<Product.SubscriptionOffer> {
  /// The offer the purchase applies, as the `offer_type` parameter.
  var analyticsValue: String {
    guard let self else { return "none" }
    if self.isIntroductoryFreeTrial { return "free_trial" }

    return switch self.type {
    case .promotional: "promo"
    default: self.type.rawValue
    }
  }
}

extension Product.SubscriptionPeriod.Unit {
  public var analyticsValue: String {
    description
  }
}

extension Product.SubscriptionPeriod {
  public var analyticsValue: String {
    switch unit {
    case .week where value == 1:
      let period = Product.SubscriptionPeriod(
        unit: .day,
        value: 7
      )
      return period.analyticsValue
    default:
      return "\(value)_\(unit.analyticsValue)"
    }
  }
}
