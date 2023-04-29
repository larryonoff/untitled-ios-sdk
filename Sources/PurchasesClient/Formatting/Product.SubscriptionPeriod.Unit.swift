import Foundation

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
  public func format(
    _ value: Product.SubscriptionPeriod.Unit
  ) -> String {
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
