import Adapty
import StoreKit

extension StoreKit.Transaction {
  static func newCandidateTransactions(
    store: TransactionCache,
    profile: AdaptyProfile
  ) async -> [VerificationResult<StoreKit.Transaction>] {
    let transactionsToConsider = await Transaction.all.collected()
    let transactionIDs = store.transactionIDs()
    let candidatesDate = store.newCandidatesDate()

    let candidateTransactions = transactionsToConsider
      .filter { result -> Bool in
        let transaction = result.transaction
        let id = transaction.id

        var dateCheck = true
        if let candidatesDate {
          dateCheck = transaction.purchaseDate > candidatesDate
        }

        let now = Date()

        return
          transaction.revocationDate == nil &&
          (transaction.expirationDate ?? now) >= now &&
          dateCheck &&
          profile.subscriptions.values.contains(where: { $0.vendorTransactionId == String(id) }) &&
          !transactionIDs.contains(id)
      }

    return candidateTransactions
  }
}

extension VerificationResult<StoreKit.Transaction> {
  var transaction: StoreKit.Transaction {
    switch self {
    case let .verified(transaction): transaction
    case let .unverified(transaction, _): transaction
    }
  }

  var verifiedTransaction: StoreKit.Transaction? {
    switch self {
    case let .verified(transaction): transaction
    default: nil
    }
  }
}
