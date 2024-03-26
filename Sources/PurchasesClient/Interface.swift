import Dependencies
import Foundation

extension DependencyValues {
  public var purchases: PurchasesClient {
    get { self[PurchasesClient.self] }
    set { self[PurchasesClient.self] = newValue }
  }
}

public struct PurchasesClient {
  public var initialize: @Sendable () -> Void

  public var paywallByID: @Sendable (Paywall.ID) -> AsyncThrowingStream<FetchPaywallResponse, Error>

  public var purchase: @Sendable (PurchaseRequest) async throws -> PurchaseResult
  public var restorePurhases: @Sendable () async throws -> RestorePurchasesResult

  public var purchases: @Sendable () -> Purchases
  public var purchasesUpdates: @Sendable () -> AsyncStream<Purchases>

  public var receipt: @Sendable () async throws -> Data?

  public var requestReview: @Sendable () async -> Void

  public var reset: @Sendable () async throws -> Void

  public var setFallbackPaywalls: @Sendable (Data) async throws -> Void
  public var logPaywall: @Sendable (Paywall) async throws -> Void
}

extension PurchasesClient {
  public func prefetch(
    paywallByID id: Paywall.ID
  ) async throws {
    for try await _ in paywallByID(id) {}
  }
}

public struct FetchPaywallResponse {
  public let paywall: Paywall?
}

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

extension FetchPaywallResponse: Equatable {}

extension FetchPaywallResponse: Hashable {}

extension FetchPaywallResponse: Sendable {}

extension PurchaseRequest: Equatable {}

extension PurchaseRequest: Hashable {}

extension PurchaseRequest: Sendable {}

extension RestorePurchasesResult: Equatable {}

extension RestorePurchasesResult: Hashable {}

extension RestorePurchasesResult: Sendable {}

extension PurchaseResult: Equatable {}

extension PurchaseResult: Hashable {}

extension PurchaseResult: Sendable {}
