import Adapty
import Combine
import ConcurrencyExtras
import DuckConcurrency
import DuckLogging
import StoreKit

final class TransactionObserver {
  private let store: TransactionCache

  private let subject = PassthroughSubject<DuckTransaction, Never>()

  init(
    store: TransactionCache
  ) {
    self.store = store
  }

  var updates: AsyncStream<DuckTransaction> {
    subject
      .buffer(size: 5, prefetch: .byRequest, whenFull: .dropOldest)
      .values
      .eraseToStream()
  }

  private let handleProfileTask = LockIsolated<Task<Void, Never>?>(nil)

  func handle(_ profile: AdaptyProfile) {
    handleProfileTask.withValue { task in
      task?.cancel()

      task = Task {
        do {
          logger.info("handle profile")

          // HACK
          // Adapty sends the profile update before finishing transaction.
          // Adding a delay ensures we process transactions in the correct order.
          try await Task.sleep(for: .seconds(2))

          logger.info("handle profile. continue after timeout")

          if store.newCandidatesDate() == nil {
            await store.setNewCandidatesDate(Date())
            logger.info("handle profile. update newCandidatesDate")
          }

          try Task.checkCancellation()
          await checkRestoredTransactions()

          try Task.checkCancellation()
          await observeNewTransactions(for: profile)

          logger.info("handle profile success")
        } catch is CancellationError {
          logger.warning("handle profile cancelled")
        } catch {
          logger.error("handle profile failure", dump: [
            "error": error
          ])
        }
      }
    }
  }

  private func checkRestoredTransactions() async {
    guard !store.hasRestoredPurchases() else {
      return
    }

    let restoredTransactions = await Transaction.currentEntitlements
      .collected()
      .filter { $0.transaction.purchaseDate > sk2ReleaseDate }
      .sorted { $0.transaction.purchaseDate < $1.transaction.purchaseDate }

    logger.debug("restored transactions", dump: [
      "restoredTransactions.count": restoredTransactions.count,
      "restoredTransactions": restoredTransactions
    ])

    for transactionResult in restoredTransactions {
      // we don't need to notify, just handle, e.g. store ids
      _ = await handleTransaction(transactionResult, cache: store)
    }

    await store.setHasRestoredPurchases(true)
  }

  private func observeNewTransactions(
    for profile: AdaptyProfile
  ) async {
    let newTransactions = await StoreKit.Transaction
      .newCandidateTransactions(store: store, profile: profile)
      .sorted { $0.transaction.purchaseDate < $1.transaction.purchaseDate }

    logger.info("new transactions", dump: [
      "newTransactions.count": newTransactions.count,
      "newTransactions": newTransactions
    ])

    guard !newTransactions.isEmpty else {
      return
    }

    for transactionResult in newTransactions {
      if let transaction = await handleTransaction(transactionResult, cache: store) {
        subject.send(transaction)
      }
    }

    if let latest = newTransactions.last {
      await store.setNewCandidatesDate(latest.transaction.purchaseDate)
    }
  }
}

private func handleTransaction(
  _ verificationResult: VerificationResult<StoreKit.Transaction>,
  cache: TransactionCache
) async -> DuckTransaction? {
  logger.info("handle transaction", dump: [
    "verificationResult": verificationResult
  ])

  guard case let .verified(transaction) = verificationResult else {
    logger.warning("transaction is not verified", dump: [
      "verificationResult": verificationResult
    ])
    // ignore unverified transactions
    return nil
  }

  // handle non-consumable

  if transaction.productType == .nonConsumable {
    let product = try? await StoreKit.Product
      .products(for: [transaction.productID])
      .first

    await cache.append(transactionID: transaction.id)

    logger.info("handle transaction (non-consumable) success", dump: [
      "transaction.id": transaction.id
    ])

    return .init(
      product: product,
      transaction: transaction,
      event: .purchaseNonConsumable
    )
  }

  // auto renewable

  if transaction.productType == .autoRenewable {
    let product = try? await StoreKit.Product
      .products(for: [transaction.productID])
      .first

    // subscription start free trial

    if transaction.isStartFreeTrial {
      logger.info("handle transaction (subscripion) success", dump: [
        "event": "start free trial",
        "transaction.id": transaction.id
      ])

      await cache.remove(transactionID: transaction.originalID)

      return .init(
        product: product,
        transaction: transaction,
        event: .subscriptionTrialStarted
      )
    }

    // subscription started or trial converted

    if !cache.transactionIDs().contains(transaction.originalID) {
      let isSubscriptionStarted = transaction.id == transaction.originalID

      logger.info("handle transaction (subscripion) success", dump: [
        "event": "\(isSubscriptionStarted ? "subscription started" : "trial converted")",
        "transaction.id": transaction.id
      ])

      await cache.append(transactionIDs: [transaction.originalID, transaction.id])

      return .init(
        product: product,
        transaction: transaction,
        event: isSubscriptionStarted ? .subscriptionStarted : .subscriptionTrialConverted
      )
    }

    // subscription renewal

    logger.info("handle transaction (subscripion) success", dump: [
      "event": "subscription renewed",
      "transaction.id": transaction.id
    ])

    await cache.append(transactionID: transaction.id)

    return .init(
      product: product,
      transaction: transaction,
      event: .subscriptionRenewed
    )
  }

  logger.warning("handle transaction completed. No eligible transactions found", dump: [
    "transaction.id": transaction.id,
    "transaction.productType": transaction.productType
  ])

  return nil
}

private let logger = Logger(
  subsystem: ".SDK.TransactionObserver",
  category: "SDK.Purchases"
)
