import DuckAnalyticsClient
import Foundation

extension AnalyticsClient.UserPropertyName {
  public static var isPremium: Self { "is_premium" }
}

extension Dictionary<AnalyticsClient.EventParameterName, Any> {
  mutating
  public func insertOrUpdate(_ product: Product) {
    var params: [AnalyticsClient.EventParameterName: Any] = [:]
    params[.contentID] = product.id

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
