import Foundation

/// An error thrown by ``withTaskTimeout(for:tolerance:clock:isolation:body:)``
/// when the operation exceeds its allotted time.
///
/// Modeled after SE-0526's `CancellationError.Reason` so migrating to the
/// standard-library cooperative-deadline API later is a mechanical change.
public struct TaskTimeoutError: Swift.Error {
  public enum Reason {
    /// The operation's deadline expired before it completed.
    case deadlineExpired
    /// The surrounding task was cancelled.
    case taskCancelled
  }

  public let reason: Reason

  public init(reason: Reason = .deadlineExpired) {
    self.reason = reason
  }
}

extension TaskTimeoutError.Reason: Equatable {}
extension TaskTimeoutError.Reason: Sendable {}

extension TaskTimeoutError: Equatable {}

extension TaskTimeoutError: LocalizedError {
  public var errorDescription: String? {
    switch reason {
    case .deadlineExpired:
      "The operation timed out before it completed."
    case .taskCancelled:
      "The operation was cancelled."
    }
  }
}

extension TaskTimeoutError: Sendable {}

public func withTaskTimeout<T: Sendable, C: Clock>(
  for interval: C.Instant.Duration,
  tolerance: C.Instant.Duration? = nil,
  clock: C,
  isolation: isolated (any Actor)? = #isolation,
  body: @escaping @Sendable @isolated(any) () async throws -> sending T
) async throws -> T {
  // The task group is non-throwing: child tasks catch their own errors and map
  // them to `_TaskTimeoutOutcome`, and the group closure returns a `Result` that
  // we unwrap (`try result.get()`) only after the group has fully drained. This
  // keeps ordering explicit and the body's own error unwrapped.
  let result: Result<T, any Error> = await withTaskGroup(
    of: _TaskTimeoutOutcome<T>.self
  ) { group in
    // Work task: runs on the body's own isolation.
    group.addTask {
      do {
        return .completed(try await body())
      } catch {
        return .failed(error)
      }
    }

    // Timer task: a normal return means the deadline elapsed (.timedOut); a thrown
    // error means the sleep itself was cancelled (.cancelled = outer cancellation).
    group.addTask {
      do {
        try await clock.sleep(for: interval, tolerance: tolerance)
        return .timedOut
      } catch {
        return .cancelled
      }
    }

    switch await group.next() {
    case let .completed(value):
      // Body finished first. Cancel the timer and return.
      group.cancelAll()
      return .success(value)

    case let .failed(error):
      // Body threw before the deadline. Cancel the timer and surface it unwrapped.
      group.cancelAll()
      return .failure(error)

    case .timedOut:
      // The deadline elapsed. Cancel the work task and await its terminal result
      // so we never abandon it. If the body managed to complete or fail with its
      // own (non-cancellation) error in the meantime, that real outcome wins;
      // otherwise the body unwound due to our cancellation and the deadline is the
      // cause.
      group.cancelAll()

      switch await group.next() {
      case let .completed(value):
        return .success(value)
      case let .failed(error) where !(error is CancellationError):
        return .failure(error)
      case .failed, .timedOut, .cancelled, .none:
        return .failure(TaskTimeoutError(reason: .deadlineExpired))
      }

    case .cancelled, .none:
      // The outer task was cancelled (the timer's sleep threw), or the group
      // produced no result. Cancel the work task and surface its own outcome,
      // including the CancellationError it throws in response.
      group.cancelAll()

      switch await group.next() {
      case let .completed(value):
        return .success(value)
      case let .failed(error):
        return .failure(error)
      case .timedOut, .cancelled, .none:
        return .failure(CancellationError())
      }
    }
  }

  return try result.get()
}

public func withTaskTimeout<T: Sendable>(
  for interval: SuspendingClock.Instant.Duration,
  tolerance: SuspendingClock.Instant.Duration? = nil,
  isolation: isolated (any Actor)? = #isolation,
  body: @escaping @Sendable @isolated(any) () async throws -> sending T
) async throws -> T {
  try await withTaskTimeout(
    for: interval,
    tolerance: tolerance,
    clock: SuspendingClock(),
    isolation: isolation,
    body: body
  )
}

private enum _TaskTimeoutOutcome<T: Sendable>: Sendable {
  case completed(T)
  case failed(any Error)
  case timedOut
  case cancelled
}
