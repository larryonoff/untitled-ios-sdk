import Adapty
@preconcurrency import Foundation
import StoreKit
import Tagged

public struct Product {
  public typealias ID = Tagged<Self, String>

  public struct SubscriptionInfo {
    public var introductoryOffer: Product.SubscriptionOffer?
    public var subscriptionGroupID: String
    public var subscriptionPeriod: Product.SubscriptionPeriod
  }

  public struct SubscriptionOffer {
    public enum OfferType: String {
      case introductory
    }

    public enum PaymentMode: String {
      case payAsYouGo = "pay_as_you_go"
      case payUpFront = "pay_up_front"
      case freeTrial = "free_trial"
    }

    public let id: String?

    public let type: Product.SubscriptionOffer.OfferType

    public let price: Decimal

    public let priceLocale: Locale

    public let displayPrice: String

    public let period: Product.SubscriptionPeriod

    public let paymentMode: Product.SubscriptionOffer.PaymentMode
  }

  public struct SubscriptionPeriod {
    public enum Unit {
      case day
      case week
      case month
      case year
    }

    public var unit: Unit
    public var value: Int

    public init(
      unit: Unit,
      value: Int
    ) {
      self.unit = unit
      self.value = value
    }
  }

  public var id: ID

  public var displayName: String
  public var description: String

  public var price: Decimal
  public var priceLocale: Locale
  public var displayPrice: String

  public var subscriptionInfo: SubscriptionInfo?

  var _adaptyProduct: ProductModel?

  public init(
    id: ID,
    displayName: String,
    description: String,
    price: Decimal,
    priceLocale: Locale,
    displayPrice: String,
    subscriptionInfo: SubscriptionInfo?
  ) {
    self.id = id
    self.displayName = displayName
    self.description = description
    self.price = price
    self.priceLocale = priceLocale
    self.displayPrice = displayPrice
    self.subscriptionInfo = subscriptionInfo
  }
}

extension Product.SubscriptionPeriod.Unit: CustomStringConvertible {
  public var description: String {
    switch self {
    case .day:
      return "day"
    case .week:
      return "week"
    case .month:
      return "month"
    case .year:
      return "year"
    }
  }
}

extension Product: Equatable {}

extension Product: Hashable {}

extension Product: Identifiable {}

extension Product.SubscriptionInfo: Codable {}

extension Product.SubscriptionInfo: Equatable {}

extension Product.SubscriptionInfo: Hashable {}

extension Product.SubscriptionInfo: Sendable {}

extension Product.SubscriptionOffer: Codable {}

extension Product.SubscriptionOffer: Equatable {}

extension Product.SubscriptionOffer: Hashable {}

extension Product.SubscriptionOffer: Sendable {}

extension Product.SubscriptionOffer.OfferType: Codable {}

extension Product.SubscriptionOffer.OfferType: Equatable {}

extension Product.SubscriptionOffer.OfferType: Hashable {}

extension Product.SubscriptionOffer.OfferType: Sendable {}

extension Product.SubscriptionOffer.PaymentMode: Codable {}

extension Product.SubscriptionOffer.PaymentMode: Equatable {}

extension Product.SubscriptionOffer.PaymentMode: Hashable {}

extension Product.SubscriptionOffer.PaymentMode: Sendable {}

extension Product.SubscriptionPeriod: Codable {}

extension Product.SubscriptionPeriod: Equatable {}

extension Product.SubscriptionPeriod: Hashable {}

extension Product.SubscriptionPeriod: Sendable {}

extension Product.SubscriptionPeriod.Unit: Codable {}

extension Product.SubscriptionPeriod.Unit: Equatable {}

extension Product.SubscriptionPeriod.Unit: Hashable {}

extension Product.SubscriptionPeriod.Unit: Sendable {}

// MARK: - Discount

extension Product {
  public func discount(
    comparingTo product: Product
  ) -> Decimal? {
    let price: Decimal
    let priceComparing: Decimal

    if
      let subscriptionInfo = subscriptionInfo,
      let subscriptionInfoComparing = product.subscriptionInfo
    {
      price = subscriptionInfo.subscriptionPeriod
        .convertPrice(self.price, to: .init(unit: .year, value: 1))
      priceComparing = subscriptionInfoComparing.subscriptionPeriod
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

  public func displayDiscount(
    comparingTo product: Product
  ) -> String? {
    guard let discount = discount(comparingTo: product) else {
      return nil
    }

    return discountFormatter.string(
      from: NSDecimalNumber(decimal: discount)
    )
  }
}

// MARK: - Price

extension Product {
  public static func displayPrice(
    _ price: Decimal,
    priceLocale: Locale
  ) -> String? {
    priceFormatter.locale = priceLocale

    return priceFormatter.string(
      from: NSDecimalNumber(decimal: price)
    )
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

// MARK: - Formatter

private let discountFormatter: NumberFormatter = {
  let formatter = NumberFormatter()
  formatter.numberStyle = .percent

  return formatter
}()

private let priceFormatter: NumberFormatter = {
  let formatter = NumberFormatter()
  formatter.numberStyle = .currency
  formatter.minimumFractionDigits = 0
  formatter.maximumFractionDigits = 2

  return formatter
}()
