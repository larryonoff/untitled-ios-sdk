import ComposableArchitecture
import DuckAnalyticsClient
import DuckDependencies
import DuckPurchases
import Foundation
#if os(iOS)
import UIKit
#endif

extension AnalyticsClient {
  /// Logged once the paywall has products, so the event can say which it shows.
  func logView<Action>(
    state: PaywallReducer.State
  ) -> Effect<Action> {
    var params: [AnalyticsClient.EventParameterName: any Sendable] = [:]
    params[.contentID] = state.target.id
    params[.introOfferShown] = state.products.contains {
      $0.subscriptionOffer?.type == .introductory
    }
    params[.paywallID] = state.target.id
    params[.placement] = state.placement
    params[.productsShown] = state.products.map(\.id.rawValue).joined(separator: ",")
    params.insertOrUpdate(state.devicePosture)

    let paywallID = state.target.id

    return .run { [params] _ in
      log("paywall_\(paywallID)_view", parameters: params)
    }
  }

  /// The paywall closes without a purchase.
  func logClose<Action>(
    _ action: PaywallAction,
    state: PaywallReducer.State,
    now: Date
  ) -> Effect<Action> {
    var params: [AnalyticsClient.EventParameterName: any Sendable] = [:]
    params[.action] = action.rawValue
    params[.paywallID] = state.target.id
    params[.placement] = state.placement
    params[.secondsOnScreen] = state.viewedAt.map {
      Int(now.timeIntervalSince($0).rounded())
    }
    params.insertOrUpdate(state.devicePosture)

    let paywallID = state.target.id

    return .run { [params] _ in
      log("paywall_\(paywallID)_action", parameters: params)
    }
  }

  func logProductSelect<Action>(
    _ product: Product,
    state: PaywallReducer.State
  ) -> Effect<Action> {
    var params: [AnalyticsClient.EventParameterName: any Sendable] = [:]
    params[.action] = PaywallAction.productSelect.rawValue
    params[.contentID] = product.id
    params[.paywallID] = state.target.id
    params[.placement] = state.placement
    params.insertOrUpdate(state.devicePosture)

    let paywallID = state.target.id

    return .run { [params] _ in
      log("paywall_\(paywallID)_action", parameters: params)
    }
  }

  func logPurchase<Action>(
    _ action: ProductAction,
    product: Product,
    paywallID: Paywall.ID,
    placement: Placement?,
    devicePosture: DevicePosture,
    error: (any Error)? = nil
  ) -> Effect<Action> {
    var params: [AnalyticsClient.EventParameterName: any Sendable] = [:]
    params[.action] = action.rawValue
    params[.paywallID] = paywallID
    params[.placement] = placement
    params.insertOrUpdate(product)
    params.insertOrUpdate(error)
    params.insertOrUpdate(devicePosture)

    return .run { [params] _ in
      log(.productAction, parameters: params)
    }
  }

  func logRestore<Action>(
    _ action: RestoreAction,
    paywallID: Paywall.ID,
    placement: Placement?,
    devicePosture: DevicePosture,
    error: (any Error)? = nil
  ) -> Effect<Action> {
    var params: [AnalyticsClient.EventParameterName: any Sendable] = [:]
    params[.action] = action.rawValue
    params[.paywallID] = paywallID
    params[.placement] = placement
    params.insertOrUpdate(error)
    params.insertOrUpdate(devicePosture)

    return .run { [params] _ in
      log(.restoreAction, parameters: params)
    }
  }
}

enum PaywallAction: String {
  case closeButton = "close_button"
  case introOfferDeclined = "intro_offer_declined"
  case productSelect = "product_select"
  case restore
}

enum ProductAction: String {
  case attempt
  case cancelled
  case failure
  case pending
  case success
}

enum RestoreAction: String {
  case attempt
  case cancelled
  case failure
  case nothingToRestore = "nothing_to_restore"
  case success
}

extension RestoreAction {
  init(_ result: RestorePurchasesResult) {
    switch result {
    case let .success(purchases):
      self = purchases.isPremium ? .success : .nothingToRestore
    case .userCancelled:
      self = .cancelled
    }
  }
}

private extension Dictionary<AnalyticsClient.EventParameterName, any Sendable> {
  mutating func insertOrUpdate(_ error: (any Error)?) {
    guard let error else { return }

    let nsError = error as NSError
    self[.errorCode] = nsError.code
    self[.errorDomain] = nsError.domain
    self[.errorDescription] = nsError.localizedDescription
  }

  mutating func insertOrUpdate(_ posture: DevicePosture) {
    #if os(iOS)
    self[.hingeStatus] = posture.hingeStatus?.analyticsValue ?? "none"
    self[.interfaceOrientation] = posture.interfaceOrientation.analyticsValue
    #endif
  }
}

/// How the device was held when an event happened, so paywall conversion can be split by it.
struct DevicePosture: Equatable, Sendable {
  #if os(iOS)
  var hingeStatus: HingeStatus?
  var interfaceOrientation: UIInterfaceOrientation
  #endif
}

#if os(iOS)
private extension HingeStatus {
  var analyticsValue: String {
    switch self {
    case .unknown: "unknown"
    case .closed: "closed"
    case .partiallyOpen: "partially_open"
    case .fullyOpen: "fully_open"
    }
  }
}

private extension UIInterfaceOrientation {
  var analyticsValue: String {
    switch self {
    case .portrait: "portrait"
    case .portraitUpsideDown: "portrait_upside_down"
    case .landscapeLeft: "landscape_left"
    case .landscapeRight: "landscape_right"
    default: "unknown"
    }
  }
}
#endif

extension AnalyticsClient.EventName {
  static let productAction: Self = "product_action"
  static let restoreAction: Self = "restore_action"
}

extension AnalyticsClient.EventParameterName {
  static let hingeStatus: Self = "hinge_status"
  static let interfaceOrientation: Self = "interface_orientation"
  static let introOfferShown: Self = "intro_offer_shown"
  static let paywallID: Self = "paywall_id"
  static let productsShown: Self = "products_shown"
  static let secondsOnScreen: Self = "seconds_on_screen"
}
