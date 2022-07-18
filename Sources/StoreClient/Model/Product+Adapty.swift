import Adapty
import Foundation

extension Product {
  init?(_ product: ProductModel) {
    self.init(
      id: .init(rawValue: product.vendorProductId),
      displayName: product.localizedTitle,
      description: product.localizedDescription,
      price: product.price,
      priceLocale: product.skProduct?.priceLocale ?? .current,
      displayPrice: product.localizedPrice ?? "",
      subscriptionInfo: .init(product)
    )
    self._adaptyProduct = product
  }
}

extension Product.SubscriptionInfo {
  init?(_ product: ProductModel) {
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
    self.subscriptionGroupID = subscriptionGroupID
    self.subscriptionPeriod = subscriptionPeriod
  }
}

extension Product.SubscriptionOffer {
  static func introductoryOffer(
    _ discountModel: ProductDiscountModel,
    product: ProductModel
  ) -> Self? {
    guard
      let paymentMode = Product.SubscriptionOffer.PaymentMode(discountModel.paymentMode),
      let period = Product.SubscriptionPeriod(discountModel.subscriptionPeriod)
    else {
      return nil
    }

    return .init(
      id: discountModel.identifier,
      type: .introductory,
      price: discountModel.price,
      priceLocale: product.skProduct?.priceLocale ?? .current,
      displayPrice: discountModel.localizedPrice ?? "",
      period: period,
      paymentMode: paymentMode
    )
  }
}

extension Product.SubscriptionOffer.PaymentMode {
  init?(_ paymentMode: ProductDiscountModel.PaymentMode) {
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
  public init?(_ period: ProductSubscriptionPeriodModel) {
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
  public init?(_ unit: ProductModel.PeriodUnit) {
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
