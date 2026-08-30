import Adapty
import Combine
import ConcurrencyExtras
import DuckConcurrency
import DuckLogging
import StoreKit

final class TransactionObserver: Sendable {
  private let store: TransactionCache

  // SAFETY: PassthroughSubject is internally thread-safe for send/subscribe;
  // it is never reassigned, only used to publish values.
  private nonisolated(unsafe) let subject = PassthroughSubject<DuckTransaction, Never>()

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
          logger.info("transaction.handle-profile")

          // HACK
          // Adapty sends the profile update before finishing transaction.
          // Adding a delay ensures we process transactions in the correct order.
          try await Task.sleep(for: .seconds(2))

          logger.info("transaction.handle-profile resumed")

          if store.newCandidatesDate() == nil {
            await store.setNewCandidatesDate(Date())
            logger.info("transaction.new-candidates-date updated")
          }

          try Task.checkCancellation()
          await checkRestoredTransactions()

          try Task.checkCancellation()
          await observeNewTransactions(for: profile)

          logger.info("transaction.handle-profile success")
        } catch is CancellationError {
          logger.warning("transaction.handle-profile cancelled")
        } catch {
          logger.error(
            """
            transaction.handle-profile failed
            error: \(error, privacy: .public)
            """
          )
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

    logger.debug(
      """
      transaction.restored received | \
      count: \(restoredTransactions.count)
      transactions: \(String(describing: restoredTransactions), privacy: .public)
      """
    )

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

    logger.info(
      """
      transaction.new received | \
      count: \(newTransactions.count)
      transactions: \(String(describing: newTransactions), privacy: .public)
      """
    )

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
  logger.info(
    """
    transaction.handle
    verification_result: \(String(describing: verificationResult), privacy: .public)
    """
  )

  guard case let .verified(transaction) = verificationResult else {
    logger.warning(
      """
      transaction.handle skipped | reason: unverified
      verification_result: \(String(describing: verificationResult), privacy: .public)
      """
    )
    // ignore unverified transactions
    return nil
  }

  // handle non-consumable

  if transaction.productType == .nonConsumable {
    let product = try? await StoreKit.Product
      .products(for: [transaction.productID])
      .first

    await cache.append(transactionID: transaction.id)

    logger.info(
      """
      transaction.handle success | \
      product_type: non-consumable \
      transaction_id: \(transaction.id)
      """
    )

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
      logger.info(
        """
        transaction.handle success | \
        product_type: auto-renewable \
        event: trial-started \
        transaction_id: \(transaction.id)
        """
      )

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

      logger.info(
        """
        transaction.handle success | \
        product_type: auto-renewable \
        event: \(isSubscriptionStarted ? "subscription-started" : "trial-converted", privacy: .public) \
        transaction_id: \(transaction.id)
        """
      )

      await cache.append(transactionIDs: [transaction.originalID, transaction.id])

      return .init(
        product: product,
        transaction: transaction,
        event: isSubscriptionStarted ? .subscriptionStarted : .subscriptionTrialConverted
      )
    }

    // subscription renewal

    logger.info(
      """
      transaction.handle success | \
      product_type: auto-renewable \
      event: subscription-renewed \
      transaction_id: \(transaction.id)
      """
    )

    await cache.append(transactionID: transaction.id)

    return .init(
      product: product,
      transaction: transaction,
      event: .subscriptionRenewed
    )
  }

  logger.warning(
    """
    transaction.handle skipped | \
    reason: not-eligible \
    transaction_id: \(transaction.id) \
    product_type: \(String(describing: transaction.productType), privacy: .public)
    """
  )

  return nil
}

private let logger = Logger(
  subsystem: ".SDK.TransactionObserver",
  category: "SDK.Purchases"
)
