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

// MARK: - Product.SubscriptionPeriod

extension Product.SubscriptionPeriod {
  public struct FormatStyle {
    public enum UnitStyle {
      case complete
      case shortened
      case recurrent
    }

    public enum ValueDisplayStrategy {
      case automatic
      case always
    }

    var unitStyle: UnitStyle
    var unitsCollapsed: [Product.SubscriptionPeriod.Unit]
    var unitsExpanded: [Product.SubscriptionPeriod.Unit]
    var valueDisplayStrategy: ValueDisplayStrategy

    public init(
      unitStyle: UnitStyle = .complete,
      unitsCollapsed: [Product.SubscriptionPeriod.Unit] = [],
      unitsExpanded: [Product.SubscriptionPeriod.Unit] = [],
      valueDisplayStrategy: ValueDisplayStrategy = .automatic
    ) {
      self.unitStyle = unitStyle
      self.unitsCollapsed = unitsCollapsed
      self.unitsExpanded = unitsExpanded
      self.valueDisplayStrategy = valueDisplayStrategy
    }

    public func unitStyle(
      _ unitStyle: UnitStyle
    ) -> Self {
      modify { $0.unitStyle = unitStyle }
    }

    public func units(
      collapsed units: [Product.SubscriptionPeriod.Unit]
    ) -> Self {
      modify { $0.unitsCollapsed = units }
    }

    public func units(
      expanded units: [Product.SubscriptionPeriod.Unit]
    ) -> Self {
      modify { $0.unitsExpanded = units }
    }

    public func valueDisplayStrategy(
      _ valueDisplayStrategy: ValueDisplayStrategy
    ) -> Self {
      modify { $0.valueDisplayStrategy = valueDisplayStrategy }
    }

    func modify(
      _ transform: (inout Self) throws -> Void
    ) rethrows -> Self {
      var new = self
      try transform(&new)
      return new
    }
  }
}

extension Product.SubscriptionPeriod.FormatStyle: Foundation.FormatStyle {
  public func format(_ value: Product.SubscriptionPeriod) -> String {
    func _oneValueString(
      unitStyle: UnitStyle,
      valueDisplayStrategy: ValueDisplayStrategy
    ) -> String? {
      switch valueDisplayStrategy {
       case .automatic:
         return nil
       case .always:
         return "1"
       }
    }

    let valueString: String?
    let unitString: String

    switch (value.unit, value.value) {
    case (.year, 1) where unitsExpanded.contains(.year):
      valueString = "12"
      unitString = Product.SubscriptionPeriod.Unit.month.formatted(
        style: unitStyle,
        number: 12.grammaticalNumber
      )
    case (.year, 1):
      valueString = _oneValueString(
        unitStyle: unitStyle,
        valueDisplayStrategy: valueDisplayStrategy
      )
      unitString = value.unit.formatted(
        style: unitStyle,
        number: value.value.grammaticalNumber
      )
    case (.year, _):
      valueString = "\(value.value)"
      unitString = value.unit.formatted(
        style: unitStyle,
        number: value.value.grammaticalNumber
      )
    case (.month, 1):
      valueString = _oneValueString(
        unitStyle: unitStyle,
        valueDisplayStrategy: valueDisplayStrategy
      )
      unitString = value.unit.formatted(
        style: unitStyle,
        number: value.value.grammaticalNumber
      )
    case (.month, 12) where unitsCollapsed.contains(.month):
      valueString = _oneValueString(
        unitStyle: unitStyle,
        valueDisplayStrategy: valueDisplayStrategy
      )
      unitString = Product.SubscriptionPeriod.Unit.year.formatted(
        style: unitStyle,
        number: 1.grammaticalNumber
      )
    case (.month, _):
      valueString = "\(value.value)"
      unitString = value.unit.formatted(
        style: unitStyle,
        number: value.value.grammaticalNumber
      )
    case (.week, 1) where unitsExpanded.contains(.week):
      valueString = "7"
      unitString = Product.SubscriptionPeriod.Unit.day.formatted(
        style: unitStyle,
        number: 7.grammaticalNumber
      )
    case (.week, 1):
      valueString = _oneValueString(
        unitStyle: unitStyle,
        valueDisplayStrategy: valueDisplayStrategy
      )
      unitString = value.unit.formatted(
        style: unitStyle,
        number: value.value.grammaticalNumber
      )
    case (.week, _):
      valueString = "\(value.value)"
      unitString = value.unit.formatted(
        style: unitStyle,
        number: value.value.grammaticalNumber
      )
    case (.day, 1):
      valueString = _oneValueString(
        unitStyle: unitStyle,
        valueDisplayStrategy: valueDisplayStrategy
      )
      unitString = value.unit.formatted(
        style: unitStyle,
        number: 1.grammaticalNumber
      )
    case (.day, 7) where unitsCollapsed.contains(.day):
      valueString = _oneValueString(
        unitStyle: unitStyle,
        valueDisplayStrategy: valueDisplayStrategy
      )
      unitString = Product.SubscriptionPeriod.Unit.week.formatted(
        style: unitStyle,
        number: 1.grammaticalNumber
      )
    case (.day, _):
      valueString = "\(value.value)"
      unitString = value.unit.formatted(
        style: unitStyle,
        number: value.value.grammaticalNumber
      )
    }

    return [valueString, unitString]
      .compactMap { $0 }
      .joined(separator: " ")
  }
}

extension Product.SubscriptionPeriod {
  public func formatted(
    unitStyle: FormatStyle.UnitStyle = .complete,
    unitsCollapsed: [Product.SubscriptionPeriod.Unit] = [],
    unitsExpanded: [Product.SubscriptionPeriod.Unit] = [],
    valueDisplayStrategy: FormatStyle.ValueDisplayStrategy = .automatic
  ) -> String {
    Self.FormatStyle(
      unitStyle: unitStyle,
      unitsCollapsed: unitsCollapsed,
      unitsExpanded: unitsExpanded,
      valueDisplayStrategy: valueDisplayStrategy
    )
    .format(self)
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

extension Product.SubscriptionPeriod.FormatStyle.UnitStyle: Codable {}

extension Product.SubscriptionPeriod.FormatStyle.UnitStyle: Equatable {}

extension Product.SubscriptionPeriod.FormatStyle.UnitStyle: Sendable {}

extension Product.SubscriptionPeriod.FormatStyle.UnitStyle: Hashable {}

extension Product.SubscriptionPeriod.FormatStyle.ValueDisplayStrategy: Codable {}

extension Product.SubscriptionPeriod.FormatStyle.ValueDisplayStrategy: Equatable {}

extension Product.SubscriptionPeriod.FormatStyle.ValueDisplayStrategy: Sendable {}

extension Product.SubscriptionPeriod.FormatStyle.ValueDisplayStrategy: Hashable {}

// MARK: - Product.SubscriptionOffer

extension Product.SubscriptionOffer {
  public struct FormatStyle {
    public init() {}
  }
}

extension Product.SubscriptionOffer.FormatStyle: Foundation.FormatStyle {
  public func format(_ value: Product.SubscriptionOffer) -> String {
    switch value.paymentMode {
    case .freeTrial:
      return L10n.Product.SubscriptionOffer.freeTrial(
        value.period.value,
        value.period.unit.formatted(
          number: value.period.value.grammaticalNumber
        )
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
    var style: Product.SubscriptionPeriod.FormatStyle.UnitStyle
    var number: Morphology.GrammaticalNumber

    public init(
      style: Product.SubscriptionPeriod.FormatStyle.UnitStyle = .complete,
      number: Morphology.GrammaticalNumber = .singular
    ) {
      self.style = style
      self.number = number
    }

    public func style(
      _ style: Product.SubscriptionPeriod.FormatStyle.UnitStyle
    ) -> Self {
      .init(
        style: style,
        number: number
      )
    }

    public func number(
      _ number: Morphology.GrammaticalNumber
    ) -> Self {
      .init(
        style: style,
        number: number
      )
    }
  }
}

extension Product.SubscriptionPeriod.Unit.FormatStyle: Foundation.FormatStyle {
  public func format(_ value: Product.SubscriptionPeriod.Unit) -> String {
    switch (number, value, style) {
    case (.singular, .day, .complete):
      return L10n.Product.SubscriptionPeriod.Unit.day
    case (.plural, .day, .complete):
      return L10n.Product.SubscriptionPeriod.Unit.Day.plural
    case (_, .day, .complete):
      return L10n.Product.SubscriptionPeriod.Unit.Day.plural2
    case (_, .day, .shortened):
      return L10n.Product.SubscriptionPeriod.Unit.Day.compactName
    case (_, .day, .recurrent):
      return L10n.Product.SubscriptionPeriod.Unit.Day.recurrent
    case (.singular, .week, .complete):
      return L10n.Product.SubscriptionPeriod.Unit.week
    case (.plural, .week, .complete):
      return L10n.Product.SubscriptionPeriod.Unit.Week.plural
    case (_, .week, .complete):
      return L10n.Product.SubscriptionPeriod.Unit.Week.plural2
    case (_, .week, .shortened):
      return L10n.Product.SubscriptionPeriod.Unit.Week.compactName
    case (_, .week, .recurrent):
      return L10n.Product.SubscriptionPeriod.Unit.Week.recurrent
    case (.singular, .month, .complete):
      return L10n.Product.SubscriptionPeriod.Unit.month
    case (.plural, .month, .complete):
      return L10n.Product.SubscriptionPeriod.Unit.Month.plural
    case (_, .month, .complete):
      return L10n.Product.SubscriptionPeriod.Unit.Month.plural2
    case (_, .month, .shortened):
      return L10n.Product.SubscriptionPeriod.Unit.Month.compactName
    case (_, .month, .recurrent):
      return L10n.Product.SubscriptionPeriod.Unit.Month.recurrent
    case (.singular, .year, .complete):
      return L10n.Product.SubscriptionPeriod.Unit.year
    case (.plural, .year, .complete):
      return L10n.Product.SubscriptionPeriod.Unit.Year.plural
    case (_, .year, .complete):
      return L10n.Product.SubscriptionPeriod.Unit.Year.plural2
    case (_, .year, .shortened):
      return L10n.Product.SubscriptionPeriod.Unit.Year.compactName
    case (_, .year, .recurrent):
      return L10n.Product.SubscriptionPeriod.Unit.Year.recurrent
    }
  }
}

extension Product.SubscriptionPeriod.Unit {
  public func formatted(
    style: Product.SubscriptionPeriod.FormatStyle.UnitStyle = .complete,
    number: Morphology.GrammaticalNumber = .singular
  ) -> String {
    Self.FormatStyle(
      style: style,
      number: number
    )
    .format(self)
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

extension Int {
  var grammaticalNumber: Morphology.GrammaticalNumber {
    switch abs(self) {
    case 0...1:
      return .singular
    case 1...4:
      return .plural
    default:
      return .pluralTwo
    }
  }
}

private let discountFormatter: NumberFormatter = {
  let formatter = NumberFormatter()
  formatter.numberStyle = .percent
  return formatter
}()

private let priceFormatter = PriceFormatter()
