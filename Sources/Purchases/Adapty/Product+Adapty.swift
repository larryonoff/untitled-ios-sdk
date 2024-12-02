import Adapty
import Foundation

package extension Product {
  init?(_ product: any AdaptyProduct) {
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

    self.updateIntroductoryOfferEligibility(
      isEligibleForIntroOffer: self.subscription?.isEligibleForIntroOffer ?? false,
      promotionalOfferID: product.promotionalOfferId
    )
  }

  mutating
  package func updateIntroductoryOfferEligibility(
    isEligibleForIntroOffer: Bool,
    promotionalOfferID: String?
  ) {
    self.subscription?.isEligibleForIntroOffer = isEligibleForIntroOffer

    if isEligibleForIntroOffer {
      self.subscriptionOffer = self.subscription?.introductoryOffer
    } else {
      self.subscriptionOffer = promotionalOfferID
        .flatMap { offerID -> Product.SubscriptionOffer? in
          self.subscription?.promotionalOffers
            .first { $0.id?.rawValue == offerID }
        }
    }
  }
}

package extension Product.SubscriptionInfo {
  init?(_ product: any AdaptyProduct) {
    guard
      let subscriptionGroupID = product.subscriptionGroupIdentifier,
      let subscriptionPeriod = product.subscriptionPeriod
        .flatMap(Product.SubscriptionPeriod.init)
    else {
      return nil
    }

    self.init(
      introductoryOffer: product.introductoryDiscount
        .flatMap { .init($0, product: product) },
      promotionalOffers: product.skProduct.discounts
        .compactMap { Product.SubscriptionOffer($0) },
      winBackOffers: [],
      subscriptionGroupID: subscriptionGroupID,
      subscriptionPeriod: subscriptionPeriod,
      isEligibleForIntroOffer: true
    )
  }
}

package extension Product.SubscriptionOffer {
  init?(
    _ discount: AdaptyProductDiscount,
    product: any AdaptyProduct
  ) {
    guard
      let paymentMode = Product.SubscriptionOffer.PaymentMode(discount.paymentMode),
      let period = Product.SubscriptionPeriod(discount.subscriptionPeriod)
    else {
      return nil
    }

    self.init(
      id: discount.identifier.flatMap { .init($0) },
      type: .introductory,
      price: discount.price,
      displayPrice: Product.displayPrice(
        discount.price,
        priceLocale: product.skProduct.priceLocale
      ) ?? "",
      period: period,
      periodCount: discount.numberOfPeriods,
      paymentMode: paymentMode
    )
  }
}

package extension Product.SubscriptionOffer.PaymentMode {
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
