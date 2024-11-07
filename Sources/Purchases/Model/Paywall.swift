import Foundation
@_exported import Tagged

public struct Paywall {
  public typealias ID = Tagged<Self, String>
  public typealias PromoOffer = Tagged<Self, String>
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

extension Paywall: Equatable {}
extension Paywall: Hashable {}
extension Paywall: Identifiable {}
extension Paywall: Sendable {}
