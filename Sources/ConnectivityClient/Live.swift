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

  init() {
    // Seeded optimistically, not from `monitor.currentPath`: the path is not meaningful
    // until the first `pathUpdateHandler` fires, and reading it before `start` reports
    // "offline" on a perfectly online device — a false offline banner that every observer
    // then sees. A wrong `.satisfied` for the milliseconds until the first update is
    // invisible by comparison, and self-corrects.
    subject = CurrentValueSubject(Connectivity(status: .satisfied))

    // SAFETY: `CurrentValueSubject` is internally synchronized; the wrapper only carries
    // the reference across the path-update closure, where we read `path.status` (a value
    // type) and `send` a `Sendable` `Connectivity`.
    let subject = UncheckedSendable(subject)
    monitor.pathUpdateHandler = { path in
      subject.wrappedValue.send(Connectivity(path))
    }
    // Started here rather than lazily on first use, so the real path is usually known
    // before anyone reads it.
    monitor.start(queue: queue)
  }

  var value: Connectivity {
    subject.value
  }

  func values() -> AsyncStream<Connectivity> {
    // `pathUpdateHandler` fires on any path change (interface, expensiveness, routes),
    // but we map only `status` — collapse the resulting duplicate values.
    UncheckedSendable(
      subject
        .removeDuplicates()
        .values
    )
    .eraseToStream()
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
