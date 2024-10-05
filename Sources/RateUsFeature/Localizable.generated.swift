// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Rate Us
  internal static let rateUs = L10n.tr("Localizable", "rateUs", fallback: "Rate Us")
  internal enum RateUs {
    /// Share
    internal static let contactUsAction = L10n.tr("Localizable", "rateUs.contactUsAction", fallback: "Share")
    /// Cancel
    internal static let dismissAction = L10n.tr("Localizable", "rateUs.dismissAction", fallback: "Cancel")
    /// No, I don’t
    internal static let doNotLoveAction = L10n.tr("Localizable", "rateUs.doNotLoveAction", fallback: "No, I don’t")
    /// Yes, I love it! 😍
    internal static let loveAction = L10n.tr("Localizable", "rateUs.loveAction", fallback: "Yes, I love it! 😍")
    /// Share
    internal static let shareAction = L10n.tr("Localizable", "rateUs.shareAction", fallback: "Share")
    /// Love the App?
    internal static let title = L10n.tr("Localizable", "rateUs.title", fallback: "Love the App?")
    internal enum DoNotLove {
      /// Please share your feedback to help us improve the app
      internal static let subtitle = L10n.tr("Localizable", "rateUs.doNotLove.subtitle", fallback: "Please share your feedback to help us improve the app")
      /// We are so sorry 😔
      internal static let title = L10n.tr("Localizable", "rateUs.doNotLove.title", fallback: "We are so sorry 😔")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: any CVarArg..., fallback value: String) -> String {
    let format = Bundle.module.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
