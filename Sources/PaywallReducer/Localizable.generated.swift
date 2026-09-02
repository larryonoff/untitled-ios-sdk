// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen
// Do not edit. Change the localization source or the SwiftGen template instead.

import Foundation

// MARK: - Localized Strings


extension LocalizedStringResource {
  internal enum CancelIntroductoryOffer {
    /// Free trial is a limited-time offer. Activate it now!
    internal static var message: LocalizedStringResource {
      LocalizedStringResource(
        "cancelIntroductoryOffer.message",
        defaultValue: "Free trial is a limited-time offer. Activate it now!",
        table: "Localizable",
        bundle: #bundle
      )
    }
    /// Are you sure?
    internal static var title: LocalizedStringResource {
      LocalizedStringResource(
        "cancelIntroductoryOffer.title",
        defaultValue: "Are you sure?",
        table: "Localizable",
        bundle: #bundle
      )
    }
    internal enum Action {
      /// Cancel
      internal static var cancel: LocalizedStringResource {
        LocalizedStringResource(
          "cancelIntroductoryOffer.action.cancel",
          defaultValue: "Cancel",
          table: "Localizable",
          bundle: #bundle
        )
      }
      /// Reject my free trial
      internal static var reject: LocalizedStringResource {
        LocalizedStringResource(
          "cancelIntroductoryOffer.action.reject",
          defaultValue: "Reject my free trial",
          table: "Localizable",
          bundle: #bundle
        )
      }
    }
  }
  internal enum Failure {
    internal enum Action {
      /// OK
      internal static var ok: LocalizedStringResource {
        LocalizedStringResource(
          "failure.action.ok",
          defaultValue: "OK",
          table: "Localizable",
          bundle: #bundle
        )
      }
      /// Try Again
      internal static var retry: LocalizedStringResource {
        LocalizedStringResource(
          "failure.action.retry",
          defaultValue: "Try Again",
          table: "Localizable",
          bundle: #bundle
        )
      }
    }
  }
}
