import Foundation
@_exported import Tagged

public struct Paywall {
  public typealias ID = Tagged<(Self, id: ()), String>
  public typealias PromoOfferType = Tagged<(Self, promoOffer: ()), String>
  public typealias VariantID = Tagged<(Self, variantID: ()), String>

  public let id: ID
  public var products: [Product]

  let remoteConfigString: String?

  public var remoteConfig: [String: Any]? {
    remoteConfigString?.data(using: .utf8).flatMap {
      try? JSONSerialization.jsonObject(with: $0, options: []) as? [String: Any]
    }
  }
}

extension Paywall.PromoOfferType {
  public static var blackFriday: Self { "bf" }
  public static var christmas: Self { "xmas" }
  public static var newYear: Self { "ny" }
}

extension Paywall: Equatable {}
extension Paywall: Hashable {}
extension Paywall: Identifiable {}
extension Paywall: Sendable {}
