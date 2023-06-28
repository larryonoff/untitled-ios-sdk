import Adapty
import Foundation
@_exported import Tagged

public struct Paywall {
  public typealias ID = Tagged<Self, String>
  public typealias VariantID = Tagged<(Self, variantID: ()), String>

  public let id: ID
  public var products: [Product]
  public let productComparingID: Product.ID?
  public let productSelectedID: Product.ID?

  public let payUpFrontProductID: Product.ID?
  public let filterPayUpFrontProduct: Bool

  public let variantID: VariantID?

  let remoteConfigString: String?

  public var productComparing: Product? {
    guard let productID = productComparingID else {
      return nil
    }
    return products.first { $0.id == productID }
  }

  public var productSelected: Product? {
    guard let productID = productSelectedID else {
      return nil
    }
    return products.first { $0.id == productID }
  }

  public var payUpFrontProduct: Product? {
    guard let productID = payUpFrontProductID else {
      return nil
    }
    return products.first { $0.id == productID }
  }

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

extension Paywall {
  init(
    _ paywall: AdaptyPaywall,
    products: [AdaptyPaywallProduct]?
  ) {
    self.id = .init(paywall.id)
    self.products = products?
      .compactMap { .init($0) } ?? []
    self.productSelectedID = paywall
      .remoteConfig?["selected_product_id"]
      .flatMap { $0 as? String }
      .flatMap { .init($0) }
    self.payUpFrontProductID = paywall
      .remoteConfig?["ios_pay_up_front_product_id"]
      .flatMap { $0 as? String }
      .flatMap { .init($0) }
    self.filterPayUpFrontProduct = paywall
      .remoteConfig?["ios_filter_pay_up_front_product"]
      .flatMap { $0 as? Bool } ?? true
    self.productComparingID = paywall
      .remoteConfig?["comparing_product_id"]
      .flatMap { $0 as? String }
      .flatMap { .init($0) }
    self.variantID = paywall
      .remoteConfig?["variant_id"]
      .flatMap { $0 as? String }
      .flatMap { .init($0) }
    self.remoteConfigString = paywall.remoteConfigString
  }
}
