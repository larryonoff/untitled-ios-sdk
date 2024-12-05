import Adapty
import StoreKit

package extension Error {
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

  func _map() -> any Error {
    if self is PurchasesError {
      return self
    }

    if let adaptyError = self as? AdaptyError {
      switch adaptyError.adaptyErrorCode {
      default:
        return adaptyError.originalError ?? PurchasesError.unknown
      }
    }

    return PurchasesError.unknown
  }
}
