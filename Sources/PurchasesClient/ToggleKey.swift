import Combine
import Dependencies
import DuckAnalyticsClient
import DuckLogging
import DuckUserIdentifierClient
import DuckUserSettings

extension PurchasesClient {
  public static func liveToggle(
    analytics: AnalyticsClient,
    userIdentifier: UserIdentifierGenerator,
    userSettings: UserSettingsClient
  ) -> Self {
    var client = Self.live(
      analytics: analytics,
      userIdentifier: userIdentifier,
      userSettings: userSettings
    )

    let purchases = UncheckedSendable(
      CurrentValueSubject<Purchases, any Error>(
        Purchases(
          isPremium: false,
          isEligibleForIntroductoryOffer: true
        )
      )
    )

    client.purchases = { purchases.value.value }

    client.purchasesUpdates = {
      UncheckedSendable(
        purchases
          .value
          .dropFirst()
          .values
      )
      .eraseToStream()
    }

    client.purchase = { @Sendable _ in
      var newValue = purchases.value.value
      newValue.isPremium = true

      purchases.value.send(newValue)

      return .success(newValue)
    }

    return client
  }
}
