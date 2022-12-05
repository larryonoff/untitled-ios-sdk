import Adapty
import Foundation

public struct Purchases {
  public var isEligibleForIntroductoryOffer: Bool = true
  public var isPremium: Bool = false
}

extension Purchases: Codable {}

extension Purchases: Equatable {}

extension Purchases: Hashable {}

extension Purchases: Sendable {}

extension Purchases {
  init(_ purchaserInfo: AdaptyProfile?) {
    guard
      let purchaserInfo = purchaserInfo,
      let accessLevel = purchaserInfo.accessLevels["premium"]
    else {
      self.isEligibleForIntroductoryOffer = true
      self.isPremium = false
      return
    }

    let subscriptionsProductIDs = purchaserInfo.subscriptions
      .values
      .map(\.vendorProductId)

    self.isEligibleForIntroductoryOffer = subscriptionsProductIDs.isEmpty
    self.isPremium = accessLevel.isActive
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
    let profile = UserDefaults.standard
      .object(forKey: .purchaserInfoKey)
      .flatMap { $0 as? Data }
      .flatMap { try? JSONDecoder().decode(AdaptyProfile.self, from: $0) }

    return Purchases(profile)
  }
}

extension String {
  static let purchaserInfoKey: Self = "AdaptySDK_Purchaser_Info"
}
