import Foundation
@_exported import Tagged

public struct Paywall {
  /// The purchases provider's placement ID the paywall is fetched by.
  public typealias ID = Tagged<(Self, id: ()), String>
  /// Which design renders the paywall.
  public typealias Kind = Tagged<(Self, kind: ()), String>
  public typealias RemoteConfig = [String: Any]
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
    products: [Product],
    remoteConfigString: String? = nil
  ) {
    self.id = id
    self.abTestName = abTestName
    self.audienceName = audienceName
    self.products = products
    self.remoteConfigString = remoteConfigString
  }
}

extension Paywall {
  /// A paywall to show: which design renders it and which placement it's
  /// fetched by.
  public struct Target: Hashable, Sendable {
    public var kind: Kind
    public var id: ID

    public init(kind: Kind, id: ID) {
      self.kind = kind
      self.id = id
    }
  }
}

extension Paywall.Kind {
  public enum Offer {
    public static let blackFriday: Paywall.Kind = "black_friday"
    public static let christmas: Paywall.Kind = "xmas"
    public static let cyberMonday: Paywall.Kind = "cyber_monday"
    public static let introductory: Paywall.Kind = "introductory"
    public static let limitedTime: Paywall.Kind = "lto"
    public static let newYear: Paywall.Kind = "new_year"
    public static let winterSale: Paywall.Kind = "winter_sale"
  }

  public static let main: Paywall.Kind = "main"
  public static let onboarding: Paywall.Kind = "onboarding"

  public var isOnboarding: Bool {
    self == .onboarding
  }
}

extension Paywall: Equatable {}
extension Paywall: Hashable {}
extension Paywall: Identifiable {}
extension Paywall: Sendable {}
