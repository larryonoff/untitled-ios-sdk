import Foundation

public struct Purchases {
  public var isEligibleForIntroductoryOffer: Bool = true
  public var isPremium: Bool = false

  public init(
    isPremium: Bool = false,
    isEligibleForIntroductoryOffer: Bool = true
  ) {
    self.isPremium = isPremium
    self.isEligibleForIntroductoryOffer = isEligibleForIntroductoryOffer
  }
}

extension Purchases: Codable {}
extension Purchases: Equatable {}
extension Purchases: Hashable {}
extension Purchases: Sendable {}
