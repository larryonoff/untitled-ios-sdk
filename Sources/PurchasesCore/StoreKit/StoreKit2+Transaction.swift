import StoreKit

extension StoreKit.Transaction {
  public var isFreeTrial: Bool {
    offer?.type == .introductory && offer?.paymentMode == .freeTrial
  }

  public var startsFreeTrial: Bool {
    // Differentiate a purchase transaction from a restore or a renewal transaction.
    // For restore and renewal transactions,
    // the original transaction identifier, originalID, and transaction identifier, id, differ.
    if id == originalID {
      return isFreeTrial
    }
    return false
  }
}
