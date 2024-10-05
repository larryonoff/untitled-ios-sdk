import Combine
import Dependencies
import DuckLogging
import DuckUserIdentifierClient

extension PurchasesClient {
  public static func liveToggle(
    analytics: AnalyticsClient,
    userIdentifier: UserIdentifierGenerator
  ) -> Self {
    let impl = PurchasesClientImpl(
      analytics: analytics,
      userIdentifier: userIdentifier
    )

    let purchases = CurrentValueSubject<Purchases, Never>(
      Purchases(isPremium: false)
    )

    return PurchasesClient(
      initialize: {
        impl.initialize()
      },
      paywallByID: { id in
        impl.paywall(by: id)
      },
      purchase: { _ in
        purchases.value.isPremium.toggle()
        return .success(purchases.value)
      },
      restorePurhases: {
        purchases.value.isPremium.toggle()
        return .success(purchases.value)
      },
      purchases: {
        purchases.value
      },
      purchasesUpdates: {
        purchases.values.eraseToStream()
      },
      receipt: {
        try impl.receipt()
      },
      requestReview: {
        await impl.requestReview()
      },
      reset: {
        try await impl.reset()
      },
      setFallbackPaywalls: {
        try await impl.setFallbackPaywalls(fileURL: $0)
      },
      logPaywall: {
        try await impl.log($)
      }
    )
  }
}
