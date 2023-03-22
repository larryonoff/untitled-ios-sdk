import AnalyticsClient
import Foundation

extension Analytics.EventName {
  public static let subscriptionFailed: Self = "sub_failed"
  public static let subscriptionPurchased: Self = "sub_purchased"
}

extension Analytics.ParameterName {
  public static let subscriptionPeriod: Self = "subs_period"
  public static let subscriptionTrialPeriod: Self = "subs_trial_period"
}

extension Analytics.UserPropertyName {
  public static let isPremium: Self = "is_premium"
}

extension Product {
  var analyticsParameters: [Analytics.ParameterName: Any] {
    var parameters: [Analytics.ParameterName: Any] = [:]
    parameters[.subscriptionPeriod] = subscription?
      .subscriptionPeriod
      .analyticsValue

    if
      let introductoryOffer = subscription?.introductoryOffer,
      introductoryOffer.paymentMode == .freeTrial
    {
      parameters[.subscriptionTrialPeriod] =
        introductoryOffer.period.analyticsValue
    }

    return parameters
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

extension Analytics {
  func logPurchase(
    _ request: PurchaseRequest
  ) {

    log(
      .event(
        eventName: .subscriptionPurchased,
        parameters: request.product.analyticsParameters
      )
    )
  }

  func logPurchaseFailed(
    with error: Error,
    request: PurchaseRequest
  ) {
    let nsError = error as NSError

    var parameters: [ParameterName: Any] = [
      .errorCode: nsError.code,
      .errorDomain: nsError.domain,
      .errorDescription: nsError.localizedDescription
    ]

    parameters.merge(
      request.product.analyticsParameters,
      uniquingKeysWith: { (_, new) in new }
    )

    log(
      .event(
        eventName: .subscriptionFailed,
        parameters: parameters
      )
    )
  }
}
