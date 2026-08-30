import Combine
import Dependencies
import Foundation
import Sharing

#if os(macOS)
import AppKit
#elseif os(watchOS)
import WatchKit
#elseif canImport(UIKit)
import UIKit
#endif

extension SharedReaderKey where Self == ApplicationPhaseKey.Default {
  /// A shared, read-only view of the app's running phase.
  ///
  /// ```swift
  /// @SharedReader(.applicationPhase) var phase
  /// ```
  ///
  /// Transitions come from the projected publisher, which leads with the
  /// current phase:
  ///
  /// ```swift
  /// for await (old, new) in $phase.transitions.values { ... }
  /// ```
  public static var applicationPhase: Self {
    Self[ApplicationPhaseKey(), default: .inactive]
  }
}

/// Observes the host application's lifecycle.
///
/// The single place those notifications are read, so no other module needs to
/// know which framework names them or what each one means.
///
/// Every Apple platform reports the same three phases under different names:
/// UIKit posts `didBecomeActive`/`willResignActive`/`didEnterBackground`,
/// AppKit `didBecomeActive`/`willResignActive`/`didHide`, and watchOS mirrors
/// UIKit through `WKApplication`. An app extension has no host application at
/// all and stays `.background` — which is true of it, since an extension never
/// reaches the foreground.
public struct ApplicationPhaseKey: SharedReaderKey {
  public typealias Value = ApplicationPhase

  public var id: ApplicationPhaseKeyID {
    ApplicationPhaseKeyID()
  }

  public init() {}

  public func load(
    context: LoadContext<Value>,
    continuation: LoadContinuation<Value>
  ) {
    // Never `assumeIsolated` — it traps in release, and `load` runs wherever
    // the first reader happens to live.
    Task { @MainActor in
      continuation.resume(returning: .current)
    }
  }

  public func subscribe(
    context: LoadContext<Value>,
    subscriber: SharedSubscriber<Value>
  ) -> SharedSubscription {
    // SAFETY: the tokens are opaque — handed straight back to `removeObserver`
    // and never otherwise used. `SharedSubscription` takes a `@Sendable`
    // closure, so they cannot reach it without this annotation.
    nonisolated(unsafe) let observers = ApplicationPhase.notifications.map { name, phase in
      NotificationCenter.default.addObserver(
        forName: name,
        object: nil,
        queue: .main
      ) { _ in
        subscriber.yield(phase)
      }
    }

    return SharedSubscription {
      observers.forEach(NotificationCenter.default.removeObserver)
    }
  }
}

public struct ApplicationPhaseKeyID: Hashable {}

extension ApplicationPhase {
  /// The app did not reach the expected phase.
  ///
  /// Thrown by ``SharedReader/wait(for:timeout:)``. Carries the phase the app
  /// was in instead, which separates the reasons a wait can lapse — a
  /// backgrounded app is not a momentarily interrupted one, and work skipped
  /// for either reason is worth telling apart in a log.
  public struct TimeoutError: Swift.Error {
    /// The phase the caller waited for.
    public let expected: ApplicationPhase

    /// The phase the app was in instead.
    public let current: ApplicationPhase

    public init(expected: ApplicationPhase, current: ApplicationPhase) {
      self.expected = expected
      self.current = current
    }
  }
}

extension ApplicationPhase.TimeoutError: Equatable {}
extension ApplicationPhase.TimeoutError: Hashable {}
extension ApplicationPhase.TimeoutError: Sendable {}

extension SharedReader<ApplicationPhase> {
  /// Phase transitions, as `(old, new)` pairs.
  ///
  /// SwiftUI models change the same way — `onChange(of:) { old, new }` — and
  /// the pair answers what a bare phase cannot: whether the app *arrived*
  /// somewhere or *started* there. The first pair carries `old == nil`, which
  /// is how a process launched into the background is told apart from a user
  /// backgrounding the app.
  public var transitions: some Publisher<(old: ApplicationPhase?, new: ApplicationPhase), Never> {
    publisher
      // A host can post its activation notice more than once on some launch
      // paths, and a repeat is not a transition.
      .removeDuplicates()
      .scan((old: ApplicationPhase?, new: ApplicationPhase)?.none) { previous, phase in
        (old: previous?.new, new: phase)
      }
      .compactMap { $0 }
  }

  /// Suspends until the app is in `phase`, throwing if `timeout` elapses
  /// first.
  ///
  /// Returns at once if the app is already there. Otherwise the wait is a
  /// precondition rather than a courtesy: work that is only valid in `phase` —
  /// a system prompt that shows nothing unless the app is active — must not go
  /// ahead on a phase that never arrived, so a lapsed wait throws instead of
  /// reporting an outcome the caller can overlook.
  ///
  /// A `.zero` timeout asserts the phase already holds, and throws when it does
  /// not.
  ///
  /// Either outcome describes the moment the call returned. The phase can change
  /// immediately afterwards, which no amount of waiting can rule out.
  ///
  /// - Throws: ``ApplicationPhase/TimeoutError`` if the app is not in `phase`
  ///   by the time `timeout` elapses, or `CancellationError` if the calling
  ///   task is cancelled while waiting.
  public func wait(
    for phase: ApplicationPhase,
    timeout: Duration
  ) async throws {
    // A reader created moments ago still holds the `.inactive` default: the
    // key's `load` hops to the main actor and has not landed yet. Loading
    // first settles the real phase, so an app that is *already* in `phase`
    // returns here — it would otherwise wait out the full timeout, because a
    // phase already reached posts no further notification to wake the
    // subscription. Going through the key, rather than asking the host
    // directly, keeps an injected reader honest.
    try? await load()

    guard wrappedValue != phase else { return }

    guard timeout > .zero else {
      throw ApplicationPhase.TimeoutError(expected: phase, current: wrappedValue)
    }

    let reached = await withTaskGroup(of: Bool.self) { group in
      group.addTask { [self] in
        // The publisher leads with the current value, so a phase arriving
        // between the check above and the subscription isn't lost.
        // `AsyncPublisher` isn't `Sendable` — it has to be made in the task
        // that consumes it, not captured from outside.
        for await current in publisher.values where current == phase {
          return true
        }
        // Falling out of the loop is not reaching the phase: the stream ended,
        // or this task was cancelled. Only the `return` above means it arrived.
        return false
      }
      group.addTask {
        @Dependency(\.continuousClock) var clock
        try? await clock.sleep(for: timeout)
        return false
      }
      // Whichever finishes first wins; cancel the other.
      let reached = await group.next() ?? false
      group.cancelAll()
      return reached
    }

    guard reached else {
      // Cancellation is not a lapsed wait — the caller went away, and calling
      // it a missed phase would send it down the timeout path.
      try Task.checkCancellation()

      // The subscription only refreshes on a notification, and a wait that
      // lapsed in the background saw none — the phase on hand is still the one
      // `load()` left at the top. Settle it again, or the error reports that
      // stale value for exactly the case `current` exists to tell apart.
      try? await load()

      throw ApplicationPhase.TimeoutError(expected: phase, current: wrappedValue)
    }
  }
}

// MARK: - Platform

extension ApplicationPhase {
  /// The phase right now.
  @MainActor
  public static var current: ApplicationPhase {
    #if os(macOS)
    NSApplication.shared.isActive ? .active : .inactive
    #elseif os(watchOS)
    ApplicationPhase(WKApplication.shared().applicationState)
    #elseif canImport(UIKit)
    ApplicationPhase(UIApplication.shared.applicationState)
    #else
    // No host application to ask — an app extension is never in the
    // foreground, and saying so beats reporting a phase we cannot observe.
    .background
    #endif
  }

  /// The host's lifecycle notifications, paired with the phase each announces.
  static var notifications: [(Notification.Name, ApplicationPhase)] {
    #if os(macOS)
    [
      (NSApplication.didBecomeActiveNotification, .active),
      (NSApplication.willResignActiveNotification, .inactive),
      // AppKit has no "background": an app the user hid is the nearest thing,
      // and it stops work the same way.
      (NSApplication.didHideNotification, .background),
    ]
    #elseif os(watchOS)
    [
      (WKApplication.didBecomeActiveNotification, .active),
      (WKApplication.willResignActiveNotification, .inactive),
      (WKApplication.didEnterBackgroundNotification, .background),
    ]
    #elseif canImport(UIKit)
    [
      (UIApplication.didBecomeActiveNotification, .active),
      (UIApplication.willResignActiveNotification, .inactive),
      (UIApplication.didEnterBackgroundNotification, .background),
    ]
    #else
    []
    #endif
  }
}

#if os(watchOS)
extension ApplicationPhase {
  init(_ state: WKApplicationState) {
    switch state {
    case .active: self = .active
    case .inactive: self = .inactive
    case .background: self = .background
    @unknown default: self = .inactive
    }
  }
}
#elseif canImport(UIKit)
extension ApplicationPhase {
  init(_ state: UIApplication.State) {
    switch state {
    case .active: self = .active
    case .inactive: self = .inactive
    case .background: self = .background
    // A phase we don't know is not one to guess at; `.inactive` claims neither
    // foreground nor background.
    @unknown default: self = .inactive
    }
  }
}
#endif
