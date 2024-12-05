import ComposableArchitecture
import DuckAnalyticsClient
import DuckPurchases
import Foundation

extension AnalyticsClient {
  func logView(
    state: PaywallReducer.State
  ) -> Effect<PaywallReducer.Action> {
    var params: [AnalyticsClient.EventParameterName: Any] = [:]
    params[.contentID] = state.paywallID
    params[.placement] = state.placement

    let paywallID = state.paywallID

    return .run { [params] _ in
      log("paywall_\(paywallID)_view", parameters: params)
    }
  }

  func logPurchase(
    _ product: Product,
    state: PaywallReducer.State
  ) -> Effect<PaywallReducer.Action> {
    var params: [AnalyticsClient.EventParameterName: Any] = [:]
    params[.action] = "attempt"
    params[.contentID] = state.paywallID
    params["paywall_id"] = state.paywallID
    params[.placement] = state.placement

    params.insertOrUpdate(product)

    let paywallID = state.paywallID

    return .run { [params] _ in
      log(.productAction, parameters: params)
    }
  }

  func logPurchase<Success>(
    _ product: Product,
    result: Result<Success, any Error>,
    state: PaywallReducer.State
  ) -> Effect<PaywallReducer.Action> {
    var params: [AnalyticsClient.EventParameterName: Any] = [:]
    params["paywall_id"] = state.paywallID
    params[.placement] = state.placement

    params.insertOrUpdate(product)

    switch result {
    case .success:
      params[.action] = "success"
    case let .failure(error):
      params[.action] = "failure"

      let nsError = error as NSError
      params[.errorCode] = nsError.code
      params[.errorDomain] = nsError.domain
      params[.errorDescription] = nsError.localizedDescription
    }

    let paywallID = state.paywallID

    return .run { [params] _ in
      log(.productAction, parameters: params)
    }
  }
}

extension AnalyticsClient.EventName {
  static var productAction: Self { "product_action" }
}

