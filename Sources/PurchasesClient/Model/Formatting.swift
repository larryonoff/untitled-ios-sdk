@preconcurrency import Foundation

extension Product {
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

// MARK: - Product

extension Product {
  public enum FormatStyle {
    public struct Price {
      var subscriptionPeriod: Product.SubscriptionPeriod?

      public init(
        subscriptionPeriod: Product.SubscriptionPeriod?
      ) {
        self.subscriptionPeriod = subscriptionPeriod
      }
    }
  }
}

extension Product.FormatStyle.Price: Foundation.FormatStyle {
  public func format(_ value: Product) -> String {
    if let subscriptionInfo = value.subscriptionInfo {
      var price = value.price
      var subscriptionPeriod = subscriptionInfo.subscriptionPeriod

      if let destinationPeriod = self.subscriptionPeriod {
        price = subscriptionInfo
          .subscriptionPeriod
          .convertPrice(
            value.price,
            to: destinationPeriod
          )
        subscriptionPeriod = destinationPeriod
      }

      let priceString = Product.displayPrice(
        price,
        priceLocale: value.priceLocale
      )
      let subscriptionPeriodString = subscriptionPeriod.formatted()

      return [priceString, subscriptionPeriodString]
        .compactMap { $0 }
        .joined(separator: " / ")
    }

    return Product.displayPrice(
      value.price,
      priceLocale: value.priceLocale
    ) ?? ""
  }
}

extension Product {
  public func formatted<F: Foundation.FormatStyle>(
    _ style: F
  ) -> F.FormatOutput where F.FormatInput == Product {
    style.format(self)
  }
}

extension FormatStyle where Self == Product.FormatStyle.Price {
  public static func price(
    subscriptionPeriod: Product.SubscriptionPeriod? = nil
  ) -> Self {
    .init(subscriptionPeriod: subscriptionPeriod)
  }
}

extension Product.FormatStyle.Price: Codable {}

extension Product.FormatStyle.Price: Equatable {}

extension Product.FormatStyle.Price: Sendable {}

extension Product.FormatStyle.Price: Hashable {}

// MARK: - Product.SubscriptionPeriod

extension Product.SubscriptionPeriod {
  public struct FormatStyle {
    public init() {}
  }
}

extension Product.SubscriptionPeriod.FormatStyle: Foundation.FormatStyle {
  public func format(_ value: Product.SubscriptionPeriod) -> String {
    switch (value.unit, value.value) {
    case (.year, 1):
      return value.unit.formatted(number: .singular)
    case (.year, _):
      let unitString = value.unit.formatted(number: .plural)
      return "\(value.value) \(unitString)"
    case (.month, 1):
      return value.unit.formatted(number: .singular)
    case (.month, _):
      let unitString = value.unit.formatted(number: .plural)
      return "\(value.value) \(unitString)"
    case (.week, 1):
      let unit = Product.SubscriptionPeriod.Unit.day
      let unitString = unit.formatted(number: .plural)
      return "7 \(unitString)"
    case (.week, _):
      let unitString = value.unit.formatted(number: .plural)
      return "\(value.value) \(unitString)"
    case (.day, 1):
      return value.unit.formatted(number: .singular)
    case (.day, _):
      let unitString = value.unit.formatted(number: .plural)
      return "\(value.value) \(unitString)"
    }
  }
}

extension Product.SubscriptionPeriod {
  public func formatted() -> String {
    Self.FormatStyle().format(self)
  }

  public func formatted<F: Foundation.FormatStyle>(
    _ style: F
  ) -> F.FormatOutput where F.FormatInput == Product.SubscriptionPeriod {
    style.format(self)
  }
}

extension Product.SubscriptionPeriod.FormatStyle: Codable {}

extension Product.SubscriptionPeriod.FormatStyle: Equatable {}

extension Product.SubscriptionPeriod.FormatStyle: Sendable {}

extension Product.SubscriptionPeriod.FormatStyle: Hashable {}

// MARK: - Product.SubscriptionOffer

extension Product.SubscriptionOffer {
  public struct FormatStyle {
    public init() {}
  }
}

extension Product.SubscriptionOffer.FormatStyle: Foundation.FormatStyle {
  public func format(_ value: Product.SubscriptionOffer) -> String {
    switch value.paymentMode {
    case .freeTrial where value.period.value > 1:
      return L10n.Product.SubscriptionOffer.freeTrial(
        value.period.value,
        value.period.unit.formatted(number: .plural)
      )
    case .freeTrial:
      return L10n.Product.SubscriptionOffer.freeTrial(
        value.period.value,
        value.period.unit.formatted(number: .singular)
      )
    case .payAsYouGo:
      assertionFailure("unsupported PaymentMode.payAsYouGo")
      return ""
    case .payUpFront:
      assertionFailure("unsupported PaymentMode.payUpFront")
      return ""
    }
  }
}

extension Product.SubscriptionOffer {
  public func formatted() -> String {
    Self.FormatStyle().format(self)
  }

  public func formatted<F: Foundation.FormatStyle>(
    _ style: F
  ) -> F.FormatOutput where F.FormatInput == Product.SubscriptionOffer {
    style.format(self)
  }
}

extension Product.SubscriptionOffer.FormatStyle: Codable {}

extension Product.SubscriptionOffer.FormatStyle: Equatable {}

extension Product.SubscriptionOffer.FormatStyle: Sendable {}

extension Product.SubscriptionOffer.FormatStyle: Hashable {}

// MARK: - Product.SubscriptionPeriod.Unit

extension Product.SubscriptionPeriod.Unit {
  public struct FormatStyle {
    var number: Morphology.GrammaticalNumber

    public init(
      number: Morphology.GrammaticalNumber
    ) {
      self.number = number
    }
  }
}

extension Product.SubscriptionPeriod.Unit.FormatStyle: Foundation.FormatStyle {
  public func format(_ value: Product.SubscriptionPeriod.Unit) -> String {
    switch (number, value) {
    case (.singular, .day):
      return L10n.Product.SubscriptionPeriod.Unit.day
    case (_, .day):
      return L10n.Product.SubscriptionPeriod.Unit.days
    case (.singular, .week):
      return L10n.Product.SubscriptionPeriod.Unit.week
    case (_, .week):
      return L10n.Product.SubscriptionPeriod.Unit.weeks
    case (.singular, .month):
      return L10n.Product.SubscriptionPeriod.Unit.month
    case (_, .month):
      return L10n.Product.SubscriptionPeriod.Unit.months
    case (.singular, .year):
      return L10n.Product.SubscriptionPeriod.Unit.year
    case (_, .year):
      return L10n.Product.SubscriptionPeriod.Unit.years
    }
  }
}

extension Product.SubscriptionPeriod.Unit {
  public func formatted(
    number: Morphology.GrammaticalNumber = .singular
  ) -> String {
    Self.FormatStyle(number: number).format(self)
  }

  public func formatted<F: Foundation.FormatStyle>(
    _ style: F
  ) -> F.FormatOutput where F.FormatInput == Product.SubscriptionPeriod.Unit {
    style.format(self)
  }
}

extension Product.SubscriptionPeriod.Unit.FormatStyle: Codable {}

extension Product.SubscriptionPeriod.Unit.FormatStyle: Equatable {}

extension Product.SubscriptionPeriod.Unit.FormatStyle: Sendable {}

extension Product.SubscriptionPeriod.Unit.FormatStyle: Hashable {}

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
