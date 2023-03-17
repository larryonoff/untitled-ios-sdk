import Adapty
import Foundation
import Tagged

public struct Paywall {
  public typealias ID = Tagged<Self, String>
  public typealias VariantID = Tagged<(Self, variantID: ()), String>

  public let id: ID
  public let products: [Product]
  public let productComparingID: Product.ID?
  public let productSelectedID: Product.ID?

  public let payUpFrontProductID: Product.ID?

  public let variantID: VariantID?

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
    self.id = .init(rawValue: paywall.id)
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
    self.productComparingID = paywall
      .remoteConfig?["comparing_product_id"]
      .flatMap { $0 as? String }
      .flatMap { .init($0) }
    self.variantID = paywall
      .remoteConfig?["variant_id"]
      .flatMap { $0 as? String }
      .flatMap { .init($0) }

  }
}
