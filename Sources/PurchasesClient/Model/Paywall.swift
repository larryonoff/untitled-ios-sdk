import Adapty
import Foundation
import Tagged

public struct Paywall {
  public typealias ID = Tagged<Self, String>

  public let id: ID
  public let products: [Product]
  public let productComparingID: Product.ID?
  public let productSelectedID: Product.ID?

  public var productComparing: Product? {
    guard let comparingID = productComparingID else {
      return nil
    }
    return products.first { $0.id == comparingID }
  }

  public var productSelected: Product? {
    guard let selectedID = productSelectedID else {
      return nil
    }
    return products.first { $0.id == selectedID }
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
      .customPayload?["selected_product_id"]
      .flatMap { $0 as? String }
      .flatMap { .init(rawValue: $0) }
    self.productComparingID = paywall
      .customPayload?["comparing_product_id"]
      .flatMap { $0 as? String }
      .flatMap { .init(rawValue: $0) }
  }
}
