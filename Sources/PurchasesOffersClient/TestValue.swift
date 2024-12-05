import Dependencies

extension PurchasesOffersClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension PurchasesOffersClient {
  public static let noop = Self(
    run: {},
    activeOffer: { nil },
    activeOfferUpdates: { .finished },
    logPaywallEvent: { _, _, _ in },
    reset: {}
  )
}
