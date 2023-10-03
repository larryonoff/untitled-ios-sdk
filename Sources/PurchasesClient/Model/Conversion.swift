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
    case (.day, .month):
      return price / Decimal(value) * 30.417 * Decimal(period.value)
    case (.day, .year):
      return price / Decimal(value) * 365.3 * Decimal(period.value)
    case (.week, .month):
      return price / Decimal(value) * 4.345 * Decimal(period.value)
    case (.week, .year):
      return price / Decimal(value) * 52.1786 * Decimal(period.value)
    default:
      return price * Decimal(Double(period.numberOfDays) / Double(numberOfDays))
    }
  }
}
