import Adapty
import Foundation
import StoreKit
import Tagged

public enum PurchasesError: Swift.Error, LocalizedError {
  case premiumExpired
  case productUnavailable
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
}
