import StoreKit

public struct PurchaseRequest {
  public let product: Product
  public let offerID: String?
  public let paywallID: Paywall.ID?

  public static func request(
    product: Product,
    offerID: String? = nil,
    paywallID: Paywall.ID?
  ) -> Self {
    .init(product: product, offerID: offerID, paywallID: paywallID)
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

public struct StoreClient {
  public var initialize: () -> Void
  public var paywalByID: (Paywall.ID) async throws -> Paywall?
  public var purchase: (PurchaseRequest) async throws -> PurchaseResult
  public var purchases: () -> Purchases
  public var purchasesChange: () -> AsyncStream<Purchases>
  public var restorePurhases: () async throws -> RestorePurchasesResult
  public var logPaywall: (Paywall) async throws -> Void

  public init(
    initialize: @escaping () -> Void,
    paywalByID: @escaping (Paywall.ID) async throws -> Paywall?,
    purchase: @escaping (PurchaseRequest) async throws -> PurchaseResult,
    purchases: @escaping () -> Purchases,
    purchasesChange: @escaping () -> AsyncStream<Purchases>,
    restorePurhases: @escaping () async throws -> RestorePurchasesResult,
    logPaywall: @escaping (Paywall) async throws -> Void
  ) {
    self.initialize = initialize
    self.paywalByID = paywalByID
    self.purchase = purchase
    self.purchases = purchases
    self.purchasesChange = purchasesChange
    self.restorePurhases = restorePurhases
    self.logPaywall = logPaywall
  }
}

extension StoreClient {
  public func paywal(by id: Paywall.ID) async throws -> Paywall? {
    try await paywalByID(id)
  }

  public func log(_ paywall: Paywall) async throws {
    try await logPaywall(paywall)
  }
}

extension PurchaseRequest: Equatable {}

extension PurchaseRequest: Hashable {}

extension RestorePurchasesResult: Equatable {}

extension RestorePurchasesResult: Hashable {}

extension RestorePurchasesResult: Sendable {}

extension PurchaseResult: Equatable {}

extension PurchaseResult: Hashable {}

extension PurchaseResult: Sendable {}
