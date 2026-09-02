// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen
// Do not edit. Change the localization source or the SwiftGen template instead.

import Foundation

// MARK: - Localized Strings


extension LocalizedStringResource {
  internal enum Error {
    internal enum Unknown {
      /// Oops, something went wrong 😔
      internal static var description: LocalizedStringResource {
        LocalizedStringResource(
          "error.unknown.description",
          defaultValue: "Oops, something went wrong 😔",
          table: "Localizable",
          bundle: #bundle
        )
      }
    }
  }
  internal enum Product {
    /// Lifetime
    internal static var lifetime: LocalizedStringResource {
      LocalizedStringResource(
        "product.lifetime",
        defaultValue: "Lifetime",
        table: "Localizable",
        bundle: #bundle
      )
    }
    internal enum SubscriptionOffer {
      /// %d-%@ free trial
      internal static func freeTrial(_ value1: Int
          , _ value2: String
          ) -> LocalizedStringResource {
        LocalizedStringResource(
          "product.subscriptionOffer.freeTrial",
          defaultValue: "\(value1, specifier: "%lld")-\(value2) free trial",
          table: "Localizable",
          bundle: #bundle
        )
      }
      internal enum PaymentMode {
        /// Free Trial
        internal static var freeTrial: LocalizedStringResource {
          LocalizedStringResource(
            "product.subscriptionOffer.paymentMode.freeTrial",
            defaultValue: "Free Trial",
            table: "Localizable",
            bundle: #bundle
          )
        }
        /// Pay as You Go
        internal static var payAsYouGo: LocalizedStringResource {
          LocalizedStringResource(
            "product.subscriptionOffer.paymentMode.payAsYouGo",
            defaultValue: "Pay as You Go",
            table: "Localizable",
            bundle: #bundle
          )
        }
        /// Pay up Front
        internal static var payUpFront: LocalizedStringResource {
          LocalizedStringResource(
            "product.subscriptionOffer.paymentMode.payUpFront",
            defaultValue: "Pay up Front",
            table: "Localizable",
            bundle: #bundle
          )
        }
      }
    }
    internal enum SubscriptionPeriod {
      internal enum Unit {
        /// day
        internal static var day: LocalizedStringResource {
          LocalizedStringResource(
            "product.subscriptionPeriod.unit.day",
            defaultValue: "day",
            table: "Localizable",
            bundle: #bundle
          )
        }
        /// month
        internal static var month: LocalizedStringResource {
          LocalizedStringResource(
            "product.subscriptionPeriod.unit.month",
            defaultValue: "month",
            table: "Localizable",
            bundle: #bundle
          )
        }
        /// week
        internal static var week: LocalizedStringResource {
          LocalizedStringResource(
            "product.subscriptionPeriod.unit.week",
            defaultValue: "week",
            table: "Localizable",
            bundle: #bundle
          )
        }
        /// year
        internal static var year: LocalizedStringResource {
          LocalizedStringResource(
            "product.subscriptionPeriod.unit.year",
            defaultValue: "year",
            table: "Localizable",
            bundle: #bundle
          )
        }
        internal enum Day {
          /// d
          internal static var compactName: LocalizedStringResource {
            LocalizedStringResource(
              "product.subscriptionPeriod.unit.day.compactName",
              defaultValue: "d",
              table: "Localizable",
              bundle: #bundle
            )
          }
          /// days
          internal static var plural: LocalizedStringResource {
            LocalizedStringResource(
              "product.subscriptionPeriod.unit.day.plural",
              defaultValue: "days",
              table: "Localizable",
              bundle: #bundle
            )
          }
          /// days
          internal static var plural2: LocalizedStringResource {
            LocalizedStringResource(
              "product.subscriptionPeriod.unit.day.plural2",
              defaultValue: "days",
              table: "Localizable",
              bundle: #bundle
            )
          }
          /// daily
          internal static var recurrent: LocalizedStringResource {
            LocalizedStringResource(
              "product.subscriptionPeriod.unit.day.recurrent",
              defaultValue: "daily",
              table: "Localizable",
              bundle: #bundle
            )
          }
        }
        internal enum Month {
          /// mo
          internal static var compactName: LocalizedStringResource {
            LocalizedStringResource(
              "product.subscriptionPeriod.unit.month.compactName",
              defaultValue: "mo",
              table: "Localizable",
              bundle: #bundle
            )
          }
          /// months
          internal static var plural: LocalizedStringResource {
            LocalizedStringResource(
              "product.subscriptionPeriod.unit.month.plural",
              defaultValue: "months",
              table: "Localizable",
              bundle: #bundle
            )
          }
          /// months
          internal static var plural2: LocalizedStringResource {
            LocalizedStringResource(
              "product.subscriptionPeriod.unit.month.plural2",
              defaultValue: "months",
              table: "Localizable",
              bundle: #bundle
            )
          }
          /// monthly
          internal static var recurrent: LocalizedStringResource {
            LocalizedStringResource(
              "product.subscriptionPeriod.unit.month.recurrent",
              defaultValue: "monthly",
              table: "Localizable",
              bundle: #bundle
            )
          }
        }
        internal enum Week {
          /// w
          internal static var compactName: LocalizedStringResource {
            LocalizedStringResource(
              "product.subscriptionPeriod.unit.week.compactName",
              defaultValue: "w",
              table: "Localizable",
              bundle: #bundle
            )
          }
          /// weeks
          internal static var plural: LocalizedStringResource {
            LocalizedStringResource(
              "product.subscriptionPeriod.unit.week.plural",
              defaultValue: "weeks",
              table: "Localizable",
              bundle: #bundle
            )
          }
          /// weeks
          internal static var plural2: LocalizedStringResource {
            LocalizedStringResource(
              "product.subscriptionPeriod.unit.week.plural2",
              defaultValue: "weeks",
              table: "Localizable",
              bundle: #bundle
            )
          }
          /// weekly
          internal static var recurrent: LocalizedStringResource {
            LocalizedStringResource(
              "product.subscriptionPeriod.unit.week.recurrent",
              defaultValue: "weekly",
              table: "Localizable",
              bundle: #bundle
            )
          }
        }
        internal enum Year {
          /// y
          internal static var compactName: LocalizedStringResource {
            LocalizedStringResource(
              "product.subscriptionPeriod.unit.year.compactName",
              defaultValue: "y",
              table: "Localizable",
              bundle: #bundle
            )
          }
          /// years
          internal static var plural: LocalizedStringResource {
            LocalizedStringResource(
              "product.subscriptionPeriod.unit.year.plural",
              defaultValue: "years",
              table: "Localizable",
              bundle: #bundle
            )
          }
          /// years
          internal static var plural2: LocalizedStringResource {
            LocalizedStringResource(
              "product.subscriptionPeriod.unit.year.plural2",
              defaultValue: "years",
              table: "Localizable",
              bundle: #bundle
            )
          }
          /// yearly
          internal static var recurrent: LocalizedStringResource {
            LocalizedStringResource(
              "product.subscriptionPeriod.unit.year.recurrent",
              defaultValue: "yearly",
              table: "Localizable",
              bundle: #bundle
            )
          }
        }
      }
    }
  }
  internal enum Purchases {
    internal enum Error {
      internal enum PremiumExpired {
        /// You don't have active subscriptions. Please check your account details
        internal static var description: LocalizedStringResource {
          LocalizedStringResource(
            "purchases.error.premiumExpired.description",
            defaultValue: "You don't have active subscriptions. Please check your account details",
            table: "Localizable",
            bundle: #bundle
          )
        }
      }
    }
  }
}
