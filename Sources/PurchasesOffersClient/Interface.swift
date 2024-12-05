import Dependencies
import DependenciesMacros
import DuckPurchases

extension DependencyValues {
  public var purchasesOffers: PurchasesOffersClient {
    get { self[PurchasesOffersClient.self] }
    set { self[PurchasesOffersClient.self] = newValue }
  }
}

@DependencyClient
public struct PurchasesOffersClient: Sendable {
  public enum PaywallEvent {
    case present
    case dismiss
  }

  public var run: @Sendable () async -> Void

  public var activeOffer: @Sendable () -> PurchasesOffer?

  public var activeOfferUpdates: @Sendable () -> AsyncStream<PurchasesOffer?> = { .finished }

  public var logPaywallEvent: @Sendable (
    _ paywall: Paywall?,
    _ paywallType: Paywall.PaywallType,
    _ event: PaywallEvent
  ) -> Void

  public var reset: @Sendable () async -> Void
}
