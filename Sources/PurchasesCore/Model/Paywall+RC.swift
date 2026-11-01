import Foundation

extension Paywall {
  public var excludedProductIDs: [Product.ID] {
    remoteConfig?["filtered_product_ids"]
      .flatMap { $0 as? [String] }?
      .map(Product.ID.init(rawValue:)) ?? []
  }

  public var comparisonProductID: Product.ID? {
    remoteConfig?["comparing_product_id"]
      .flatMap { $0 as? String }
      .flatMap { .init($0) }
  }

  public var comparisonProduct: Product? {
    guard let comparisonProductID else { return nil }
    return products.first { $0.id == comparisonProductID }
  }

  public var selectedProductID: Product.ID? {
    remoteConfig?["selected_product_id"]
      .flatMap { $0 as? String }
      .flatMap { .init($0) }
  }

  public var selectedProduct: Product? {
    guard let selectedProductID else { return nil }
    return products.first { $0.id == selectedProductID }
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

  public var offerDuration: TimeInterval? {
    remoteConfig?["offer_duration"]
      .flatMap { $0 as? TimeInterval }
  }

  public var offerEndDate: Date? {
    remoteConfig?["offer_end_date"]
      .flatMap { $0 as? String }
      .flatMap { string -> Date? in
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd"

        return formatter.date(from: string)
      }
  }

  // MARK: - AB Variant

  public var variantID: VariantID? {
    remoteConfig?["variant_id"]
      .flatMap { $0 as? String }
      .flatMap { .init($0) }
  }
}
