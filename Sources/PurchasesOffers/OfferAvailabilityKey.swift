import Dependencies
import DuckPaywallTargeting
import DuckPurchasesClient
import DuckRemoteSettingsClient
import Foundation
import Sharing

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension SharedKey where Self == OfferAvailabilityKey.Default {
  /// What remote config and the purchases provider make available in this
  /// session.
  ///
  /// Refreshes itself for as long as anyone holds it — each time the app
  /// becomes active, and on subscribing if it already is — so nothing has to
  /// be sent to keep it fresh.
  public static var offerAvailability: Self {
    Self[OfferAvailabilityKey(), default: OfferAvailability()]
  }
}

public struct OfferAvailabilityKey: SharedKey {
  @Dependency(\.context) private var dependencyContext
  @Dependency(\.date) var date
  @Dependency(\.paywallTargeting) var paywallTargeting
  @Dependency(\.purchases) var purchases
  @Dependency(\.remoteSettings) var remoteSettings
  @Dependency(\.supportedOffers) var supportedOffers

  public typealias Value = OfferAvailability

  public var id: OfferAvailabilityKeyID {
    OfferAvailabilityKeyID()
  }

  public init() {}

  public func load(
    context: LoadContext<Value>,
    continuation: LoadContinuation<Value>
  ) {
    continuation.resumeReturningInitialValue()
  }

  public func save(
    _ value: Value,
    context: SaveContext,
    continuation: SaveContinuation
  ) {
    // Session-only, like `.inMemory`: there is nowhere to write it.
    continuation.resume()
  }

  public func subscribe(
    context: LoadContext<Value>,
    subscriber: SharedSubscriber<Value>
  ) -> SharedSubscription {
    // Tests and previews set the availability they need; fetching would reach
    // clients they left unimplemented.
    guard dependencyContext == .live else {
      return SharedSubscription {}
    }

    let task = Task {
      // Iterating before the check below: the observer is registered with the
      // iterator, and an activation between the two would otherwise be missed.
      var activations = NotificationCenter.default.notifications(
        named: Self.didBecomeActive
      )
      .makeAsyncIterator()

      // Read at each fetch: the first offer depends on what's been shown.
      @SharedReader(.offerHistory) var history
      var availability = OfferAvailability()

      // Not before the app is active. The state holding this key is created
      // while the app launches, before the host configures the clients
      // `fetch()` reads: Firebase raises on a Remote Config read ahead of
      // `FirebaseApp.configure()`. Launch ends in the activation below.
      if await Self.isAppActive {
        availability.merge(await fetch(history: history))
        subscriber.yield(availability)
      }

      // One refresh at a time, so a slow one can't land after a newer one.
      while await activations.next() != nil {
        availability.merge(await fetch(history: history))
        subscriber.yield(availability)
      }
    }

    return SharedSubscription {
      task.cancel()
    }
  }

  @MainActor
  private static var isAppActive: Bool {
    #if os(macOS)
    NSApplication.shared.isActive
    #elseif canImport(UIKit) && !os(watchOS)
    UIApplication.shared.applicationState == .active
    #else
    true
    #endif
  }

  private static var didBecomeActive: Notification.Name {
    #if os(macOS)
    NSApplication.didBecomeActiveNotification
    #elseif canImport(UIKit)
    UIApplication.didBecomeActiveNotification
    #else
    Notification.Name("OfferAvailabilityKey.neverPosted")
    #endif
  }
}

public struct OfferAvailabilityKeyID: Hashable {}
