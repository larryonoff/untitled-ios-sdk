// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum CancelIntroductoryOffer {
    /// The free trial is a one-time offer. If you decline it, you won’t be activate it later
    internal static let message = L10n.tr("Localizable", "cancelIntroductoryOffer.message", fallback: "The free trial is a one-time offer. If you decline it, you won’t be activate it later")
    /// Are you sure?
    internal static let title = L10n.tr("Localizable", "cancelIntroductoryOffer.title", fallback: "Are you sure?")
    internal enum Action {
      /// Cancel
      internal static let cancel = L10n.tr("Localizable", "cancelIntroductoryOffer.action.cancel", fallback: "Cancel")
      /// Reject free trial
      internal static let reject = L10n.tr("Localizable", "cancelIntroductoryOffer.action.reject", fallback: "Reject free trial")
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
