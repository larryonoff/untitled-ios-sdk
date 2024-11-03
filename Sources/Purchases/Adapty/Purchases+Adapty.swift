import Adapty
import Foundation

package extension Purchases {
  init(_ profile: AdaptyProfile?) {
    guard
      let profile,
      let accessLevel = profile.accessLevels["premium"]
    else {
      self.init(
        isPremium: false,
        isEligibleForIntroductoryOffer: true
      )
      return
    }

    let subscriptionsProductIDs = profile.subscriptions
      .values
      .map(\.vendorProductId)

    self.init(
      isPremium: accessLevel.isActive,
      isEligibleForIntroductoryOffer: subscriptionsProductIDs.isEmpty
    )
  }
}

package extension Purchases {
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
  static var purchaserInfoKey: Self { "AdaptySDK_Purchaser_Info" }
}
