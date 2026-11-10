// A back-port of SE-0526 `withDeadline` (swiftlang/swift#91190).
//
// The standard library ships it with the Swift 6.5 runtime (`StdlibDeploymentTarget 6.5`, an OS
// after iOS 27). Without the runtime's cancellation scopes the back-port differs:
// - the operation runs in a child task, so it is `sending @escaping @isolated(any)`, returns a
//   `Sendable` value, throws untyped errors and cannot return `~Copyable` values (`Task.value`
//   requires a `Sendable`, `Copyable` result and erases the error type);
// - expiry throws `TaskTimeoutError` instead of `CancellationError` with `reason == .deadlineExpired`;
// - the clock need not be `Identifiable` (swift-clocks' `TestClock` is not).
//
// A Swift 6.5 SDK declares `withDeadline` too; should a call become ambiguous, spell it
// `DuckConcurrency.withDeadline`. Delete this file once the deployment target reaches the
// Swift 6.5 runtime.
//
// ponytail: no nested-deadline composition and no `Task.activeDeadline` (needs a task-local);
// add them when a caller nests deadlines.

import Foundation

/// An error thrown by ``withDeadline(_:tolerance:clock:isolation:operation:)``
/// when the operation outlives its deadline.
///
/// The standard-library `withDeadline` throws `CancellationError` with
/// `reason == .deadlineExpired` instead. Once the deployment target reaches it, migrate
/// `catch let error as TaskTimeoutError where error.reason == .deadlineExpired` to
/// `catch let error as CancellationError where error.reason == .deadlineExpired`.
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

/// Runs `operation`, cancelling it once `expiration` passes on `clock`.
///
/// After expiry the operation is cancelled and awaited: if it still completes, or fails with its
/// own error, that outcome is returned; otherwise ``TaskTimeoutError`` (`.deadlineExpired`) is
/// thrown. A deadline that has already passed cancels the operation before it starts. Outer
/// cancellation reaches the operation, whose own outcome is returned.
public func withDeadline<Return: Sendable, C: Clock>(
  _ expiration: C.Instant,
  tolerance: C.Instant.Duration? = nil,
  clock: C = ContinuousClock(),
  isolation: isolated (any Actor)? = #isolation,
  operation: sending @escaping @isolated(any) () async throws -> sending Return
) async throws -> Return {
  // `operation` is `sending`, so it can be handed to one task only from here: a
  // closure the task group captures is no longer disconnected, and region
  // isolation rejects sending it on to `addTask`. The work child owns this task
  // instead: it awaits it and forwards its own cancellation, so the group still
  // drains only after `operation` has finished.
  let isExpired = clock.now >= expiration
  let work = Task {
    if isExpired {
      // SAFETY: the handle is this task's own and never leaves the closure.
      withUnsafeCurrentTask { $0?.cancel() }
    }
    return try await operation()
  }

  // The task group is non-throwing: child tasks catch their own errors and map
  // them to `_DeadlineOutcome`, and the group closure returns a `Result` that
  // we unwrap (`try result.get()`) only after the group has fully drained. This
  // keeps ordering explicit and the operation's own error unwrapped.
  let result: Result<Return, any Error> = await withTaskGroup(
    of: _DeadlineOutcome<Return>.self
  ) { group in
    // Work child: `operation` runs on its own isolation inside `work`.
    group.addTask {
      do {
        return try await .completed(
          withTaskCancellationHandler {
            try await work.value
          } onCancel: {
            work.cancel()
          }
        )
      } catch {
        return .failed(error)
      }
    }

    // Timer task: a normal return means the deadline elapsed (.timedOut); a thrown
    // error means the sleep itself was cancelled (.cancelled = outer cancellation).
    group.addTask {
      do {
        try await clock.sleep(until: expiration, tolerance: tolerance)
        return .timedOut
      } catch {
        return .cancelled
      }
    }

    switch await group.next() {
    case let .completed(value):
      // The operation finished first. Cancel the timer and return.
      group.cancelAll()
      return .success(value)

    case let .failed(error) where error is CancellationError && isExpired && !Task.isCancelled:
      // A deadline already past cancelled the operation before it started, and it unwound
      // before the timer reported: the deadline is the cause, as when the timer fires first.
      group.cancelAll()
      return .failure(TaskTimeoutError(reason: .deadlineExpired))

    case let .failed(error):
      // The operation threw before the deadline. Cancel the timer and surface it unwrapped.
      group.cancelAll()
      return .failure(error)

    case .timedOut:
      // The deadline elapsed. Cancel the work task and await its terminal result
      // so we never abandon it. If the operation managed to complete or fail with its
      // own (non-cancellation) error in the meantime, that real outcome wins;
      // otherwise the operation unwound due to our cancellation and the deadline is
      // the cause.
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

/// Runs `operation`, cancelling it once `timeout` elapses on `clock`.
///
/// The same as ``withDeadline(_:tolerance:clock:isolation:operation:)`` with an expiration of
/// `clock.now.advanced(by: timeout)`.
public func withDeadline<Return: Sendable, C: Clock>(
  in timeout: C.Instant.Duration,
  tolerance: C.Instant.Duration? = nil,
  clock: C = ContinuousClock(),
  isolation: isolated (any Actor)? = #isolation,
  operation: sending @escaping @isolated(any) () async throws -> sending Return
) async throws -> Return {
  try await withDeadline(
    clock.now.advanced(by: timeout),
    tolerance: tolerance,
    clock: clock,
    isolation: isolation,
    operation: operation
  )
}

private enum _DeadlineOutcome<T: Sendable>: Sendable {
  case completed(T)
  case failed(any Error)
  case timedOut
  case cancelled
}
