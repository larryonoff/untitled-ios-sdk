import DuckAnalyticsClient
import Foundation

extension AnalyticsClient.EventName {
  public static let subscriptionFailed: Self = "sub_failed"
  public static let subscriptionPurchased: Self = "sub_purchased"
}

extension AnalyticsClient.EventParameterName {
  public static let subscriptionPeriod: Self = "subs_period"
  public static let subscriptionTrialPeriod: Self = "subs_trial_period"
}

extension AnalyticsClient.UserPropertyName {
  public static let isPremium: Self = "is_premium"
}

extension Product {
  var analyticsParameters: [AnalyticsClient.EventParameterName: Any] {
    var parameters: [AnalyticsClient.EventParameterName: Any] = [:]
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

extension AnalyticsClient {
  func logPurchase(
    _ request: PurchaseRequest
  ) {

    log(
      .subscriptionPurchased,
      parameters: request.product.analyticsParameters
    )
  }

  func logPurchaseFailed(
    with error: Error,
    request: PurchaseRequest
  ) {
    let nsError = error as NSError

    var parameters: [EventParameterName: Any] = [
      .errorCode: nsError.code,
      .errorDomain: nsError.domain,
      .errorDescription: nsError.localizedDescription
    ]

    parameters.merge(
      request.product.analyticsParameters,
      uniquingKeysWith: { (_, new) in new }
    )

    log(
      .subscriptionFailed,
      parameters: parameters
    )
  }
}
