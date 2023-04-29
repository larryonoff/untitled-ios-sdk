import Foundation

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
    priceLocale: Locale,
    roundingRule: Product.FormatStyle.RoundingRule = .down
  ) -> String? {
    priceFormatter.locale = priceLocale
    priceFormatter.roundingMode = roundingRule.toNumberFormatterRoundingMode

    return priceFormatter.string(from: price)
  }
}

// MARK: - Product

extension Product {
  public enum FormatStyle {
    public struct Price {
      public enum Separator: String {
        case slash = "/"
        case omitted = ""
      }

      public enum SubscriptionPeriodStyle: String {
        case automatic
        case omitted
      }

      var roundingRule: RoundingRule
      var separator: Separator
      var subscriptionPeriod: Product.SubscriptionPeriod?
      var subscriptionPeriodStyle: SubscriptionPeriodStyle
      var subscriptionPeriodUnitStyle: Product.SubscriptionPeriod.FormatStyle.UnitStyle

      public init(
        roundingRule: RoundingRule = .down,
        separator: Separator = .slash,
        subscriptionPeriod: Product.SubscriptionPeriod?,
        subscriptionPeriodStyle: SubscriptionPeriodStyle = .automatic,
        subscriptionPeriodUnitStyle: Product.SubscriptionPeriod.FormatStyle.UnitStyle = .complete
      ) {
        self.roundingRule = roundingRule
        self.separator = separator
        self.subscriptionPeriod = subscriptionPeriod
        self.subscriptionPeriodStyle = subscriptionPeriodStyle
        self.subscriptionPeriodUnitStyle = subscriptionPeriodUnitStyle
      }

      public func roundingRule(
        _ roundingRule: RoundingRule
      ) -> Self {
        modify { $0.roundingRule = roundingRule }
      }

      public func separator(
        _ separator: Separator
      ) -> Self {
        modify { $0.separator = separator }
      }

      public func subscriptionPeriodStyle(
        _ style: SubscriptionPeriodStyle
      ) -> Self {
        modify { $0.subscriptionPeriodStyle = style }
      }

      public func subscriptionPeriodUnitStyle(
        _ style: Product.SubscriptionPeriod.FormatStyle.UnitStyle
      ) -> Self {
        modify { $0.subscriptionPeriodUnitStyle = style }
      }

      func modify(
        _ transform: (inout Self) throws -> Void
      ) rethrows -> Self {
        var new = self
        try transform(&new)
        return new
      }
    }

    public typealias RoundingRule = FloatingPointRoundingRule
  }
}

extension Product.FormatStyle.Price: Foundation.FormatStyle {
  public func format(_ value: Product) -> String {
    if let subscription = value.subscription {
      var price = value.price
      var subscriptionPeriod = subscription.subscriptionPeriod

      if let destinationPeriod = self.subscriptionPeriod {
        price = subscription
          .subscriptionPeriod
          .convertPrice(
            value.price,
            to: destinationPeriod
          )
        subscriptionPeriod = destinationPeriod
      }

      let priceString = Product.displayPrice(
        price,
        priceLocale: value.priceLocale,
        roundingRule: roundingRule
      )

      let subscriptionPeriodString: String?

      switch subscriptionPeriodStyle {
      case .automatic:
        subscriptionPeriodString = subscriptionPeriod
          .formatted(unitStyle: subscriptionPeriodUnitStyle)
      case .omitted:
        subscriptionPeriodString = nil
      }

      var _separator: String = " "

      if separator != .omitted {
        switch subscriptionPeriodUnitStyle {
        case .complete, .recurrent:
          _separator = " \(separator.rawValue) "
        case .shortened:
          _separator = separator.rawValue
        }
      }

      return [priceString, subscriptionPeriodString]
        .compactMap { $0 }
        .joined(separator: _separator)
    }

    return Product.displayPrice(
      value.price,
      priceLocale: value.priceLocale,
      roundingRule: roundingRule
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

extension Product.FormatStyle.Price.Separator: Codable {}

extension Product.FormatStyle.Price.Separator: Equatable {}

extension Product.FormatStyle.Price.Separator: Sendable {}

extension Product.FormatStyle.Price.Separator: Hashable {}

extension Product.FormatStyle.Price.SubscriptionPeriodStyle: Codable {}

extension Product.FormatStyle.Price.SubscriptionPeriodStyle: Equatable {}

extension Product.FormatStyle.Price.SubscriptionPeriodStyle: Sendable {}

extension Product.FormatStyle.Price.SubscriptionPeriodStyle: Hashable {}

extension Product.FormatStyle.RoundingRule {
  var toNumberFormatterRoundingMode: NumberFormatter.RoundingMode {
    switch self {
    case .awayFromZero:
      return .up
    case .down:
      return .down
    case .toNearestOrAwayFromZero:
      return .halfUp
    case .toNearestOrEven:
      return .halfEven
    case .towardZero:
      return .halfDown
    case .up:
      return .up
    @unknown default:
      assertionFailure(
        "Product.FormatStyle.RoundingRule.(@unknown default, value: \(self))"
      )
      return .up
    }
  }
}

private let discountFormatter: NumberFormatter = {
  let formatter = NumberFormatter()
  formatter.numberStyle = .percent
  return formatter
}()

private let priceFormatter = PriceFormatter()
