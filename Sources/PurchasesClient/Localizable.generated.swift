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
        /// days
        internal static let days = L10n.tr("Localizable", "product.subscriptionPeriod.unit.days", fallback: "days")
        /// month
        internal static let month = L10n.tr("Localizable", "product.subscriptionPeriod.unit.month", fallback: "month")
        /// months
        internal static let months = L10n.tr("Localizable", "product.subscriptionPeriod.unit.months", fallback: "months")
        /// week
        internal static let week = L10n.tr("Localizable", "product.subscriptionPeriod.unit.week", fallback: "week")
        /// weeks
        internal static let weeks = L10n.tr("Localizable", "product.subscriptionPeriod.unit.weeks", fallback: "weeks")
        /// year
        internal static let year = L10n.tr("Localizable", "product.subscriptionPeriod.unit.year", fallback: "year")
        /// years
        internal static let years = L10n.tr("Localizable", "product.subscriptionPeriod.unit.years", fallback: "years")
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
