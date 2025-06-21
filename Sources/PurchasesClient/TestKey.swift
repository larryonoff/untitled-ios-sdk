import Dependencies

extension PurchasesClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension PurchasesClient {
  public static let noop = Self(
    initialize: {},
    paywallByID: { _ in .finished() },
    purchase: { _ in try await Task.never() },
    restorePurhases: { try await Task.never() },
    purchases: { Purchases() },
    purchasesUpdates: { AsyncStream { _ in } },
    receipt: { nil },
    requestReview: {},
    reset: {},
    setFallback: { _ in try await Task.never() },
    logPaywall: { _ in try await Task.never() },
    transactionsUpdates: { AsyncStream { _ in } }
  )
}

extension PurchasesClient {
  public static let mock = Self(
    initialize: { },
    paywallByID: { _ in .finished() },
    purchase: { _ in .success(.init(isPremium: true)) },
    restorePurhases: { .success(.init(isPremium: true)) },
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
