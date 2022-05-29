import Analytics

extension Analytics.EventName {
  public static let subscriptionFailed: Self = "sub_failed"
  public static let subscriptionPurchased: Self = "sub_purchased"
}

extension Analytics.ParameterName {
  public static let subscriptionPeriod: Self = "subs_period"
}

extension Analytics.UserPropertyName {
  public static let isPremium: Self = "is_premium"
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
