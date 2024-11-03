import Foundation
@_exported import Tagged

public struct Paywall {
  public typealias ID = Tagged<Self, String>
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

// MARK: - Remote Config

extension Paywall {
  public var filteredProductIDs: [Product.ID] {
    remoteConfig?["filtered_product_ids"]
      .flatMap { $0 as? [String] }?
      .map(Product.ID.init(rawValue:)) ?? []
  }

  public var productComparingID: Product.ID? {
    remoteConfig?["comparing_product_id"]
      .flatMap { $0 as? String }
      .flatMap { .init($0) }
  }

  public var productComparing: Product? {
    guard let productComparingID else { return nil }
    return products.first { $0.id == productComparingID }
  }

  public var productSelectedID: Product.ID? {
    remoteConfig?["selected_product_id"]
      .flatMap { $0 as? String }
      .flatMap { .init($0) }
  }

  public var productSelected: Product? {
    guard let productSelectedID else { return nil }
    return products.first { $0.id == productSelectedID }
  }

  public var introductoryOfferProductID: Product.ID? {
    remoteConfig?["introductory_offer_product_id"]
      .flatMap { $0 as? String }
      .flatMap { .init($0) }
  }

  public var introductoryOfferProduct: Product? {
    guard let introductoryOfferProductID else { return nil }
    return products.first { $0.id == introductoryOfferProductID }
  }

  public var variantID: VariantID? {
    remoteConfig?["variant_id"]
      .flatMap { $0 as? String }
      .flatMap { .init($0) }
  }
}
