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
      logger.warning("Cannot find a valid Adapty settings")

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
    logger.info("initialize")

    let bundle = Bundle.main
    guard let apiKey = bundle.adaptyAPIKey, !apiKey.isEmpty else {
      reportIssue("Cannot find a valid Adapty settings")

      logger.error("initialize", dump: [
        "error": "Cannot find a valid Adapty settings"
      ])

      return
    }

    let adaptyDelegate: _AdaptyDelegate? = state.withLock { state in
      guard state.adaptyDelegate == nil else { return nil }
      let delegate = _AdaptyDelegate()
      state.adaptyDelegate = delegate
      return delegate
    }

    guard let adaptyDelegate else {
      logger.info("Adapty already configured")
      return
    }

    Adapty.delegate = adaptyDelegate

    _ = Task.detached(priority: .high) { [weak self] in
      for await event in adaptyDelegate.stream {
        switch event {
        case let .didLoadLatestProfile(profile):
          guard let self else { break }

          let purchases = self.updatePurchases(profile)

          logger.info("purchases updated", dump: [
            "purchases": purchases
          ])

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
        logger.info("initialize failure", dump: [
          "error": error
        ])
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

    logger.info("initialize success")
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
          logger.info("get paywall", dump: [
            "id": id
          ])

          let cached = state.withLock { $0.paywalls[id] }

          if let cached {
            logger.info("get paywall success", dump: [
              "id": id,
              "paywall": cached,
              "isFromCache": true
            ])

            continuation.yield(cached)
          }

          let paywall = try await fetchPaywall(by: id)

          if paywall != cached {
            continuation.yield(paywall)
          }

          continuation.finish()

          logger.info("get paywall success", dump: [
            "id": id,
            "paywall": paywall as Any,
            "isFromCache": false
          ])
        } catch {
          logger.error("get paywall failed", dump: [
            "id": id,
            "failure": error
          ])

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
        logger.info("get paywall deduplicated", dump: [
          "id": id
        ])
        return existing
      }

      let task = Task<Paywall?, any Error> { [weak self] in
        defer {
          self?.state.withLock { $0.paywallFetchTasks.removeValue(forKey: id) }
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
      logger.info("purchase", dump: [
        "request": request
      ])

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
        logger.info("purchase pending", dump: [
          "request": request
        ])
        return .pending
      case let .success(profile: profile, transaction: _):
        let purchases = updatePurchases(profile)

        logger.info("purchase success", dump: [
          "request": request,
          "purchases": purchases
        ])

        return .success(purchases)
      case .userCancelled:
        logger.info("purchase userCancelled", dump: [
          "request": request
        ])
        return .userCancelled
      }
    } catch {
      logger.error("purchase failure", dump: [
        "error": error.localizedDescription,
        "request": request
      ])

      let newError = error._map()

      if newError.isPaymentCancelled {
        return .userCancelled
      }

      throw newError
    }
  }

  func restorePurchases() async throws -> RestorePurchasesResult {
    do {
      logger.info("restore purchases")

      let profile = try await Adapty.restorePurchases()
      let purchases = updatePurchases(profile)

      if !purchases.isPremium {
        throw PurchasesError.premiumExpired
      }

      logger.info("restore purchases success", dump: [
        "purchases": purchases
      ])

      return .success(purchases)
    } catch {
      logger.error("restore purchases failure", dump: [
        "error": error.localizedDescription
      ])

      let newError = error._map()

      if newError.isPaymentCancelled {
        return .userCancelled
      }

      throw newError
    }
  }

  func setFallback(fileURL: URL) async throws {
    do {
      logger.info("set fallback paywalls")

      try await Adapty.setFallback(fileURL: fileURL)

      logger.info("set fallback paywalls success")
    } catch {
      logger.error("set fallback paywalls failure", dump: [
        "error": error.localizedDescription
      ])
      throw error
    }
  }

  func log(_ paywall: Paywall) async throws {
    do {
      logger.info("log show paywall", dump: [
        "paywall": paywall
      ])

      guard
        let adaptyFlow = try await Self.adaptyFlow(by: paywall.id)
      else {
        return
      }

      try await Adapty.logShowFlow(adaptyFlow)

      logger.info("log show paywall success")
    } catch {
      logger.error("log show paywall failure", dump: [
        "paywall": paywall,
        "error": error.localizedDescription
      ])

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

      logger.info("requestReview success", dump: [
        "WARNING": "dialog may not appear, Apple doesn't provide developers any control"
      ])
    } else {
      logger.error("requestReview failure", dump: [
        "error": "Active `UIWindowScene` not available"
      ])
    }
#endif
  }

  func reset() async throws {
    do {
      logger.info("reset")

      try await Adapty.logout()

      let userID = userIdentifier()
      try await Adapty.identify(
        userID.uuidString,
        withAppAccountToken: userID.rawValue
      )

      _purchases.value = Purchases()

      logger.info("reset success")
    } catch {
      logger.error("reset failure", dump: [
        "error": error.localizedDescription
      ])

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

    logger.info("delegate: didLoadLatestProfile", dump: [
      "profile": profile
    ])
  }
}

private let logger = Logger(
  subsystem: ".SDK.PurchasesClient",
  category: "Purchases"
)
