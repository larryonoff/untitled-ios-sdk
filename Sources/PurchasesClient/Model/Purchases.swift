import Adapty
import Foundation

public struct Purchases {
  public var isEligibleForIntroductoryOffer: Bool = true
  public var isPremium: Bool = false

  public init(
    isPremium: Bool = false
  ) {
    self.isPremium = isPremium
  }
}

extension Purchases: Codable {}
extension Purchases: Equatable {}
extension Purchases: Hashable {}
extension Purchases: Sendable {}

extension Purchases {
  init(_ profile: AdaptyProfile?) {
    guard
      let profile,
      let accessLevel = profile.accessLevels["premium"]
    else {
      self.isEligibleForIntroductoryOffer = true
      self.isPremium = false
      return
    }

    let subscriptionsProductIDs = profile.subscriptions
      .values
      .map(\.vendorProductId)

    self.isEligibleForIntroductoryOffer = subscriptionsProductIDs.isEmpty
    self.isPremium = accessLevel.isActive
  }
}

extension Purchases {
  private struct VH<T: Codable>: Codable {
    let value: T
    let hash: String?

    init(_ value: T, hash: String?) {
      self.value = value
      self.hash = hash
    }

    enum CodingKeys: String, CodingKey {
      case value = "v"
      case hash = "h"
    }
  }

  /// This's workaround function
  ///
  /// PurchaserInfo is loaded directly from user defaults,
  /// since Adapty SDK doesn't have public option for
  ///
  /// Purchaser info is not up-to-date,
  /// when internet connection is not available,
  /// so it's important to load previous values
  static func load() -> Purchases {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(formatter)
    decoder.dataDecodingStrategy = .base64

    let profile = UserDefaults.standard
      .object(forKey: .purchaserInfoKey)
      .flatMap { $0 as? Data }
      .flatMap { try? decoder.decode(VH<AdaptyProfile>.self, from: $0) }

    return Purchases(profile?.value)
  }
}

extension String {
  static let purchaserInfoKey: Self = "AdaptySDK_Purchaser_Info"
}
