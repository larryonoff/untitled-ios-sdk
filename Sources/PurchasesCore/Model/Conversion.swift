import Foundation

extension Decimal {
  public func discount(
    comparingTo comparingValue: Decimal
  ) -> Decimal {
    let decimalHandler = NSDecimalNumberHandler(
      roundingMode: .bankers,
      scale: 2,
      raiseOnExactness: false,
      raiseOnOverflow: false,
      raiseOnUnderflow: false,
      raiseOnDivideByZero: false
    )

    let decimalPrice = NSDecimalNumber(decimal: self)
    let decimalComparingPrice = NSDecimalNumber(decimal: comparingValue)

    let ratio = decimalPrice
      .dividing(by: decimalComparingPrice)
      .rounding(accordingToBehavior: decimalHandler)

    return NSDecimalNumber(value: 1)
      .subtracting(ratio)
      .decimalValue
  }
}

extension Product {
  public func discount(
    comparingTo product: Product
  ) -> Decimal? {
    let price: Decimal
    let priceComparing: Decimal

    if
      let subscription,
      let subscriptionComparing = product.subscription
    {
      price = subscription.subscriptionPeriod
        .convertedPrice(self.price, to: .init(unit: .year, value: 1))
      priceComparing = subscriptionComparing.subscriptionPeriod
        .convertedPrice(product.price, to: .init(unit: .year, value: 1))
    } else {
      price = self.price
      priceComparing = product.price
    }

    return price.discount(comparingTo: priceComparing)
  }
}

extension Product.SubscriptionOffer {
  public func discount(
    comparingTo product: Product
  ) -> Decimal? {
    guard paymentMode != .freeTrial else { return nil }

    let price: Decimal
    let priceComparing: Decimal

    if let subscription = product.subscription {
      price = self.period
        .convertedPrice(self.price, to: .init(unit: .year, value: 1))
      priceComparing = subscription.subscriptionPeriod
        .convertedPrice(product.price, to: .init(unit: .year, value: 1))
    } else {
      price = self.price
      priceComparing = product.price
    }

    return price.discount(comparingTo: priceComparing)
  }
}

extension Product.SubscriptionPeriod {
  public func convertedPrice(
    _ price: Decimal,
    to period: Product.SubscriptionPeriod
  ) -> Decimal {
    guard self != period else {
      return price
    }

    guard numberOfDays > 0 else {
      return 0
    }

    // Divide after multiplying so a binary fraction cannot lower a whole-currency result.
    return price * Decimal(period.numberOfDays) / Decimal(numberOfDays)
  }
}
