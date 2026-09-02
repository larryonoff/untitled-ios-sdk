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
      String(localized: .Error.Unknown.description)
    case .premiumExpired:
      String(localized: .Purchases.Error.PremiumExpired.description)
    case .productUnavailable:
      "Product not available"
    }
  }
}
