import Dependencies

extension PurchasesClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
    initialize: unimplemented("\(Self.self).initialize"),
    paywallByID: unimplemented("\(Self.self).paywalByID", placeholder: .finished()),
    purchase: unimplemented("\(Self.self).purchase", placeholder: .userCancelled),
    restorePurhases: unimplemented("\(Self.self).restorePurhases", placeholder: .userCancelled),
    purchases: unimplemented("\(Self.self).purchases", placeholder: Purchases()),
    purchasesUpdates: unimplemented("\(Self.self).purchasesUpdates", placeholder: .finished),
    receipt: unimplemented("\(Self.self).receipt", placeholder: nil),
    requestReview: unimplemented("\(Self.self).requestReview"),
    reset: unimplemented("\(Self.self).reset"),
    setFallbackPaywalls: unimplemented("\(Self.self).setFallbackPaywalls"),
    logPaywall: unimplemented("\(Self.self).logPaywall")
  )
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
    setFallbackPaywalls: { _ in try await Task.never() },
    logPaywall: { _ in try await Task.never() }
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
    setFallbackPaywalls: { _ in },
    logPaywall: { _ in }
  )
}
