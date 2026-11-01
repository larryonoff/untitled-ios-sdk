import Dependencies
import DuckConcurrency
import Foundation
import Testing

@Suite(.timeLimit(.minutes(1)))
struct TaskTimeoutTests {
  private struct Failure: Error, Equatable {}

  @Test func `the result arrives without advancing the deadline`() async throws {
    let value = try await withTaskTimeout(for: .seconds(10), clock: TestClock()) { 42 }
    #expect(value == 42)
  }

  @Test func `the operation error is preserved`() async {
    await #expect(throws: Failure.self) {
      try await withTaskTimeout(for: .seconds(10), clock: TestClock()) { () async throws -> Int in throw Failure() }
    }
  }

  @Test func `an elapsed deadline cancels cooperative work`() async {
    let clock = TestClock()
    let task = Task {
      try await withTaskTimeout(for: .seconds(5), clock: clock) {
        try await clock.sleep(for: .seconds(60))
        return 42
      }
    }
    await clock.advance(by: .seconds(5))
    await #expect(throws: TaskTimeoutError(reason: .deadlineExpired)) { try await task.value }
  }

  @Test func `parent cancellation reaches the operation`() async {
    let clock = TestClock()
    let task = Task {
      try await withTaskTimeout(for: .seconds(5), clock: clock) {
        try await clock.sleep(for: .seconds(60))
        return 42
      }
    }
    task.cancel()
    await #expect(throws: CancellationError.self) { try await task.value }
  }

  @Test func `a single element stream finishes after its value`() async {
    var values: [String] = []
    for await value in AsyncStream("value") { values.append(value) }
    #expect(values == ["value"])
  }
}

extension TaskTimeoutTests {
  private final class TransferredValue {
    var integer = 42
  }

  @Test func `a transferred timeout body owns a nonsendable value`() async throws {
    let value = TransferredValue()
    let result = try await withTaskTimeout(for: .seconds(10), clock: TestClock()) {
      value.integer += 1
      return value.integer
    }
    #expect(result == 43)
  }

  @Test func `a single element stream accepts a transferred nonsendable value`() async {
    let value = TransferredValue()
    let stream = AsyncStream(value)
    var iterator = stream.makeAsyncIterator()
    let received = await iterator.next()
    #expect(received?.integer == 42)
  }
}
