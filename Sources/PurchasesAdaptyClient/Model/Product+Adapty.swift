import Adapty
import struct DuckPurchasesCore.Product
import Foundation
import StoreKit

extension Product {
  package init?(_ product: any AdaptyProduct) {
    let skProduct = product.skProduct

    let paywallProduct = product as? AdaptyPaywallProduct

    self.init(
      id: .init(product.vendorProductId),
      displayName: product.localizedTitle,
      description: product.localizedDescription,
      price: product.price,
      priceLocale: skProduct.priceFormatStyle.locale,
      displayPrice: Product.formattedPrice(
        product.price,
        locale: skProduct.priceFormatStyle.locale
      ) ?? "",
      subscription: .init(product)
    )
    self.subscriptionOffer = paywallProduct?.subscriptionOffer.flatMap {
      .init($0, product: product)
    }
  }
}

extension Product.SubscriptionInfo {
  @_optimize(none)
  package init?(_ product: any AdaptyProduct) {
    let paywallProduct = product as? AdaptyPaywallProduct

    guard
      let subscriptionGroupID = product.subscriptionGroupIdentifier,
      let subscriptionPeriod = product.subscriptionPeriod
        .flatMap(Product.SubscriptionPeriod.init)
    else {
      return nil
    }

    let subscription = product.skProduct.subscription
    let introductoryOffer: Product.SubscriptionOffer?
    let promotionalOffers: [Product.SubscriptionOffer]
    let winBackOffers: [Product.SubscriptionOffer]

    if let subscription {
      introductoryOffer = subscription.introductoryOffer
        .flatMap { .init($0) }

      promotionalOffers = subscription.promotionalOffers
        .compactMap { .init($0) }

      winBackOffers = subscription.winBackOffers
        .compactMap { .init($0) }
    } else {
      introductoryOffer = nil
      promotionalOffers = []
      winBackOffers = []
    }

    // Eligibility comes from the offer attached by Adapty, not catalog IDs.
    self.init(
      introductoryOffer: introductoryOffer,
      promotionalOffers: promotionalOffers,
      winBackOffers: winBackOffers,
      subscriptionGroupID: subscriptionGroupID,
      subscriptionPeriod: subscriptionPeriod,
      isEligibleForIntroOffer: paywallProduct?.subscriptionOffer?.offerType == .introductory
    )
  }
}

extension Product.SubscriptionOffer {
  package init?(
    _ offer: AdaptySubscriptionOffer,
    product: any AdaptyProduct
  ) {
    guard
      let paymentMode = Product.SubscriptionOffer.PaymentMode(offer.paymentMode),
      let period = Product.SubscriptionPeriod(offer.subscriptionPeriod)
    else {
      return nil
    }

    let skProduct = product.skProduct

    self = .init(
      id: offer.identifier.flatMap { .init($0) },
      type: .init(offer.offerType),
      price: offer.price,
      displayPrice: Product.formattedPrice(
        offer.price,
        locale: skProduct.priceFormatStyle.locale
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
    default:
      self = .init(rawValue: offerType.rawValue)
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
