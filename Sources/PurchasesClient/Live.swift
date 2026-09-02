import Adapty
import Combine
import Dependencies
import DuckAnalyticsClient
import DuckFoundation
import DuckLogging
import DuckUserIdentifierClient
import DuckUserSettings
import Foundation
import IssueReporting
import OSLog
import StoreKit
#if canImport(UIKit)
import UIKit
#endif

extension PurchasesClient {
  public static func live(
    analytics: AnalyticsClient,
    userIdentifier: UserIdentifierGenerator,
    userSettings: UserSettingsClient
  ) -> Self {
    guard
      let apiKey = Bundle.main.adaptyAPIKey,
      !apiKey.isEmpty
    else {
      logger.warning("purchases.configure skipped | reason: missing-adapty-settings")

      return Self.noop
    }

    let transactionStore = TransactionCache(
      userSettings: userSettings
    )

    let transactionObserver = TransactionObserver(
      store: transactionStore
    )

    let impl = PurchasesClientImpl(
      analytics: analytics,
      transactionObserver: transactionObserver,
      userIdentifier: userIdentifier
    )

    return PurchasesClient(
      initialize: {
        impl.initialize()
      },
      paywallByID: { id in
        impl.paywall(by: id)
      },
      purchase: {
        try await impl.purchase($0)
      },
      restorePurchases: {
        try await impl.restorePurchases()
      },
      purchases: {
        impl.purchases
      },
      purchasesUpdates: {
        impl.purchasesUpdates
      },
      receipt: {
        try impl.receipt()
      },
      requestReview: {
        await impl.requestReview()
      },
      reset: {
        try await impl.reset()
      },
      setFallback: {
        try await impl.setFallback(fileURL: $0)
      },
      logPaywall: {
        try await impl.log($0)
      },
      transactionsUpdates: {
        transactionObserver.updates
      }
    )
  }
}

final class PurchasesClientImpl: Sendable {
  private struct State {
    var adaptyDelegate: _AdaptyDelegate?
    var paywalls: [Paywall.ID: Paywall] = [:]
    /// In-flight paywall fetches, keyed by ID, so concurrent callers for the
    /// same paywall share one network request instead of issuing N.
    var paywallFetchTasks: [Paywall.ID: Task<Paywall?, any Error>] = [:]
  }

  private let state = Mutex(State())

  // SAFETY: CurrentValueSubject is internally thread-safe; Combine doesn't
  // annotate it `Sendable`.
  private nonisolated(unsafe) let _purchases = CurrentValueSubject<Purchases, Never>(.load())
  private let analytics: AnalyticsClient
  private let transactionObserver: TransactionObserver
  private let userIdentifier: UserIdentifierGenerator

  init(
    analytics: AnalyticsClient,
    transactionObserver: TransactionObserver,
    userIdentifier: UserIdentifierGenerator
  ) {
    self.analytics = analytics
    self.transactionObserver = transactionObserver
    self.userIdentifier = userIdentifier
  }

  var purchases: Purchases {
    _purchases.value
  }

  var purchasesUpdates: AsyncStream<Purchases> {
    _purchases
      .dropFirst()
      .removeDuplicates()
      .values
      .eraseToStream()
  }

  func initialize() {
    logger.info("purchases.initialize")

    let bundle = Bundle.main
    guard let apiKey = bundle.adaptyAPIKey, !apiKey.isEmpty else {
      reportIssue("Cannot find a valid Adapty settings")

      logger.error("purchases.initialize failed | reason: missing-adapty-settings")

      return
    }

    let adaptyDelegate: _AdaptyDelegate? = state.withLock { state in
      guard state.adaptyDelegate == nil else { return nil }
      let delegate = _AdaptyDelegate()
      state.adaptyDelegate = delegate
      return delegate
    }

    guard let adaptyDelegate else {
      logger.info("purchases.initialize skipped | reason: already-configured")
      return
    }

    Adapty.delegate = adaptyDelegate

    _ = Task.detached(priority: .high) { [weak self] in
      for await event in adaptyDelegate.stream {
        switch event {
        case let .didLoadLatestProfile(profile):
          guard let self else { break }

          let purchases = self.updatePurchases(profile)

          logger.info(
            """
            purchases.update success
            purchases: \(String(describing: purchases), privacy: .public)
            """
          )

          transactionObserver.handle(profile)
        }
      }
    }

    let userID = userIdentifier()

    let config = AdaptyConfiguration
      .builder(withAPIKey: apiKey)
      .with(callbackDispatchQueue: .init(label: "AdaptyQueue"))
      .with(customerUserId: userID.uuidString, withAppAccountToken: userID.rawValue)
      .build()

    Adapty.activate(with: config) { error in
      if let error {
        logger.error(
          """
          purchases.initialize failed
          error: \(error, privacy: .public)
          """
        )
      }
    }

    Task { [weak self] in
      if
        let fallbackURL = Bundle.main.url(
          forResource: "fallback_paywalls",
          withExtension: "json"
        )
      {
        try? await self?.setFallback(fileURL: fallbackURL)
      }
    }

    logger.info("purchases.initialize success")
  }

  func paywall(
    by id: Paywall.ID
  ) -> AsyncThrowingStream<Paywall?, any Error> {
    AsyncThrowingStream { [weak self] continuation in
      let task = Task { [weak self] in
        guard let self else {
          continuation.finish()
          return
        }

        do {
          logger.info(
            """
            purchases.paywall-fetch | \
            paywall_id: \(id, privacy: .public)
            """
          )

          let cached = state.withLock { $0.paywalls[id] }

          if let cached {
            logger.info(
              """
              purchases.paywall-fetch success | \
              paywall_id: \(id, privacy: .public) \
              is_from_cache: true
              paywall: \(String(describing: cached), privacy: .public)
              """
            )

            continuation.yield(cached)
          }

          let paywall = try await fetchPaywall(by: id)

          if paywall != cached {
            continuation.yield(paywall)
          }

          continuation.finish()

          logger.info(
            """
            purchases.paywall-fetch success | \
            paywall_id: \(id, privacy: .public) \
            is_from_cache: false
            paywall: \(String(describing: paywall), privacy: .public)
            """
          )
        } catch {
          logger.error(
            """
            purchases.paywall-fetch failed | \
            paywall_id: \(id, privacy: .public)
            error: \(error, privacy: .public)
            """
          )

          continuation.finish(throwing: error)
        }
      }

      continuation.onTermination = { _ in task.cancel() }
    }
  }

  /// Fetches a paywall from Adapty, deduplicating concurrent callers for the
  /// same ID so N simultaneous subscribers share a single network request.
  private func fetchPaywall(by id: Paywall.ID) async throws -> Paywall? {
    let task = state.withLock { state -> Task<Paywall?, any Error> in
      if let existing = state.paywallFetchTasks[id] {
        logger.info(
          """
          purchases.paywall-fetch deduplicated | \
          paywall_id: \(id, privacy: .public)
          """
        )
        return existing
      }

      let task = Task<Paywall?, any Error> { [weak self] in
        defer {
          self?.state.withLock { _ = $0.paywallFetchTasks.removeValue(forKey: id) }
        }

        guard let flow = try await Self.adaptyFlow(by: id) else {
          return nil
        }

        var paywall = Paywall(flow, products: nil)

        if let adaptyProducts = try await Self.adaptyProducts(for: flow) {
          let productsByID = Dictionary(
            adaptyProducts.map { ($0.vendorProductId, $0) },
            uniquingKeysWith: { first, _ in first }
          )

          paywall.products = (flow.paywalls.first?.vendorProductIds ?? [])
            .compactMap { productsByID[$0].flatMap { .init($0) } }
        }

        // Cache write is co-located with assembly (no `await` in between), so a
        // subscriber's cancellation cannot strand a successfully fetched paywall.
        self?.state.withLock { $0.paywalls[id] = paywall }

        return paywall
      }

      state.paywallFetchTasks[id] = task
      return task
    }

    return try await task.value
  }

  func purchase(
    _ request: PurchaseRequest
  ) async throws -> PurchaseResult {
    do {
      logger.info(
        """
        purchases.purchase | \
        paywall_id: \(request.paywallID, privacy: .public) \
        product_id: \(request.product.id, privacy: .public)
        """
      )

      guard
        let flow = try await Self.adaptyFlow(by: request.paywallID),
        let products = try await Self.adaptyProducts(for: flow),
        let product = products
          .first(where: { $0.vendorProductId == request.product.id.rawValue })
      else {
        // Not a programmer error: the product can legitimately be unavailable
        // (no network, not approved yet), so this must not trap in debug.
        throw PurchasesError.productUnavailable
      }

      let purchaseResult = try await Adapty.makePurchase(product: product)

      switch purchaseResult {
      case .pending:
        logger.info(
          """
          purchases.purchase pending | \
          paywall_id: \(request.paywallID, privacy: .public) \
          product_id: \(request.product.id, privacy: .public)
          """
        )
        return .pending
      case let .success(profile: profile, transaction: _):
        let purchases = updatePurchases(profile)

        logger.info(
          """
          purchases.purchase success | \
          paywall_id: \(request.paywallID, privacy: .public) \
          product_id: \(request.product.id, privacy: .public)
          purchases: \(String(describing: purchases), privacy: .public)
          """
        )

        return .success(purchases)
      case .userCancelled:
        logger.info(
          """
          purchases.purchase cancelled | \
          paywall_id: \(request.paywallID, privacy: .public) \
          product_id: \(request.product.id, privacy: .public)
          """
        )
        return .userCancelled
      }
    } catch {
      logger.error(
        """
        purchases.purchase failed | \
        paywall_id: \(request.paywallID, privacy: .public) \
        product_id: \(request.product.id, privacy: .public)
        error: \(error, privacy: .public)
        """
      )

      let newError = error._map()

      if newError.isPaymentCancelled {
        return .userCancelled
      }

      throw newError
    }
  }

  func restorePurchases() async throws -> RestorePurchasesResult {
    do {
      logger.info("purchases.restore")

      let profile = try await Adapty.restorePurchases()
      let purchases = updatePurchases(profile)

      if !purchases.isPremium {
        throw PurchasesError.premiumExpired
      }

      logger.info(
        """
        purchases.restore success
        purchases: \(String(describing: purchases), privacy: .public)
        """
      )

      return .success(purchases)
    } catch {
      logger.error(
        """
        purchases.restore failed
        error: \(error, privacy: .public)
        """
      )

      let newError = error._map()

      if newError.isPaymentCancelled {
        return .userCancelled
      }

      throw newError
    }
  }

  func setFallback(fileURL: URL) async throws {
    do {
      logger.info("purchases.set-fallback")

      try await Adapty.setFallback(fileURL: fileURL)

      logger.info("purchases.set-fallback success")
    } catch {
      logger.error(
        """
        purchases.set-fallback failed
        error: \(error, privacy: .public)
        """
      )
      throw error
    }
  }

  func log(_ paywall: Paywall) async throws {
    do {
      logger.info(
        """
        purchases.log-paywall | \
        paywall_id: \(paywall.id, privacy: .public)
        """
      )

      guard
        let adaptyFlow = try await Self.adaptyFlow(by: paywall.id)
      else {
        return
      }

      try await Adapty.logShowFlow(adaptyFlow)

      logger.info("purchases.log-paywall success")
    } catch {
      logger.error(
        """
        purchases.log-paywall failed | \
        paywall_id: \(paywall.id, privacy: .public)
        error: \(error, privacy: .public)
        """
      )

      throw error
    }
  }

  func receipt() throws -> Data? {
    let bundle = Bundle.main

    return try bundle.appStoreReceiptURL.flatMap { receiptURL in
      let fileManager = FileManager.default
      guard fileManager.fileExists(atPath: receiptURL.path) else {
        return nil
      }
      return try Data(contentsOf: receiptURL)
    }
  }

  func requestReview() async {
#if canImport(UIKit)
    let application = await UIApplication.shared
    var activeScene: UIWindowScene?

    for scene in await application.connectedScenes {
      guard
        await scene.activationState == .foregroundActive,
        let scene = scene as? UIWindowScene
      else {
        continue
      }

      activeScene = scene
      break
    }

    if let activeScene {
      // `SKStoreReviewController` is deprecated as of iOS 18.
      await AppStore.requestReview(in: activeScene)

      // Dialog may not appear; Apple doesn't provide developers any control.
      logger.info("purchases.request-review success")
    } else {
      logger.error("purchases.request-review failed | reason: no-active-window-scene")
    }
#endif
  }

  func reset() async throws {
    do {
      logger.info("purchases.reset")

      try await Adapty.logout()

      let userID = userIdentifier()
      try await Adapty.identify(
        userID.uuidString,
        withAppAccountToken: userID.rawValue
      )

      _purchases.value = Purchases()

      logger.info("purchases.reset success")
    } catch {
      logger.error(
        """
        purchases.reset failed
        error: \(error, privacy: .public)
        """
      )

      throw error
    }
  }

  private static func adaptyFlow(
    by id: Paywall.ID
  ) async throws -> AdaptyFlow? {
    try await Adapty.getFlow(placementId: id.rawValue)
  }

  private static func adaptyProducts(
    for flow: AdaptyFlow
  ) async throws -> [AdaptyPaywallProduct]? {
    try await Adapty
      .getPaywallProducts(flow: flow)
  }

  @discardableResult
  private func updatePurchases(
    _ profile: AdaptyProfile?
  ) -> Purchases {
    let purchases = Purchases(profile)
    _purchases.value = purchases

    return purchases
  }
}

// MARK: - Adapty

enum AdaptyDelegateEvent: Equatable {
  case didLoadLatestProfile(AdaptyProfile)
}

final class _AdaptyDelegate: AdaptyDelegate {
  private let pipe = AsyncStream<AdaptyDelegateEvent>.makeStream()

  init() {}

  var stream: AsyncStream<AdaptyDelegateEvent> {
    pipe.stream.eraseToStream()
  }

  // AdaptyDelegate

  func didLoadLatestProfile(
    _ profile: AdaptyProfile
  ) {
    pipe.continuation.yield(
      .didLoadLatestProfile(profile)
    )

    logger.info(
      """
      purchases.profile received
      profile: \(profile, privacy: .public)
      """
    )
  }
}

private let logger = Logger(
  subsystem: ".SDK.PurchasesClient",
  category: "Purchases"
)
