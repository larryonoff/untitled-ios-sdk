import Foundation
@_exported import Tagged

public struct Paywall {
  public typealias ID = Tagged<(Self, id: ()), String>
  public typealias PaywallType = Tagged<(Self, type: ()), String>
  public typealias RemoteConfig = [String: Any]
  public typealias SpecialOfferType = Tagged<(Self, promoOffer: ()), String>
  public typealias VariantID = Tagged<(Self, variantID: ()), String>

  public let id: ID
  public let abTestName: String?  
  public let audienceName: String?
  public var products: [Product]

  let remoteConfigString: String?

  public var remoteConfig: RemoteConfig? {
    remoteConfigString?.data(using: .utf8).flatMap {
      try? JSONSerialization.jsonObject(with: $0, options: []) as? [String: Any]
    }
  }

  public init(
    id: ID,
    abTestName: String? = nil,
    audienceName: String? = nil,
    products: [Product]
  ) {
    self.id = id
    self.abTestName = abTestName
    self.audienceName = audienceName
    self.products = products
    self.remoteConfigString = nil
  }
}

extension Paywall.PaywallType {
  public enum Offer {
    public static var blackFriday: Paywall.PaywallType { "black_friday" }
    public static var christmas: Paywall.PaywallType { "xmas" }
    public static var cyberMonday: Paywall.PaywallType { "cyber_monday" }
    public static var introductory: Paywall.PaywallType { "introductory" }
    public static var limitedTime: Paywall.PaywallType { "lto" }
    public static var newYear: Paywall.PaywallType { "new_year" }
    public static var winterSale: Paywall.PaywallType { "winter_sale" }
  }

  public static var onboarding: Paywall.PaywallType { "onboarding" }
  public static var main: Paywall.PaywallType { "main" }

  public var isOnboarding: Bool {
    self == .onboarding
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
