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
    public enum Notation {
      case automatic
      case compactName
      case shortened
    }

    public struct Price {
      var subscriptionPeriod: Product.SubscriptionPeriod?
      var subscriptionPeriodUnitStyle: Product.SubscriptionPeriod.FormatStyle.UnitStyle

      public init(
        subscriptionPeriod: Product.SubscriptionPeriod?,
        subscriptionPeriodUnitStyle: Product.SubscriptionPeriod.FormatStyle.UnitStyle = .complete
      ) {
        self.subscriptionPeriod = subscriptionPeriod
        self.subscriptionPeriodUnitStyle = subscriptionPeriodUnitStyle
      }

      public func subscriptionPeriodUnitStyle(
        _ subscriptionPeriodUnitStyle: Product.SubscriptionPeriod.FormatStyle.UnitStyle
      ) -> Self {
        .init(
          subscriptionPeriod: subscriptionPeriod,
          subscriptionPeriodUnitStyle: subscriptionPeriodUnitStyle
        )
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
      let subscriptionPeriodString = subscriptionPeriod
        .formatted(unitStyle: subscriptionPeriodUnitStyle)

      let separator: String
      switch subscriptionPeriodUnitStyle {
      case .complete, .recurrent:
        separator = " / "
      case .shortened:
        separator = "/"
      }

      return [priceString, subscriptionPeriodString]
        .compactMap { $0 }
        .joined(separator: separator)
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

extension Product.FormatStyle.Notation: Codable {}

extension Product.FormatStyle.Notation: Equatable {}

extension Product.FormatStyle.Notation: Sendable {}

extension Product.FormatStyle.Notation: Hashable {}

// MARK: - Product.SubscriptionPeriod

extension Product.SubscriptionPeriod {
  public struct FormatStyle {
    public enum UnitStyle {
      case complete
      case shortened
      case recurrent
    }

    var unitStyle: UnitStyle
    var unitsCollapsed: [Product.SubscriptionPeriod.Unit]
    var unitsExpanded: [Product.SubscriptionPeriod.Unit]

    public init(
      unitStyle: UnitStyle = .complete,
      unitsCollapsed: [Product.SubscriptionPeriod.Unit] = [],
      unitsExpanded: [Product.SubscriptionPeriod.Unit] = []
    ) {
      self.unitStyle = unitStyle
      self.unitsCollapsed = unitsCollapsed
      self.unitsExpanded = unitsExpanded
    }

    public func unitStyle(
      _ unitStyle: UnitStyle
    ) -> Self {
      .init(
        unitStyle: unitStyle,
        unitsCollapsed: unitsCollapsed,
        unitsExpanded: unitsExpanded
      )
    }

    public func units(
      collapsed units: [Product.SubscriptionPeriod.Unit]
    ) -> Self {
      .init(
        unitStyle: unitStyle,
        unitsCollapsed: units,
        unitsExpanded: unitsExpanded
      )
    }

    public func units(
      expanded units: [Product.SubscriptionPeriod.Unit]
    ) -> Self {
      .init(
        unitStyle: unitStyle,
        unitsCollapsed: unitsCollapsed,
        unitsExpanded: units
      )
    }
  }
}

extension Product.SubscriptionPeriod.FormatStyle: Foundation.FormatStyle {
  public func format(_ value: Product.SubscriptionPeriod) -> String {
    func _oneValueString(
      unitStyle: UnitStyle
    ) -> String? {
      (unitStyle == .complete || unitStyle == .shortened) ? nil : "1"
    }

    let valueString: String?
    let unitString: String

    switch (value.unit, value.value) {
    case (.year, 1) where unitsExpanded.contains(.year):
      valueString = "12"
      unitString = Product.SubscriptionPeriod.Unit.month.formatted(
        style: unitStyle,
        number: .plural
      )
    case (.year, 1):
      valueString = _oneValueString(unitStyle: unitStyle)
      unitString = value.unit.formatted(
        style: unitStyle,
        number: .singular
      )
    case (.year, _):
      valueString = "\(value.value)"
      unitString = value.unit.formatted(
        style: unitStyle,
        number: .plural
      )
    case (.month, 1):
      valueString = _oneValueString(unitStyle: unitStyle)
      unitString = value.unit.formatted(
        style: unitStyle,
        number: .singular
      )
    case (.month, 12) where unitsCollapsed.contains(.month):
      valueString = _oneValueString(unitStyle: unitStyle)
      unitString = Product.SubscriptionPeriod.Unit.year.formatted(
        style: unitStyle,
        number: .singular
      )
    case (.month, _):
      valueString = "\(value.value)"
      unitString = value.unit.formatted(
        style: unitStyle,
        number: .plural
      )
    case (.week, 1) where unitsExpanded.contains(.week):
      valueString = "7"
      unitString = Product.SubscriptionPeriod.Unit.day.formatted(
        style: unitStyle,
        number: .plural
      )
    case (.week, 1):
      valueString = _oneValueString(unitStyle: unitStyle)
      unitString = value.unit.formatted(
        style: unitStyle,
        number: .plural
      )
    case (.week, _):
      valueString = "\(value.value)"
      unitString = value.unit.formatted(
        style: unitStyle,
        number: .plural
      )
    case (.day, 1):
      valueString = _oneValueString(unitStyle: unitStyle)
      unitString = value.unit.formatted(
        style: unitStyle,
        number: .singular
      )
    case (.day, 7) where unitsCollapsed.contains(.day):
      valueString = _oneValueString(unitStyle: unitStyle)
      unitString = Product.SubscriptionPeriod.Unit.week.formatted(
        style: unitStyle,
        number: .plural
      )
    case (.day, _):
      valueString = "\(value.value)"
      unitString = value.unit.formatted(
        style: unitStyle,
        number: .plural
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
    unitsExpanded: [Product.SubscriptionPeriod.Unit] = []
  ) -> String {
    Self.FormatStyle(
      unitStyle: unitStyle,
      unitsCollapsed: unitsCollapsed,
      unitsExpanded: unitsExpanded
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
    case (_, .day, .complete):
      return L10n.Product.SubscriptionPeriod.Unit.days
    case (_, .day, .shortened):
      return L10n.Product.SubscriptionPeriod.Unit.Day.compactName
    case (_, .day, .recurrent):
      return L10n.Product.SubscriptionPeriod.Unit.Day.recurrent
    case (.singular, .week, .complete):
      return L10n.Product.SubscriptionPeriod.Unit.week
    case (_, .week, .complete):
      return L10n.Product.SubscriptionPeriod.Unit.weeks
    case (_, .week, .shortened):
      return L10n.Product.SubscriptionPeriod.Unit.Week.compactName
    case (_, .week, .recurrent):
      return L10n.Product.SubscriptionPeriod.Unit.Week.recurrent
    case (.singular, .month, .complete):
      return L10n.Product.SubscriptionPeriod.Unit.month
    case (_, .month, .complete):
      return L10n.Product.SubscriptionPeriod.Unit.months
    case (_, .month, .shortened):
      return L10n.Product.SubscriptionPeriod.Unit.Month.compactName
    case (_, .month, .recurrent):
      return L10n.Product.SubscriptionPeriod.Unit.Month.recurrent
    case (.singular, .year, .complete):
      return L10n.Product.SubscriptionPeriod.Unit.year
    case (_, .year, .complete):
      return L10n.Product.SubscriptionPeriod.Unit.years
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
