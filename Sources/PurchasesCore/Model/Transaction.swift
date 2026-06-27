import Foundation
import StoreKit

public typealias DuckTransaction = DuckPurchasesCore.Transaction

public struct Transaction {
  public enum Event {
    case purchaseNonConsumable

    case subscriptionTrialStarted
    case subscriptionTrialConverted
    case subscriptionStarted
    case subscriptionRenewed
  }

  public let product: StoreKit.Product?
  private let transaction: StoreKit.Transaction
  public let event: Event

  public init(
    product: StoreKit.Product?,
    transaction: StoreKit.Transaction,
    event: Event
  ) {
    self.product = product
    self.transaction = transaction
    self.event = event
  }

  public var id: UInt64 {
    transaction.id
  }

  public var price: Decimal? {
    product?.price ?? transaction.price
  }

  public var productID: String {
    transaction.productID
  }

  public var productType: StoreKit.Product.ProductType {
    transaction.productType
  }

  public var currency: Locale.Currency? {
    transaction.currency
  }

  public var storefront: Storefront {
    transaction.storefront
  }

  public var isStartFreeTrial: Bool {
    transaction.isStartFreeTrial
  }
}

extension Transaction: Equatable {}
extension Transaction: Hashable {}

extension Transaction.Event: Equatable {}
extension Transaction.Event: Hashable {}
