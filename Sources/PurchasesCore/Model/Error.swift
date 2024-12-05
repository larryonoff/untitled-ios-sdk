import Adapty
import Foundation
import StoreKit
import Tagged

public enum PurchasesError: Swift.Error {
  case unknown
  case premiumExpired
  case productUnavailable
}

extension PurchasesError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .unknown:
      L10n.Error.Unknown.description
    case .premiumExpired:
      L10n.Purchases.Error.PremiumExpired.description
    case .productUnavailable:
      "Product not available"
    }
  }
}
