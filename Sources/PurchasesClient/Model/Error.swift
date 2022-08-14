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
    guard
      let adaptyError = self as? AdaptyError,
      let skError = adaptyError.originalError as? SKError
    else {
      return false
    }
    return skError.code == .paymentCancelled
  }
}
