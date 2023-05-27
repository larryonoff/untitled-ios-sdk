import Adapty
import Foundation

extension Product {
  init?(_ product: AdaptyProduct) {
    self.init(
      id: .init(product.vendorProductId),
      displayName: product.localizedTitle,
      description: product.localizedDescription,
      price: product.price,
      priceLocale: product.skProduct.priceLocale,
      displayPrice: Product.displayPrice(
        product.price,
        priceLocale: product.skProduct.priceLocale
      ) ?? "",
      subscription: .init(product)
    )
  }
}

extension Product.SubscriptionInfo {
  init?(_ product: AdaptyProduct) {
    guard
      let subscriptionGroupID = product.subscriptionGroupIdentifier,
      let subscriptionPeriod = product.subscriptionPeriod
        .flatMap(Product.SubscriptionPeriod.init)
    else {
      return nil
    }

    self.introductoryOffer = product.introductoryDiscount.flatMap {
      .introductoryOffer($0, product: product)
    }
    self.promotionalOffers = product.skProduct.discounts
      .compactMap { Product.SubscriptionOffer($0) }
    self.subscriptionGroupID = subscriptionGroupID
    self.subscriptionPeriod = subscriptionPeriod
    self.isEligibleForIntroOffer = true
  }
}

extension Product.SubscriptionOffer {
  static func introductoryOffer(
    _ discount: AdaptyProductDiscount,
    product: AdaptyProduct
  ) -> Self? {
    guard
      let paymentMode = Product.SubscriptionOffer.PaymentMode(discount.paymentMode),
      let period = Product.SubscriptionPeriod(discount.subscriptionPeriod)
    else {
      return nil
    }

    return .init(
      id: discount.identifier,
      type: .introductory,
      price: discount.price,
      priceLocale: product.skProduct.priceLocale,
      displayPrice: Product.displayPrice(
        discount.price,
        priceLocale: product.skProduct.priceLocale
      ) ?? "",
      period: period,
      paymentMode: paymentMode
    )
  }
}

extension Product.SubscriptionOffer.PaymentMode {
  init?(_ paymentMode: AdaptyProductDiscount.PaymentMode) {
    switch paymentMode {
    case .freeTrial:
      self = .freeTrial
    case .payAsYouGo:
      self = .payAsYouGo
    case .payUpFront:
      self = .payUpFront
    default:
      return nil
    }
  }
}

extension Product.SubscriptionPeriod {
  public init?(_ period: AdaptyProductSubscriptionPeriod) {
    guard let unit = Product.SubscriptionPeriod.Unit(period.unit) else {
      return nil
    }

    self.init(
      unit: unit,
      value: period.numberOfUnits
    )
  }
}

extension Product.SubscriptionPeriod.Unit {
  public init?(_ unit: AdaptyPeriodUnit) {
    switch unit {
    case .day:
      self = .day
    case .week:
      self = .week
    case .month:
      self = .month
    case .year:
      self = .year
    case .unknown:
      return nil
    }
  }
}
