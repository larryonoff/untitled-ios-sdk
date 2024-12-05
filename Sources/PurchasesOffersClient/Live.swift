import Combine
import Dependencies
import Foundation
import DuckDependencies
import DuckLogging
import DuckPaywallDependencies
import DuckPurchases
import DuckPurchasesClient
import DuckRemoteSettingsClient
import UIKit

extension PurchasesOffersClient {
  public static func live(
    offers: Set<PurchasesOfferType>,
    appStorage: UserDefaults,
    paywallID: PaywallIDGenerator,
    purchases: PurchasesClient,
    remoteSettings: RemoteSettingsClient
  ) -> Self {
    let impl = PurchasesOffersClientImpl(
      offers: offers,
      appStorage: appStorage,
      paywallID: paywallID,
      purchases: purchases,
      remoteSettings: remoteSettings
    )

    impl.initialize()

    return Self(
      run: {
        await impl.run()
      },
      activeOffer: {
        impl.activeOffer.value
      },
      activeOfferUpdates: {
        UncheckedSendable(
          impl.activeOffer
            .dropFirst() // drop first since we need only changes, but the first value
            .removeDuplicates()
            .values
        )
        .eraseToStream()
      },
      logPaywallEvent: {
        impl.logPaywall($0, paywallType: $1, event: $2)
      },
      reset: {
        await impl.reset()
      }
    )
  }
}

final class PurchasesOffersClientImpl {
  private let offersConditions: [PurchasesOfferCondition]
  private let appStorage: UserDefaults
  private let paywallID: PaywallIDGenerator
  private let purchases: PurchasesClient
  private let remoteSettings: RemoteSettingsClient

  @Dependency(\.date) private var date

  let activeOffer = CurrentValueSubject<PurchasesOffer?, Never>(nil)

  private var timerHandle: Task<Void, Never>?
  private var purchasesHandle: Task<Void, Never>?
  private var appLifecycleHandle: Task<Void, Never>?

  init(
    offers: Set<PurchasesOfferType>,
    appStorage: UserDefaults,
    paywallID: PaywallIDGenerator,
    purchases: PurchasesClient,
    remoteSettings: RemoteSettingsClient
  ) {
    self.offersConditions = [
      offers.contains(.blackFriday) ? PurchasesOfferCondition.blackFriday(
        appStorage: appStorage,
        paywallID: paywallID,
        purchases: purchases,
        remoteSettings: remoteSettings
      ) : nil,
//      offers.contains(.limitedTime) ? PurchasesOfferCondition.limitedTime(
//        appStorage: appStorage,
//        paywallID: paywallID,
//        purchases: purchases,
//        remoteSettings: remoteSettings
//      ) : nil,
      offers.contains(.introductory) ? PurchasesOfferCondition.introductory(
        appStorage: appStorage,
        paywallID: paywallID,
        purchases: purchases,
        remoteSettings: remoteSettings
      ) : nil,
    ].compactMap { $0 }

    self.appStorage = appStorage
    self.purchases = purchases
    self.paywallID = paywallID
    self.remoteSettings = remoteSettings
  }

  func run() async {
    guard !offersConditions.isEmpty else { return }

    try? await remoteSettings.fetch(.request())

    await updateOffer(for: purchases.purchases())

    subscribePurchases()
    subscribeAppLifecycle()

    await prefetchPaywall(for: activeOffer.value)
  }

  private func subscribePurchases() {
    purchasesHandle?.cancel()
    purchasesHandle = Task.detached(priority: .low) { [weak self] in
      guard let purchasesUpdates = self?.purchases.purchasesUpdates() else {
        return
      }

      for await purchases in purchasesUpdates {
        guard let self else { return }

        await self.updateOffer(for: purchases)
      }
    }
  }

  private func subscribeAppLifecycle() {
    appLifecycleHandle?.cancel()
    appLifecycleHandle = Task.detached(priority: .low) { [weak self] in
      let notifications = NotificationCenter.default
        .notifications(named: UIApplication.didBecomeActiveNotification)
        .map { _ in }

      for await _ in notifications {
        guard let self else { return }

        await self.updateOffer(
          for: self.purchases.purchases()
        )
      }
    }
  }

  func logPaywall(
    _ paywall: Paywall?,
    paywallType: Paywall.PaywallType,
    event: PurchasesOffersClient.PaywallEvent
  ) {
    switch event {
    case .dismiss:
      if paywallType == .main {
        appStorage.wasMainPaywallDismissed = true
      }

      Task {
        await updateOffer(
          for: purchases.purchases(),
          paywallType: paywallType
        )
      }
    case .present:
      Task {
        await updateOffer(
          for: purchases.purchases(),
          paywallType: paywallType
        )
      }
    }
  }

  func reset() async {
    cancelTimer()

    purchasesHandle?.cancel()
    purchasesHandle = nil

    appStorage.wasMainPaywallDismissed = false
    appStorage.wasLimitedTimeOfferActive = false
    appStorage.purchasesOffer = nil

    await run()
  }

  func initialize() {
    let purchases = self.purchases.purchases()

    guard !purchases.isPremium else { return }
    guard let offer = appStorage.purchasesOffer else { return }

    let now = date()
    guard offer.isValid(for: now) else { return }

    if let endDate = offer.endDate {
      runTimerIfNeeded(endDate: endDate)
    }

    activeOffer.value = offer
  }

  // MARK: - Offers

  private func updateOffer(
    for purchases: Purchases,
    paywallType: Paywall.PaywallType? = nil
  ) async {
    logger.info("update offer")

    guard !purchases.isPremium else {
      activeOffer.value = nil
      cancelTimer()

      logger.warning("update offer complete", dump: [
        "info": "user has premium. Offer is nil"
      ])

      return
    }

    let now = date()

    var suggestedOffer: PurchasesOffer?

    for condition in offersConditions {
      suggestedOffer = await condition.calculateOffer(now, paywallType)
      if suggestedOffer != nil { break }
    }

    let isOfferValid = suggestedOffer?.isValid(for: now) == true

    if !isOfferValid {
      cancelTimer()
    } else if let endDate = suggestedOffer?.endDate {
      runTimerIfNeeded(endDate: endDate)
    } else if suggestedOffer == nil {
      cancelTimer()
    }

    if suggestedOffer?.is(\.blackFriday) == true || suggestedOffer?.is(\.limitedTime) == true {
      appStorage.wasLimitedTimeOfferActive = true
    }

    if isOfferValid {
      logger.info("update offer complete", dump: [
        "offer": suggestedOffer as Any
      ])

      appStorage.purchasesOffer = suggestedOffer
      activeOffer.value = suggestedOffer
    } else {
      logger.warning("update offer complete", dump: [
        "offer": suggestedOffer as Any,
        "info": "offer is not valid"
      ])

      appStorage.purchasesOffer = nil
      activeOffer.value = nil
    }
  }

  // MARK: -

  private func prefetchPaywall(for offer: PurchasesOffer?) async {
    guard let offer else { return }

    switch offer {
    case .blackFriday:
      await self.purchases
        .prefetch(paywallByID: paywallID(.Offer.blackFriday))
    case .introductory:
      await self.purchases
        .prefetch(paywallByID: paywallID(.Offer.introductory))
    case .limitedTime:
      await self.purchases
        .prefetch(paywallByID: paywallID(.Offer.limitedTime))
    }
  }

  private func runTimerIfNeeded(endDate: Date) {
    guard timerHandle == nil else { return }

    let now = date()
    let timerDuration = endDate.timeIntervalSince(now)

    timerHandle = Task(priority: .low) { [weak self] in
      try? await Task.sleep(for: .seconds(timerDuration))

      guard !Task.isCancelled else { return }

      if let self {
        await self.updateOffer(
          for: self.purchases.purchases()
        )
      }
    }
  }

  private func cancelTimer() {
    timerHandle?.cancel()
    timerHandle = nil
  }
}
