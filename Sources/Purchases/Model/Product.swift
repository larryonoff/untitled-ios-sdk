import Foundation
import Tagged

public struct Product {
  public typealias ID = Tagged<Self, String>

  public struct SubscriptionInfo {
    public var introductoryOffer: Product.SubscriptionOffer?
    public var promotionalOffers: [Product.SubscriptionOffer]
    public var subscriptionGroupID: String
    public var subscriptionPeriod: Product.SubscriptionPeriod
    public var isEligibleForIntroOffer: Bool
  }

  public struct SubscriptionOffer {
    public typealias ID = Tagged<Self, String>

    public enum OfferType: String {
      case introductory
      case promotional
    }

    public enum PaymentMode: String {
      case payAsYouGo = "pay_as_you_go"
      case payUpFront = "pay_up_front"
      case freeTrial = "free_trial"
    }

    public let id: ID?

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

  public var promoOfferID: SubscriptionOffer.ID?

  public var promoOffer: SubscriptionOffer? {
    promoOfferID.flatMap { promoOfferID in
      subscription?.promotionalOffers
        .first { $0.id == promoOfferID }
    }
  }

  public var subscription: SubscriptionInfo?

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

  // MARK: - Dynamic Properties

  public var isEligibleForTrial: Bool {
    subscription?
      .introductoryOffer?
      .paymentMode == .freeTrial
  }
}

extension Product.SubscriptionPeriod {
  public var numberOfDays: Int {
    switch unit {
    case .day: value
    case .week: value * Product.SubscriptionPeriod.day(7).numberOfDays
    case .month: value * Product.SubscriptionPeriod.week(4).numberOfDays
    case .year: value * Product.SubscriptionPeriod.month(12).numberOfDays
    }
  }

  public static func year(_ value: Int) -> Self {
    .init(unit: .year, value: value)
  }

  public static func month(_ value: Int) -> Self {
    .init(unit: .month, value: value)
  }

  public static func week(_ value: Int) -> Self {
    .init(unit: .week, value: value)
  }

  public static func day(_ value: Int) -> Self {
    .init(unit: .day, value: value)
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
