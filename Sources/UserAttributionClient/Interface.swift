import Dependencies
import DependenciesMacros
import Foundation

extension DependencyValues {
  public var userAttribution: UserAttributionClient {
    get { self[UserAttributionClient.self] }
    set { self[UserAttributionClient.self] = newValue }
  }
}

@DependencyClient
public struct UserAttributionClient: Sendable {
  public struct Attribution: @unchecked Sendable {
    private let _dictionary: [AnyHashable: Any]?

    public var dictionary: [AnyHashable: Any]? { _dictionary }

    public init(
      _ dictionary: [AnyHashable: Any]?
    ) {
      self._dictionary = dictionary
    }
  }

  public struct Configuration: Sendable {
    public struct UserTracking: Sendable {
      public var authorizationWaitTimeoutInterval: UInt?

      public init(
        authorizationWaitTimeoutInterval: UInt? = 120
      ) {
        self.authorizationWaitTimeoutInterval = authorizationWaitTimeoutInterval
      }
    }

    public var userTracking: UserTracking?

    public init(
      userTracking: UserTracking? = nil
    ) {
      self.userTracking = userTracking
    }
  }

  public enum DelegateEvent: Sendable {
    case onAttributionChanged(Attribution)
  }

  public struct Transaction: Sendable {
    public enum PurchaseType: Sendable {
      case purchaseNonConsumable

      case subscriptionTrialStarted
      case subscriptionTrialConverted
      case subscriptionStarted
      case subscriptionRenewed
    }

    public let price: Decimal?
    public let currency: Locale.Currency?

    public let productID: String

    public let purchaseType: PurchaseType

    public let transactionID: String

    public init(
      price: Decimal?,
      currency: Locale.Currency?,
      productID: String,
      purchaseType: PurchaseType,
      transactionID: String
    ) {
      self.price = price
      self.currency = currency
      self.productID = productID
      self.purchaseType = purchaseType
      self.transactionID = transactionID
    }
  }

  public var initialize: @Sendable (Configuration) -> Void

  public var delegate: @Sendable () -> AsyncStream<DelegateEvent> = { .finished }

  public var logTransaction: @Sendable (
    _ _: Transaction
  ) -> Void

  public var uid: @Sendable () async -> String? = { nil }

  public var reset: @Sendable () -> Void
}
