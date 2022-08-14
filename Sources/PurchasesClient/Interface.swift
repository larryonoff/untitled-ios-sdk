import StoreKit

public struct PurchaseRequest {
  public let product: Product
  public let paywallID: Paywall.ID

  public static func request(
    product: Product,
    paywallID: Paywall.ID
  ) -> Self {
    .init(product: product, paywallID: paywallID)
  }
}

public enum RestorePurchasesResult {
  case success(Purchases)
  case userCancelled
}

public enum PurchaseResult {
  case success(Purchases)
  case userCancelled
}

public struct PurchasesClient {
  public var initialize: @Sendable () -> Void
  public var paywalByID: @Sendable (Paywall.ID) async throws -> Paywall?
  public var purchase: @Sendable (PurchaseRequest) async throws -> PurchaseResult
  public var purchases: @Sendable () -> Purchases
  public var purchasesUpdates: @Sendable () -> AsyncStream<Purchases>
  public var restorePurhases: @Sendable () async throws -> RestorePurchasesResult
  public var logPaywall: @Sendable (Paywall) async throws -> Void
}

extension PurchasesClient {
  public func paywal(by id: Paywall.ID) async throws -> Paywall? {
    try await paywalByID(id)
  }

  public func log(_ paywall: Paywall) async throws {
    try await logPaywall(paywall)
  }
}

extension PurchaseRequest: Equatable {}

extension PurchaseRequest: Hashable {}

extension PurchaseRequest: Sendable {}

extension RestorePurchasesResult: Equatable {}

extension RestorePurchasesResult: Hashable {}

extension RestorePurchasesResult: Sendable {}

extension PurchaseResult: Equatable {}

extension PurchaseResult: Hashable {}

extension PurchaseResult: Sendable {}
