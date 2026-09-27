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
  /// Refreshes itself for as long as anyone holds it — once on subscribing,
  /// then each time the app becomes active — so nothing has to be sent to keep
  /// it fresh.
  public static var offerAvailability: Self {
    Self[OfferAvailabilityKey(), default: OfferAvailability()]
  }
}

public struct OfferAvailabilityKey: SharedKey {
  @Dependency(\.context) private var dependencyContext
  @Dependency(\.paywallTargeting) var paywallTargeting
  @Dependency(\.purchases) var purchases
  @Dependency(\.remoteSettings) var remoteSettings

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
      let activations = NotificationCenter.default.notifications(
        named: Self.didBecomeActive
      )

      var availability = OfferAvailability()
      availability.merge(await fetch())
      subscriber.yield(availability)

      // One refresh at a time, so a slow one can't land after a newer one.
      for await _ in activations {
        availability.merge(await fetch())
        subscriber.yield(availability)
      }
    }

    return SharedSubscription {
      task.cancel()
    }
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
