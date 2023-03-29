// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Product {
    internal enum SubscriptionOffer {
      /// %d-%@ free trial
      internal static func freeTrial(_ p1: Int, _ p2: Any) -> String {
        return L10n.tr("Localizable", "product.subscriptionOffer.freeTrial", p1, String(describing: p2), fallback: "%d-%@ free trial")
      }
    }
    internal enum SubscriptionPeriod {
      internal enum Unit {
        /// day
        internal static let day = L10n.tr("Localizable", "product.subscriptionPeriod.unit.day", fallback: "day")
        /// month
        internal static let month = L10n.tr("Localizable", "product.subscriptionPeriod.unit.month", fallback: "month")
        /// week
        internal static let week = L10n.tr("Localizable", "product.subscriptionPeriod.unit.week", fallback: "week")
        /// year
        internal static let year = L10n.tr("Localizable", "product.subscriptionPeriod.unit.year", fallback: "year")
        internal enum Day {
          /// d
          internal static let compactName = L10n.tr("Localizable", "product.subscriptionPeriod.unit.day.compactName", fallback: "d")
          /// days
          internal static let plural = L10n.tr("Localizable", "product.subscriptionPeriod.unit.day.plural", fallback: "days")
          /// days
          internal static let plural2 = L10n.tr("Localizable", "product.subscriptionPeriod.unit.day.plural2", fallback: "days")
          /// daily
          internal static let recurrent = L10n.tr("Localizable", "product.subscriptionPeriod.unit.day.recurrent", fallback: "daily")
        }
        internal enum Month {
          /// mo
          internal static let compactName = L10n.tr("Localizable", "product.subscriptionPeriod.unit.month.compactName", fallback: "mo")
          /// months
          internal static let plural = L10n.tr("Localizable", "product.subscriptionPeriod.unit.month.plural", fallback: "months")
          /// months
          internal static let plural2 = L10n.tr("Localizable", "product.subscriptionPeriod.unit.month.plural2", fallback: "months")
          /// monthly
          internal static let recurrent = L10n.tr("Localizable", "product.subscriptionPeriod.unit.month.recurrent", fallback: "monthly")
        }
        internal enum Week {
          /// w
          internal static let compactName = L10n.tr("Localizable", "product.subscriptionPeriod.unit.week.compactName", fallback: "w")
          /// weeks
          internal static let plural = L10n.tr("Localizable", "product.subscriptionPeriod.unit.week.plural", fallback: "weeks")
          /// weeks
          internal static let plural2 = L10n.tr("Localizable", "product.subscriptionPeriod.unit.week.plural2", fallback: "weeks")
          /// weekly
          internal static let recurrent = L10n.tr("Localizable", "product.subscriptionPeriod.unit.week.recurrent", fallback: "weekly")
        }
        internal enum Year {
          /// y
          internal static let compactName = L10n.tr("Localizable", "product.subscriptionPeriod.unit.year.compactName", fallback: "y")
          /// years
          internal static let plural = L10n.tr("Localizable", "product.subscriptionPeriod.unit.year.plural", fallback: "years")
          /// years
          internal static let plural2 = L10n.tr("Localizable", "product.subscriptionPeriod.unit.year.plural2", fallback: "years")
          /// annually
          internal static let recurrent = L10n.tr("Localizable", "product.subscriptionPeriod.unit.year.recurrent", fallback: "annually")
        }
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = Bundle.module.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
