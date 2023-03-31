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
      return L10n.Error.Unknown.description
    case .premiumExpired:
      return L10n.Purchases.Error.PremiumExpired.description
    case .productUnavailable:
      return "Product not available"
    }
  }
}

extension Error {
  var isPaymentCancelled: Bool {
    if let adaptyError = self as? AdaptyError {
      if adaptyError.adaptyErrorCode == .paymentCancelled {
        return true
      }

      if let skError = adaptyError.originalError as? SKError {
        return skError.code == .paymentCancelled
      }
    }

    if let skError = self as? SKError {
      return skError.code == .paymentCancelled
    }

    return false
  }

  func _map() -> Error {
    if let adaptyError = self as? AdaptyError {
      switch adaptyError.adaptyErrorCode {
      default:
        return adaptyError.originalError ?? PurchasesError.unknown
      }
    }

    return PurchasesError.unknown
  }
}
