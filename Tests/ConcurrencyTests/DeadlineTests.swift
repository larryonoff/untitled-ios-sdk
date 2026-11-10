import Dependencies
import Foundation
import DuckConcurrency
import Testing

// Cases follow swiftlang/swift#91190's test/Concurrency/Runtime/task_deadlines.swift where the
// back-port can honour them: no nested deadlines, and expiry throws `TaskTimeoutError`.

@Suite(.timeLimit(.minutes(1)))
struct DeadlineTests {
  @Test func `the operation value is returned before the deadline`() async throws {
    let value = try await withDeadline(in: .seconds(1), clock: TestClock()) { 42 }
    #expect(value == 42)
  }

  @Test func `the operation error is rethrown unwrapped`() async {
    await #expect(throws: OperationError.self) {
      try await withDeadline(in: .seconds(1), clock: TestClock()) { () async throws -> Int in
        throw OperationError()
      }
    }
  }

  @Test func `an expired deadline throws and cancels the operation`() async {
    await #expect(throws: TaskTimeoutError(reason: .deadlineExpired)) {
      try await withDeadline(in: .seconds(1), clock: ImmediateClock()) {
        try await untilCancelled()
        return 42
      }
    }
  }

  @Test func `an operation completing after expiry returns its result`() async throws {
    let value = try await withDeadline(in: .seconds(1), clock: ImmediateClock()) {
      try? await untilCancelled()
      return 42
    }
    #expect(value == 42)
  }

  @Test func `a deadline that has already passed cancels the operation before it starts`() async throws {
    let clock = ImmediateClock()
    let wasCancelledAtStart = try await withDeadline(clock.now, clock: clock) {
      Task.isCancelled
    }
    #expect(wasCancelledAtStart)
  }

  @Test func `a deadline that has already passed still runs an operation that ignores cancellation`() async throws {
    let clock = ImmediateClock()
    let value = try await withDeadline(clock.now, clock: clock) { 42 }
    #expect(value == 42)
  }

  @Test func `a deadline that has already passed fails checkCancellation with the deadline error`() async {
    let clock = ImmediateClock()
    await #expect(throws: TaskTimeoutError(reason: .deadlineExpired)) {
      try await withDeadline(clock.now, clock: clock) { () async throws -> Int in
        try Task.checkCancellation()
        return 99
      }
    }
  }

  @Test func `checkCancellation after expiry fails with the deadline error`() async {
    await #expect(throws: TaskTimeoutError(reason: .deadlineExpired)) {
      try await withDeadline(in: .seconds(1), clock: ImmediateClock()) { () async throws -> Int in
        try? await untilCancelled()
        try Task.checkCancellation()
        return 0
      }
    }
  }

  @Test func `the surrounding task stays uncancelled after the deadline`() async throws {
    let wasCancelledInside = try await withDeadline(in: .seconds(1), clock: ImmediateClock()) {
      try? await untilCancelled()
      return Task.isCancelled
    }
    #expect(wasCancelledInside)
    #expect(!Task.isCancelled)
  }

  @Test func `the operation runs on the isolation it declares`() async throws {
    let isMainThread = try await withDeadline(in: .seconds(1), clock: TestClock()) { @MainActor in
      currentThreadIsMain()
    }
    #expect(isMainThread)
  }

  @Test func `outer cancellation reaches the operation`() async {
    let (started, start) = AsyncStream.makeStream(of: Void.self)
    let task = Task {
      try await withDeadline(in: .seconds(1), clock: TestClock()) {
        start.yield()
        try await untilCancelled()
        return 42
      }
    }

    for await _ in started { break }
    task.cancel()

    await #expect(throws: CancellationError.self) { try await task.value }
  }

  @Test func `a transferred operation owns a nonsendable value`() async throws {
    let value = TransferredValue()
    let result = try await withDeadline(in: .seconds(1), clock: TestClock()) {
      value.integer += 1
      return value.integer
    }
    #expect(result == 43)
  }
}

private final class TransferredValue {
  var integer = 42
}

private struct OperationError: Error {}

private func currentThreadIsMain() -> Bool {
  Thread.isMainThread
}

/// Suspends until the task is cancelled: a `TestClock` nobody advances never wakes on its own.
private func untilCancelled() async throws {
  try await TestClock().sleep(for: .seconds(1))
}
