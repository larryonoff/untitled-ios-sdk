import Combine
import ComposableArchitecture
import Dependencies
import DuckDependencies
import DuckLogging
import Foundation
import KeychainAccess
import UIKit

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

final class UserSessionClientImpl {
  @Dependency(\.bundle) private var bundle
  @Dependency(\.date) private var date

  let storage: KeychainStorage
  let minSessionDuration: TimeInterval

  private let metricsSubject = PassthroughSubject<UserSessionMetrics, Never>()
  private var _metrics: UserSessionMetrics {
    willSet {
      metricsSubject.send(newValue)
    }
  }

  var metrics: UserSessionMetrics {
    get {
      lock.withLock { _metrics }
    }
    set {
      lock.withLock {
        _metrics = newValue

        storage.save(newValue)
      }
    }
  }

  var metricsChanges: AsyncStream<UserSessionMetrics> {
    AsyncStream(metricsSubject.values)
  }

  private let lock = NSRecursiveLock()

  private var isActive = false
  private var isSuspended = false

  init(
    storage: KeychainStorage,
    minSessionDuration: TimeInterval
  ) {
    @Dependency(\.bundle) var bundle
    @Dependency(\.date) var date

    self.minSessionDuration = minSessionDuration
    self.storage = storage

    self._metrics = storage.loadMetrics() ?? .init(
      date: date(),
      version: bundle.version
    )
  }

  func activate() {
    log.info("\(#function)")

    lock.withLock {
      guard !isActive else { return }
      defer { isActive = true }

      subscribe()

      metrics.activate(
        at: date(),
        minSessionDuration: minSessionDuration,
        version: bundle.version
      )
    }
  }

  func reset() {
    log.info("\(#function)")

    metrics = .init(
      date: date(),
      version: bundle.version
    )
  }

  private func restore() {
    log.info("\(#function)")

    lock.withLock {
      guard isSuspended else {
        log.info("\(#function) skipped", dump: [
          "reason": "suspended is false"
        ])
        return
      }
      defer { isSuspended = false }

      metrics.restore(
        at: date(),
        minSessionDuration: minSessionDuration
      )
    }
  }

  private func suspend() {
    log.info("\(#function)")

    lock.withLock {
      defer { isSuspended = true }

      metrics.suspend(at: date())
    }
  }

  private func terminate() {
    log.info("\(#function)")

    metrics.suspend(at: date())
  }

  private func subscribe() {
    let didBecomeActive = NotificationCenter.default.addObserver(
      forName: UIApplication.didBecomeActiveNotification,
      object: nil,
      queue: nil
    ) { [weak self] _ in
      self?.restore()
    }

    let willResignActive = NotificationCenter.default.addObserver(
      forName: UIApplication.willResignActiveNotification,
      object: nil,
      queue: nil
    ) { [weak self] _ in
      self?.suspend()
    }

    let willTerminate = NotificationCenter.default.addObserver(
      forName: UIApplication.willTerminateNotification,
      object: nil,
      queue: nil
    ) { [weak self] _ in
      self?.terminate()
    }
  }
}

struct KeychainStorage {
  private let keychain: Keychain = {
    let prefix = Bundle.main.bundleIdentifier ?? ""
    return Keychain(service: "\(prefix).user-session")
  }()

  let decoder = JSONDecoder()
  let encoder = JSONEncoder()

  func loadValue<Value: Decodable>(
    at key: String,
    default defaultValue: Value?
  ) -> Value? {
    do {
      guard let data = try keychain.getData(key) else {
        return nil
      }

      return try decoder.decode(Value.self, from: data)
    } catch {
      log.error("loadValue failure", dump: [
        "error": error,
        "key": key
      ])
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
      log.error("saveValue failure", dump: [
        "error": error,
        "key": key,
        "value": newValue
      ])
    }
  }

  func loadMetrics() -> UserSessionMetrics? {
    loadValue(at: .metrics, default: nil)
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
