import Foundation
import Tagged

public struct Product {
  public typealias ID = Tagged<Self, String>

  public struct SubscriptionInfo {
    public var introductoryOffer: Product.SubscriptionOffer?
    public var promotionalOffers: [Product.SubscriptionOffer]
    public var winBackOffers: [Product.SubscriptionOffer]
    public var subscriptionGroupID: String
    public var subscriptionPeriod: Product.SubscriptionPeriod
    public var isEligibleForIntroOffer: Bool
  }

  public struct SubscriptionOffer {
    public typealias ID = Tagged<Self, String>

    public enum OfferType: String {
      case introductory
      case promotional
      case winBack

      case code
    }

    public enum PaymentMode: String {
      case payAsYouGo = "pay_as_you_go"
      case payUpFront = "pay_up_front"
      case freeTrial = "free_trial"
    }

    public let id: ID?

    public let type: Product.SubscriptionOffer.OfferType

    public let price: Decimal

    public let displayPrice: String

    public let period: Product.SubscriptionPeriod

    public var periodCount: Int

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

  public var priceFormatStyle: Decimal.FormatStyle.Currency {
    .init(code: priceLocale.currencyCode ?? "USD", locale: priceLocale)
    .rounded(rule: .down)
  }

  public var displayPrice: String

  public var subscription: SubscriptionInfo?

  public var subscriptionOffer: Product.SubscriptionOffer?

  public init(
    id: ID,
    displayName: String,
    description: String,
    price: Decimal,
    priceLocale: Locale,
    displayPrice: String,
    subscription: SubscriptionInfo?
  ) {
    self.id = id
    self.displayName = displayName
    self.description = description
    self.price = price
    self.priceLocale = priceLocale
    self.displayPrice = displayPrice
    self.subscription = subscription
  }

  // MARK: - Helper Properties

  public var isEligibleForTrial: Bool {
    subscription?
      .introductoryOffer?
      .paymentMode == .freeTrial
  }
}

extension Product.SubscriptionPeriod {
  public var numberOfDays: Double {
    switch unit {
    case .day:
      return Double(value)
    case .week:
      return Double(value) * 7
    case .month:
      // using average month length
      return Double(value) * 30.44
    case .year:
      // using average year length accounting for leap years
      return Double(value) * 365.25
    }
  }

  public static func day(_ value: Int) -> Self {
    .init(unit: .day, value: value)
  }

  public static func week(_ value: Int) -> Self {
    .init(unit: .week, value: value)
  }

  public static func month(_ value: Int) -> Self {
    .init(unit: .month, value: value)
  }

  public static func year(_ value: Int) -> Self {
    .init(unit: .year, value: value)
  }

  public static var weekly: Self {
    .init(unit: .week, value: 1)
  }

  public static var monthly: Product.SubscriptionPeriod {
    .init(unit: .month, value: 1)
  }

  public static var yearly: Product.SubscriptionPeriod {
    .init(unit: .year, value: 1)
  }

  public static var everyThreeDays: Product.SubscriptionPeriod {
    .init(unit: .day, value: 3)
  }

  public static var everyTwoWeeks: Product.SubscriptionPeriod {
    .init(unit: .week, value: 2)
  }

  public static var everyTwoMonths: Product.SubscriptionPeriod {
    .init(unit: .month, value: 2)
  }

  public static var everyThreeMonths: Product.SubscriptionPeriod {
    .init(unit: .month, value: 3)
  }

  public static var everySixMonths: Product.SubscriptionPeriod {
    .init(unit: .month, value: 6)
  }
}

extension Product.SubscriptionPeriod.Unit: CustomStringConvertible {
  public var description: String {
    switch self {
    case .day: "day"
    case .week: "week"
    case .month: "month"
    case .year: "year"
    }
  }
}

extension Product: Equatable {}
extension Product: Hashable {}
extension Product: Identifiable {}
extension Product: Sendable {}

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
