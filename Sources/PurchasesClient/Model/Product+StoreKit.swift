import StoreKit

extension Product {
  public init(_ product: SKProduct) {
    id = .init(product.productIdentifier)
    displayName = product.localizedTitle
    description = product.localizedDescription

    price = product.price.decimalValue
    priceLocale = product.priceLocale
    displayPrice = Self.displayPrice(
      product.price.decimalValue,
      priceLocale: product.priceLocale
    ) ?? ""

    subscription = .init(product)
  }
}

extension Product.SubscriptionInfo {
  init?(_ product: SKProduct) {
    guard
      let subscriptionGroupID = product.subscriptionGroupIdentifier,
      let subscriptionPeriod = product.subscriptionPeriod
        .flatMap(Product.SubscriptionPeriod.init)
    else {
      return nil
    }

    self.introductoryOffer = product
      .introductoryPrice
      .flatMap { .init($0) }
    self.subscriptionGroupID = subscriptionGroupID
    self.subscriptionPeriod = subscriptionPeriod
    self.promotionalOffers = product.discounts
      .compactMap { Product.SubscriptionOffer($0) }
    self.isEligibleForIntroOffer = true
  }
}

extension Product.SubscriptionOffer {
  public init(_ discount: SKProductDiscount) {
    id = discount.identifier.flatMap { .init($0) }
    type = .init(discount.type)

    price = discount.price.decimalValue
    priceLocale = discount.priceLocale
    displayPrice = Product.displayPrice(
      discount.price.decimalValue,
      priceLocale: discount.priceLocale
    ) ?? ""
    period = Product.SubscriptionPeriod(discount.subscriptionPeriod)
    paymentMode = PaymentMode(discount.paymentMode)
  }
}

extension Product.SubscriptionOffer.PaymentMode {
  public init(_ value: SKProductDiscount.PaymentMode) {
    switch value {
    case .payAsYouGo:
      self = .payAsYouGo
    case .payUpFront:
      self = .payUpFront
    case .freeTrial:
      self = .freeTrial
    @unknown default:
      assertionFailure("SKProductDiscount.PaymentMode.(@unknown default, rawValue: \(value.rawValue))")
      self = .freeTrial
    }
  }
}

extension Product.SubscriptionOffer.OfferType {
  public init(_ value: SKProductDiscount.`Type`) {
    switch value {
    case .introductory:
      self = .introductory
    case .subscription:
      self = .promotional
    @unknown default:
      assertionFailure("SKProductDiscount.`Type`.(@unknown default, rawValue: \(value.rawValue))")
      self = .promotional
    }
  }
}

extension Product.SubscriptionPeriod {
  public init(_ period: SKProductSubscriptionPeriod) {
    self.value = period.numberOfUnits
    self.unit = Product.SubscriptionPeriod.Unit(period.unit)
  }
}

extension Product.SubscriptionPeriod.Unit {
  public init(_ value: SKProduct.PeriodUnit) {
    switch value {
    case .day:
      self = .day
    case .week:
      self = .week
    case .month:
      self = .month
    case .year:
      self = .year
    @unknown default:
      assertionFailure("SKProduct.PeriodUnit.(@unknown default, rawValue: \(value.rawValue))")
      self = .year
    }
  }
}
