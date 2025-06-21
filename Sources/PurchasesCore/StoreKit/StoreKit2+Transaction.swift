import StoreKit

extension StoreKit.Transaction {
  public var isFreeTrial: Bool {
    if #available(iOS 17.2, *) {
      return
        offer?.type == .introductory &&
        offer?.paymentMode == .freeTrial
    } else {
      let freeTrialPaymentModeString =
      StoreKit.Product.SubscriptionOffer.PaymentMode.freeTrial.rawValue

      return
        offerType == .introductory &&
        offerPaymentModeStringRepresentation == freeTrialPaymentModeString
    }
  }

  public var isStartFreeTrial: Bool {
    // Differentiate a purchase transaction from a restore or a renewal transaction.
    // For restore and renewal transactions,
    // the original transaction identifier, originalID, and transaction identifier, id, differ.
    if id == originalID {
      return isFreeTrial
    }
    return false
  }
}
