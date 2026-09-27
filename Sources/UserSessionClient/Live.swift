import Dependencies
import DuckConcurrency
import DuckDependencies
import DuckFoundation
import DuckLogging
import Foundation
import KeychainAccess

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension UserSessionClient: DependencyKey {
  public static let liveValue: Self = {
    let impl = UserSessionClientImpl(
      storage: .init(),
      minSessionDuration: 5 * 60
    )

    return UserSessionClient(
      activate: {
        impl.activate()
      },
      metrics: {
        impl.metrics
      },
      metricsChanges: {
        impl.metricsChanges
      },
      reset: {
        impl.reset()
      }
    )
  }()
}

final class UserSessionClientImpl: Sendable {
  private let bundle: BundleInfo
  private let date: DateGenerator

  let storage: KeychainStorage
  let minSessionDuration: TimeInterval

  /// Current-value broadcast: a subscriber arriving after `metrics` was read
  /// still opens with the latest value, so no change can fall in between.
  private let updates: AsyncBroadcast<UserSessionMetrics>

  private struct State {
    var metrics: UserSessionMetrics
    var isActive = false
    var isSuspended = false
    /// Whether storage has been read, so `metrics` reflects it. A keychain read
    /// fails before first unlock (silent push, background fetch); saving the
    /// fresh stand-in then would overwrite the real record once it unlocks.
    var hasReadStorage: Bool
  }

  // SAFETY: written once from `subscribe()`, which the `isActive` check in
  // `activate()` guarantees runs at most once, and read only in `deinit` after
  // every other reference is gone. The tokens are opaque and never mutated.
  private nonisolated(unsafe) var observers: [any NSObjectProtocol] = []

  private let state: Mutex<State>

  var metrics: UserSessionMetrics {
    state.withLock { $0.metrics }
  }

  var metricsChanges: AsyncStream<UserSessionMetrics> {
    // State, not events: a consumer that falls behind needs only the latest.
    updates.stream(bufferingPolicy: .bufferingNewest(1))
  }

  init(
    storage: KeychainStorage,
    minSessionDuration: TimeInterval
  ) {
    @Dependency(\.bundle) var bundle
    @Dependency(\.date) var date

    self.bundle = bundle
    self.date = date
    self.minSessionDuration = minSessionDuration
    self.storage = storage

    let stored: UserSessionMetrics?
    let hasReadStorage: Bool
    do {
      stored = try storage.loadMetrics()
      hasReadStorage = true
    } catch {
      stored = nil
      hasReadStorage = false
    }

    let metrics = stored ?? .init(date: date(), version: bundle.version)

    self.state = Mutex(State(metrics: metrics, hasReadStorage: hasReadStorage))
    self.updates = AsyncBroadcast(metrics)
  }

  /// Applies a mutation to the stored metrics, then persists and publishes the
  /// result. The mutation runs inside the lock; the side effects run outside it,
  /// so `storage.save` and subscriber callbacks never re-enter the lock.
  ///
  /// While storage was unreadable, each call retries the read first and, once
  /// it succeeds, applies the mutation to the real record in place of the
  /// stand-in. Until then nothing is saved.
  private func withMetrics(_ body: (inout UserSessionMetrics) -> Void) {
    let (newValue, hasReadStorage) = state.withLock { state -> (UserSessionMetrics, Bool) in
      if !state.hasReadStorage {
        do {
          if let stored = try storage.loadMetrics() { state.metrics = stored }
          state.hasReadStorage = true
        } catch {}
      }
      body(&state.metrics)
      return (state.metrics, state.hasReadStorage)
    }

    // ponytail: never persists while the keychain stays unreadable; add a
    // UserDefaults fallback if that turns out to happen past first unlock.
    if hasReadStorage { storage.save(newValue) }
    updates.yield(newValue)
  }

  func activate() {
    let shouldActivate = state.withLock { state -> Bool in
      guard !state.isActive else { return false }
      state.isActive = true
      return true
    }

    guard shouldActivate else {
      log.info(
        """
        user-session.activate skipped | \
        reason: already_active
        """
      )
      return
    }

    // Subscribe first: a launch that is not on screen yet counts its session
    // when the app appears, and missing that notification would lose it.
    subscribe()

    let date = date()
    let version = bundle.version
    let isOnScreen = Self.isApplicationOnScreen

    // A launch the user never saw — a prewarm, a silent push, a background
    // fetch — is not a session. Counting it would both invent one and consume
    // the number the real session was going to get, because the arrival that
    // opens that session is a phase change this process has already passed.
    // So the session is left closed and the first `didBecomeActive` opens it.
    state.withLock { $0.isSuspended = !isOnScreen }

    withMetrics { metrics in
      // Version bookkeeping happens on every launch, on screen or not: it
      // records which build is running, not that anyone is using it.
      metrics.trackVersion(version)

      guard isOnScreen else { return }

      metrics.open(
        at: date,
        minSessionDuration: minSessionDuration
      )
    }

    log.info(
      """
      user-session.activate success | \
      is_on_screen: \(isOnScreen, privacy: .public)
      """
    )
  }

  /// Whether the app is in front of the user right now.
  ///
  /// Read synchronously so a session is counted by the time `activate()`
  /// returns: callers report the session number during launch, and one settled
  /// a notification later would be reported stale.
  ///
  /// Off the main thread the phase cannot be read at all — `assumeIsolated`
  /// would trap rather than answer — so such a caller is treated as not on
  /// screen and the first `didBecomeActive` settles it.
  private static var isApplicationOnScreen: Bool {
    guard Thread.isMainThread else { return false }
    return MainActor.assumeIsolated { ApplicationPhase.current } == .active
  }

  func reset() {
    log.info("user-session.reset")

    let date = date()
    let version = bundle.version

    withMetrics {
      $0 = UserSessionMetrics(date: date, version: version)
    }
  }

  private func restore() {
    let wasSuspended = state.withLock { state -> Bool in
      guard state.isSuspended else { return false }
      state.isSuspended = false
      return true
    }

    // Not suspended means the app was already on screen — `activate()` opened
    // the session, and `didBecomeActive` also arrives after interruptions that
    // never took it away, such as a dismissed alert or control centre.
    guard wasSuspended else {
      log.info(
        """
        user-session.restore skipped | \
        reason: not_suspended
        """
      )
      return
    }

    let date = date()

    withMetrics {
      $0.open(
        at: date,
        minSessionDuration: minSessionDuration
      )
    }

    log.info("user-session.restore success")
  }

  private func suspend() {
    log.info("user-session.suspend")

    state.withLock { $0.isSuspended = true }

    let date = date()
    withMetrics { $0.suspend(at: date) }
  }

  private func terminate() {
    let wasSuspended = state.withLock { state -> Bool in
      defer { state.isSuspended = true }
      return state.isSuspended
    }

    // Terminating from the background: `willResignActive` already charged the
    // foreground time, and suspending again would charge it twice.
    guard !wasSuspended else {
      log.info(
        """
        user-session.terminate skipped | \
        reason: already_suspended
        """
      )
      return
    }

    log.info("user-session.terminate")

    let date = date()
    withMetrics { $0.suspend(at: date) }
  }

  private func subscribe() {
    // Observer tokens were previously dropped on the floor, leaving no way to
    // unregister; keep them so `deinit` can remove the observations.
    observers = [
      NotificationCenter.default.addObserver(
        forName: .applicationDidBecomeActive,
        object: nil,
        queue: nil
      ) { [weak self] _ in
        self?.restore()
      },
      NotificationCenter.default.addObserver(
        forName: .applicationWillResignActive,
        object: nil,
        queue: nil
      ) { [weak self] _ in
        self?.suspend()
      },
      NotificationCenter.default.addObserver(
        forName: .applicationWillTerminate,
        object: nil,
        queue: nil
      ) { [weak self] _ in
        self?.terminate()
      }
    ]
  }

  deinit {
    observers.forEach(NotificationCenter.default.removeObserver)
  }
}

/// - Isolation: none; safe to use from any isolation domain.
// SAFETY: every stored property is a `let`. `Keychain` wraps the Keychain
// Services C API, which is thread-safe, and exposes only computed properties
// over its immutable options. `JSONDecoder`/`JSONEncoder` are classes but hold
// no mutable state once configured, and neither is reconfigured here.
struct KeychainStorage: @unchecked Sendable {
  private let keychain: Keychain = {
    let prefix = Bundle.main.bundleIdentifier ?? ""
    return Keychain(service: "\(prefix).user-session")
  }()

  let decoder = JSONDecoder()
  let encoder = JSONEncoder()

  /// Throws when the keychain cannot be read (before first unlock), so the
  /// caller can tell that apart from a missing record. An undecodable record
  /// is treated as missing: it would never become readable.
  func loadValue<Value: Decodable>(at key: String) throws -> Value? {
    let data: Data?
    do {
      data = try keychain.getData(key)
    } catch {
      log.error(
        """
        user-session.load failed | \
        key: \(key, privacy: .public)
        error: \(error, privacy: .public)
        """
      )
      throw error
    }

    guard let data else { return nil }

    do {
      return try decoder.decode(Value.self, from: data)
    } catch {
      log.error(
        """
        user-session.decode failed | \
        key: \(key, privacy: .public)
        error: \(error, privacy: .public)
        """
      )
      return nil
    }
  }

  func saveValue<Value: Encodable>(_ newValue: Value?, at key: String) {
    do {
      if let newValue {
        let data = try encoder.encode(newValue)
        try keychain.set(data, key: key)
      } else {
        try keychain.remove(key)
      }
    } catch {
      log.error(
        """
        user-session.save failed | \
        key: \(key, privacy: .public)
        error: \(error, privacy: .public)
        """
      )
    }
  }

  func loadMetrics() throws -> UserSessionMetrics? {
    try loadValue(at: .metrics)
  }

  func save(_ newValue: UserSessionMetrics?) {
    saveValue(newValue, at: .metrics)
  }
}

extension String {
  static var metrics: String { "metrics" }
}

let log = Logger(
  subsystem: ".SDK.UserSessionClient",
  category: "UserTracking"
)
