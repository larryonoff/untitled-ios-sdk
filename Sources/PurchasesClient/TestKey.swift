import Dependencies

extension PurchasesClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension PurchasesClient {
  public static let noop = Self()
}

extension PurchasesClient {
  public static let mock = Self(
    initialize: { },
    paywallByID: { _ in .finished() },
    purchase: { _ in .success(.init(isPremium: true)) },
    restorePurchases: { .success(.init(isPremium: true)) },
    purchases: { Purchases(isPremium: true) },
    purchasesUpdates: { AsyncStream { _ in } },
    receipt: { nil },
    requestReview: {},
    reset: {},
    setFallback: { _ in },
    logPaywall: { _ in },
    transactionsUpdates: { AsyncStream { _ in } }
  )
}
