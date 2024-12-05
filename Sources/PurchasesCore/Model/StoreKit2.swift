import StoreKit

extension Product {
  public init(_ product: StoreKit.Product) {
    self.id = .init(product.id)
    self.displayName = product.displayName
    self.description = product.description
    self.price = product.price
    self.displayPrice = product.displayPrice
    self.subscription = product.subscription
      .flatMap { .init($0) }

    self.priceLocale = product.priceFormatStyle.locale

    self.subscriptionOffer = nil
  }
}

extension Product.SubscriptionInfo {
  public init(
    _ subscription: StoreKit.Product.SubscriptionInfo
  ) {
    self.introductoryOffer = subscription.introductoryOffer
      .flatMap { .init($0) }

    self.promotionalOffers = subscription.promotionalOffers
      .compactMap { .init($0) }

    if #available(iOS 18.0, *) {
      self.winBackOffers = subscription.winBackOffers
        .compactMap { .init($0) }
    } else {
      self.winBackOffers = []
    }

    self.subscriptionGroupID = subscription.subscriptionGroupID

    self.subscriptionPeriod = .init(subscription.subscriptionPeriod)

    self.isEligibleForIntroOffer = false
  }
}

extension Product.SubscriptionOffer {
  public init(
    _ offer: StoreKit.Product.SubscriptionOffer
  ) {
    self.id = offer.id.flatMap { .init(rawValue: $0) }
    self.type = .init(offer.type)

    self.price = offer.price
    self.displayPrice = offer.displayPrice

    self.period = .init(offer.period)

    self.periodCount = offer.periodCount

    self.paymentMode = .init(offer.paymentMode)
  }
}

extension Product.SubscriptionOffer.OfferType {
  public init(_ value: StoreKit.Product.SubscriptionOffer.OfferType) {
    if value == .introductory {
      self = .introductory
    } else if value == .promotional {
      self = .promotional
    } else if #available(iOS 18.0, *), value == .winBack {
      self = .winBack
    } else {
      assertionFailure("Product.SubscriptionOffer.OfferType.(@unknown default, rawValue: \(value.rawValue))")
      self = .introductory
    }
  }
}

extension Product.SubscriptionOffer.PaymentMode {
  public init(_ value: StoreKit.Product.SubscriptionOffer.PaymentMode) {
    switch value {
    case .payAsYouGo:
      self = .payAsYouGo
    case .payUpFront:
      self = .payUpFront
    case .freeTrial:
      self = .freeTrial
    default:
      assertionFailure("Product.SubscriptionOffer.PaymentMode.(@unknown default, rawValue: \(value.rawValue))")
      self = .freeTrial
    }
  }
}

extension Product.SubscriptionPeriod {
  public init(_ period: StoreKit.Product.SubscriptionPeriod) {
    self.value = period.value
    self.unit = Product.SubscriptionPeriod.Unit(period.unit)
  }
}

extension Product.SubscriptionPeriod.Unit {
  public init(_ value: StoreKit.Product.SubscriptionPeriod.Unit) {
    switch value {
    case .day:
      self = .day
    case .week:
      self = .week
    case .month:
      self = .month
    case .year:
      self = .year
    }
  }
}
