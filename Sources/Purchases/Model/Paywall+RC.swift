import Foundation

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

  // MARK: - Intro Offer

  public var introductoryOfferProductID: Product.ID? {
    remoteConfig?["introductory_offer_product_id"]
      .flatMap { $0 as? String }
      .flatMap { .init($0) }
  }

  public var introductoryOfferProduct: Product? {
    guard let introductoryOfferProductID else { return nil }
    return products.first { $0.id == introductoryOfferProductID }
  }

  // MARK: - Intro Offer

  public var offerDuration: TimeInterval? {
    remoteConfig?["offer_duration"]
      .flatMap { $0 as? TimeInterval }
  }

  // MARK: - AB Variant

  public var variantID: VariantID? {
    remoteConfig?["variant_id"]
      .flatMap { $0 as? String }
      .flatMap { .init($0) }
  }
}
