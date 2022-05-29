import Adapty

public struct Purchases: Codable, Equatable, Hashable {
  public var isPremium: Bool = false
  public var isTrialAvailable: Bool = true
}

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
