import Foundation
import Synchronization

/// Runs at most `concurrency` operations at a time; the rest wait in arrival order.
public final class AsyncQueue: Sendable {
  private typealias WaitingContinuation = CheckedContinuation<Void, any Error>

  private struct Waiter {
    let id: UUID
    let continuation: WaitingContinuation
  }

  // Invariant: `waiters` is non-empty only while `runningCount == maxConcurrentOperationCount`.
  // A finishing operation hands its slot straight to the first waiter, so `runningCount` counts
  // every operation that has started and not yet finished.
  private struct State {
    var runningCount = 0
    var waiters: [Waiter] = []
  }

  private let maxConcurrentOperationCount: Int
  private let state = Mutex(State())

  public init(concurrency: Int = 1) {
    self.maxConcurrentOperationCount = max(concurrency, 1)
  }

  public func enqueue<T>(
    _ operation: @Sendable () async throws -> sending T
  ) async throws -> T {
    try await acquire()
    defer { release() }
    return try await operation()
  }

  private func acquire() async throws {
    let id = UUID()
    try await withTaskCancellationHandler {
      try await withCheckedThrowingContinuation { (continuation: WaitingContinuation) in
        enum Admission { case start, wait, cancel }
        let admission: Admission = state.withLock { state in
          // Cancellation that lands before the waiter is registered finds nothing to resume in
          // `onCancel`, so it is observed here, under the same lock.
          if Task.isCancelled { return .cancel }
          if state.runningCount < maxConcurrentOperationCount {
            state.runningCount += 1
            return .start
          }
          state.waiters.append(Waiter(id: id, continuation: continuation))
          return .wait
        }
        switch admission {
        case .start: continuation.resume()
        case .cancel: continuation.resume(throwing: CancellationError())
        case .wait: break
        }
      }
    } onCancel: {
      let continuation = state.withLock { state -> WaitingContinuation? in
        guard let index = state.waiters.firstIndex(where: { $0.id == id }) else { return nil }
        return state.waiters.remove(at: index).continuation
      }
      continuation?.resume(throwing: CancellationError())
    }
  }

  private func release() {
    let next = state.withLock { state -> WaitingContinuation? in
      guard !state.waiters.isEmpty else {
        state.runningCount -= 1
        return nil
      }
      return state.waiters.removeFirst().continuation
    }
    next?.resume()
  }

  // MARK: - Diagnostics

  /// Returns diagnostic information about the queue state
  @_spi(Diagnostics)
  public func diagnosticInfo() -> String {
    state.withLock { state in
      "Queue(concurrency: \(maxConcurrentOperationCount), running: \(state.runningCount), waiting: \(state.waiters.count))"
    }
  }
}
