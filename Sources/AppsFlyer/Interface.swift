import Dependencies
import Foundation
import PurchasesClient
import UIKit

extension DependencyValues {
  public var appsFlyer: AppsFlyerClient {
    get { self[AppsFlyerClient.self] }
    set { self[AppsFlyerClient.self] = newValue }
  }
}

public struct AppsFlyerClient {
  public var initialize: @Sendable (Configuration) async -> Void

  public var appContinueUserActivity: @Sendable (NSUserActivity, @escaping ([UIUserActivityRestoring]?) -> Void) -> Void
  public var appOpenURL: @Sendable (URL, [UIApplication.OpenURLOptionsKey: Any]) -> Void

  public var applicationID: @Sendable () -> String?

  public var logEvent: @Sendable (String) -> Void

  public var reset: @Sendable () -> Void
}

// MARK: - AppsFlyerClient.Configuration

extension AppsFlyerClient {
  public struct Configuration {
    public struct TransactionQueueListener {
      public var discountedProductsIDs: [Product.ID]?
      public var productsNamesMap: [Product.ID: String]?

      public init(
        discountedProductsIDs: [Product.ID]? = nil,
        productsNamesMap: [Product.ID: String]? = nil
      ) {
        self.discountedProductsIDs = discountedProductsIDs
        self.productsNamesMap = productsNamesMap
      }
    }

    public struct UserTracking {
      public var authorizationWaitTimeoutInterval: TimeInterval?

      public init(
        authorizationWaitTimeoutInterval: TimeInterval?
      ) {
        self.authorizationWaitTimeoutInterval = authorizationWaitTimeoutInterval
      }
    }

    public var isAdaptyEnabled: Bool
    public var transactionQueueListener: TransactionQueueListener?
    public var userTracking: UserTracking?

    public init(
      isAdaptyEnabled: Bool,
      transactionQueueListener: TransactionQueueListener?,
      userTracking: UserTracking? = nil
    ) {
      self.isAdaptyEnabled = isAdaptyEnabled
      self.transactionQueueListener = transactionQueueListener
      self.userTracking = userTracking
    }
  }
}

extension AppsFlyerClient.Configuration {
  public static func configuration(
    isAdaptyEnabled: Bool,
    transactionQueueListener: TransactionQueueListener? = nil,
    userTracking: UserTracking? = nil
  ) -> Self {
    .init(
      isAdaptyEnabled: isAdaptyEnabled,
      transactionQueueListener: transactionQueueListener,
      userTracking: userTracking
    )
  }
}

extension AppsFlyerClient.Configuration: Equatable {}

extension AppsFlyerClient.Configuration: Hashable {}

extension AppsFlyerClient.Configuration: Sendable {}

extension AppsFlyerClient.Configuration.TransactionQueueListener: Equatable {}

extension AppsFlyerClient.Configuration.TransactionQueueListener: Hashable {}

extension AppsFlyerClient.Configuration.TransactionQueueListener: Sendable {}

extension AppsFlyerClient.Configuration.UserTracking: Equatable {}

extension AppsFlyerClient.Configuration.UserTracking: Hashable {}

extension AppsFlyerClient.Configuration.UserTracking: Sendable {}

