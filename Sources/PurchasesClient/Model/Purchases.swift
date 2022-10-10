import Adapty
import Foundation

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

extension Purchases {
  /// This's workaround function
  ///
  /// PurchaserInfo is loaded directly from user defaults,
  /// since Adapty SDK doesn't have public option for
  ///
  /// Purchaser info is not up-to-date,
  /// when internet connection is not available,
  /// so it's important to load previous values
  static func load() -> Purchases {
    let purchaserInfo = UserDefaults.standard
      .object(forKey: .purchaserInfoKey)
      .flatMap { $0 as? Data }
      .flatMap { try? JSONDecoder().decode(PurchaserInfoModel.self, from: $0) }

    return Purchases(purchaserInfo)
  }
}

extension String {
  static let purchaserInfoKey: Self = "AdaptySDK_Purchaser_Info"
}
