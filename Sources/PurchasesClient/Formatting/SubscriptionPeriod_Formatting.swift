import Foundation

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
  public func format(
    _ value: Product.SubscriptionPeriod
  ) -> String {
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
