import Adapty
import Foundation

extension Paywall {
  package init(
    _ paywall: AdaptyPaywall,
    products: [AdaptyPaywallProduct]?
  ) {
    self.id = .init(paywall.placementId)

    self.abTestName = paywall.abTestName
    self.audienceName = paywall.audienceName

    self.products = products?
      .compactMap { .init($0) } ?? []

    self.remoteConfigString = paywall.remoteConfig?.jsonString
  }
}

extension Product {
  package init?(_ product: AdaptyProduct) {
    guard let skProduct = product.sk2Product else {
      return nil
    }

    let paywallProduct = product as? AdaptyPaywallProduct

    self.id = .init(product.vendorProductId)
    self.displayName = product.localizedTitle
    self.description = product.localizedDescription
    self.price = product.price
    self.priceLocale = skProduct.priceFormatStyle.locale
    self.displayPrice = Product.displayPrice(
      product.price,
      formatStyle: skProduct.priceFormatStyle
    ) ?? ""

    self.subscription = .init(product)
    self.subscriptionOffer = paywallProduct?.subscriptionOffer.flatMap {
      .init($0, product: product)
    }
  }
}

extension Product.SubscriptionInfo {
  @_optimize(none)
  package init?(_ product: AdaptyProduct) {
    let paywallProduct = product as? AdaptyPaywallProduct

    guard
      let subscriptionGroupID = product.subscriptionGroupIdentifier,
      let subscriptionPeriod = product.subscriptionPeriod
        .flatMap(Product.SubscriptionPeriod.init)
    else {
      return nil
    }

    let skProduct = paywallProduct?.sk2Product
    let subscription = skProduct?.subscription

    if let subscription {
      self.introductoryOffer = subscription.introductoryOffer
        .flatMap { .init($0) }

      self.promotionalOffers = subscription.promotionalOffers
        .compactMap { .init($0) } ?? []

      if #available(iOS 18.0, *) {
        self.winBackOffers = subscription.winBackOffers
          .compactMap { .init($0) } ?? []
      } else {
        self.winBackOffers = []
      }
    } else {
      self.introductoryOffer = nil
      self.promotionalOffers = []
      self.winBackOffers = []
    }

    self.subscriptionGroupID = subscriptionGroupID
    self.subscriptionPeriod = subscriptionPeriod

    self.isEligibleForIntroOffer =
      subscription?.introductoryOffer?.id != nil &&
      paywallProduct?.subscriptionOffer?.identifier == subscription?.introductoryOffer?.id &&
      paywallProduct?.subscriptionOffer?.offerType == .introductory
  }
}

extension Product.SubscriptionOffer {
  package init?(
    _ offer: AdaptySubscriptionOffer,
    product: AdaptyProduct
  ) {
    guard
      let paymentMode = Product.SubscriptionOffer.PaymentMode(offer.paymentMode),
      let period = Product.SubscriptionPeriod(offer.subscriptionPeriod),
      let sk2Product = product.sk2Product
    else {
      return nil
    }

    self = .init(
      id: offer.identifier.flatMap { .init($0) },
      type: .init(offer.offerType),
      price: offer.price,
      displayPrice: Product.displayPrice(
        offer.price,
        formatStyle: sk2Product.priceFormatStyle
      ) ?? "",
      period: period,
      periodCount: offer.numberOfPeriods,
      paymentMode: paymentMode
    )
  }
}

extension Product.SubscriptionOffer.OfferType {
  package init(_ offerType: AdaptySubscriptionOfferType) {
    switch offerType {
    case .introductory:
      self = .introductory
    case .promotional:
      self = .promotional
    case .winBack:
      self = .winBack
    case .code:
      self = .code
    }
  }
}

extension Product.SubscriptionOffer.PaymentMode {
  package init?(_ paymentMode: AdaptySubscriptionOffer.PaymentMode) {
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
  package init?(_ period: AdaptySubscriptionPeriod) {
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
  package init?(_ unit: AdaptySubscriptionPeriod.Unit) {
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
