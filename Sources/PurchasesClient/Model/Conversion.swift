import Foundation

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
        .convertPrice(self.price, to: .init(unit: .year, value: 1))
      priceComparing = subscriptionComparing.subscriptionPeriod
        .convertPrice(product.price, to: .init(unit: .year, value: 1))
    } else {
      price = self.price
      priceComparing = product.price
    }

    let decimalHandler = NSDecimalNumberHandler(
      roundingMode: .bankers,
      scale: 2,
      raiseOnExactness: false,
      raiseOnOverflow: false,
      raiseOnUnderflow: false,
      raiseOnDivideByZero: false
    )

    let decimalPrice = NSDecimalNumber(decimal: price)
    let decimalComparingPrice = NSDecimalNumber(decimal: priceComparing)

    let ratio = decimalPrice
      .dividing(by: decimalComparingPrice)
      .rounding(accordingToBehavior: decimalHandler)

    return NSDecimalNumber(value: 1)
      .subtracting(ratio)
      .decimalValue
  }
}

extension Product.SubscriptionPeriod {
  public func convertPrice(
    _ price: Decimal,
    to period: Product.SubscriptionPeriod
  ) -> Decimal {
    switch (unit, period.unit) {
    case (.day, .day):
      return price * Decimal(value) / Decimal(period.value)
    case (.day, .week):
      return price * Decimal(value) * 7 / Decimal(period.value)
    case (.day, .month):
      return price * Decimal(value) * 30 / Decimal(period.value)
    case (.day, .year):
      return price * Decimal(value) * 365 / Decimal(period.value)
    case (.week, .day):
      return price / 7
    case (.week, .week):
      return price * Decimal(value) / Decimal(period.value)
    case (.week, .month):
      return price * Decimal(value) * 4.345 / Decimal(period.value)
    case (.week, .year):
      return price * Decimal(value) * 52.143 / Decimal(period.value)
    case (.month, .day):
      return price * Decimal(value) / Decimal(period.value) / 30
    case (.month, .week):
      return price * Decimal(value) / Decimal(period.value) / 4.345
    case (.month, .month):
      return price * Decimal(value) / Decimal(period.value)
    case (.month, .year):
      return price * Decimal(value) * 12 / Decimal(period.value)
    case (.year, .day):
      return price * Decimal(value) / Decimal(period.value) / 365
    case (.year, .week):
      return price * Decimal(value) / Decimal(period.value) / 52.143
    case (.year, .month):
      return price * Decimal(value) / Decimal(period.value) / 12
    case (.year, .year):
      return price * Decimal(value) / Decimal(period.value)
    }
  }
}
