import StoreKit

public struct PurchaseRequest: Equatable, Hashable {
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

public enum RestorePurchasesResult: Equatable, Hashable {
  case success(Purchases)
  case userCancelled
}

public enum PurchaseResult: Equatable, Hashable {
  case success(Purchases)
  case userCancelled
}

public struct AppStoreClient {
  public let initialize: () -> Void
  public let paywalByID: (Paywall.ID) async throws -> Paywall?
  public let purchase: (PurchaseRequest) async throws -> PurchaseResult
  public let purchases: () -> Purchases
  public let purchasesChange: () -> AsyncStream<Purchases>
  public let restorePurhases: () async throws -> RestorePurchasesResult
  public let logPaywall: (Paywall) -> Void

  public init(
    initialize: @escaping () -> Void,
    paywalByID: @escaping (Paywall.ID) async throws -> Paywall?,
    purchase: @escaping (PurchaseRequest) async throws -> PurchaseResult,
    purchases: @escaping () -> Purchases,
    purchasesChange: @escaping () -> AsyncStream<Purchases>,
    restorePurhases: @escaping () async throws -> RestorePurchasesResult,
    logPaywall: @escaping (Paywall) -> Void
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
