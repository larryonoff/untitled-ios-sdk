import Dependencies
import DependenciesMacros
import Foundation

extension DependencyValues {
  public var purchases: PurchasesClient {
    get { self[PurchasesClient.self] }
    set { self[PurchasesClient.self] = newValue }
  }
}

@DependencyClient
public struct PurchasesClient: Sendable {
  public var initialize: @Sendable () -> Void

  @DependencyEndpoint(method: "paywall")
  public var paywallByID: @Sendable (
    _ by: Paywall.ID
  ) -> AsyncThrowingStream<Paywall?, any Error> = { _ in .finished() }

  public var purchase: @Sendable (
    _ _: PurchaseRequest
  ) async throws -> PurchaseResult = { _ in .success(.init()) }

  public var restorePurhases: @Sendable () async throws -> RestorePurchasesResult

  public var purchases: @Sendable () -> Purchases = { .init() }
  public var purchasesUpdates: @Sendable () -> AsyncStream<Purchases> = { .finished }

  public var receipt: @Sendable () async throws -> Data?

  public var requestReview: @Sendable () async -> Void

  public var reset: @Sendable () async throws -> Void

  public var setFallbackPaywalls: @Sendable (
    _ fileURL: URL
  ) async throws -> Void

  @DependencyEndpoint(method: "log")
  public var logPaywall: @Sendable (
    _ _: Paywall
  ) async throws -> Void
}

extension PurchasesClient {
  @discardableResult
  @Sendable
  public func prefetch(
    paywallByID id: Paywall.ID
  ) async -> Paywall? {
    do {
      var paywall: Paywall?
      for try await _paywall in paywallByID(id) {
        paywall = _paywall
      }
      return paywall
    } catch {
      return nil
    }
  }
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
  case pending
  case userCancelled
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
