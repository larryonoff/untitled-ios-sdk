import Combine
import Dependencies
import DuckFoundation
import Foundation
import Network

extension ConnectivityClient: DependencyKey {
  public static let liveValue: Self = {
    let client = ConnectivityClientImpl()

    return Self(
      value: { client.value },
      values: { client.values() }
    )
  }()
}

/// Owns the single `NWPathMonitor` for the process and multiplexes its updates.
///
/// One system subscription feeds a `CurrentValueSubject`, so every consumer sees the
/// current connectivity immediately and shares one monitor — the subject handles
/// latest-value replay, fan-out, and teardown, and `value` reads synchronously.
private final class ConnectivityClientImpl: Sendable {
  private let monitor = NWPathMonitor()
  private let queue = DispatchQueue(label: "io.onelightapps.connectivity.monitor")

  // SAFETY: `CurrentValueSubject` is internally synchronized, so reads and sends are
  // safe from any thread; only this immutable reference crosses isolation boundaries.
  private nonisolated(unsafe) let subject: CurrentValueSubject<Connectivity, Never>
  private let didStart = Mutex(false)

  init() {
    subject = CurrentValueSubject(Connectivity(monitor.currentPath))
  }

  var value: Connectivity {
    startIfNeeded()
    return subject.value
  }

  func values() -> AsyncStream<Connectivity> {
    startIfNeeded()
    // `pathUpdateHandler` fires on any path change (interface, expensiveness, routes),
    // but we map only `status` — collapse the resulting duplicate values.
    return UncheckedSendable(
      subject
        .removeDuplicates()
        .values
    )
    .eraseToStream()
  }

  private func startIfNeeded() {
    didStart.withLock { started in
      guard !started else { return }
      started = true

      // SAFETY: `CurrentValueSubject` is internally synchronized; the wrapper only carries
      // the reference across the path-update closure, where we read `path.status` (a value
      // type) and `send` a `Sendable` `Connectivity`.
      let subject = UncheckedSendable(subject)
      monitor.pathUpdateHandler = { path in
        subject.wrappedValue.send(Connectivity(path))
      }
      monitor.start(queue: queue)
    }
  }

  deinit {
    monitor.cancel()
    subject.send(completion: .finished)
  }
}

private extension Connectivity {
  init(_ path: NWPath) {
    self.init(status: .init(path.status))
  }
}

private extension Connectivity.Status {
  init(_ status: NWPath.Status) {
    switch status {
    case .satisfied:
      self = .satisfied
    case .unsatisfied:
      self = .unsatisfied
    case .requiresConnection:
      self = .requiresConnection
    @unknown default:
      self = .unsatisfied
    }
  }
}
