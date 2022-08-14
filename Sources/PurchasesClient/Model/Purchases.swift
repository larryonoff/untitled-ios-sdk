import Adapty

public struct Purchases {
  public var isPremium: Bool = false
  public var isTrialAvailable: Bool = true
}

extension Purchases: Codable {}

extension Purchases: Equatable {}

extension Purchases: Hashable {}

extension Purchases: Sendable {}

extension Purchases {
  init(_ purchaserInfo: PurchaserInfoModel?) {
    guard
      let purchaserInfo = purchaserInfo,
      let accessLevel = purchaserInfo.accessLevels["premium"]
    else {
      self.isPremium = false
      self.isTrialAvailable = true
      return
    }

    let subscriptionsProductIDs = purchaserInfo.subscriptions
      .values
      .map(\.vendorProductId)

    self.isPremium = accessLevel.isActive
    self.isTrialAvailable = subscriptionsProductIDs.isEmpty
  }
}
