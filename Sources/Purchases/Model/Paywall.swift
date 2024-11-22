import Foundation
@_exported import Tagged

public struct Paywall {
  public typealias ID = Tagged<(Self, id: ()), String>
  public typealias RemoteConfig = [String: Any]
  public typealias SpecialOfferType = Tagged<(Self, promoOffer: ()), String>
  public typealias VariantID = Tagged<(Self, variantID: ()), String>

  public let id: ID
  public var products: [Product]

  let remoteConfigString: String?

  public var remoteConfig: RemoteConfig? {
    remoteConfigString?.data(using: .utf8).flatMap {
      try? JSONSerialization.jsonObject(with: $0, options: []) as? [String: Any]
    }
  }
}

extension Paywall.SpecialOfferType {
  public static var blackFriday: Self { "black_friday" }
  public static var christmas: Self { "xmas" }
  public static var cyberMonday: Self { "cyber_monday" }
  public static var newYear: Self { "new_year" }
  public static var winterSale: Self { "winter_sale" }
}

extension Paywall: Equatable {}
extension Paywall: Hashable {}
extension Paywall: Identifiable {}
extension Paywall: Sendable {}
