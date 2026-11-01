import DuckTestSupport
import Synchronization
import Testing

private let owners = Mutex(0)

@MainActor
private func verifyExclusiveOwner() async {
  owners.withLock { $0 += 1 }
  defer { owners.withLock { $0 -= 1 } }
  for _ in 0..<100 { await Task.yield() }
  #expect(owners.withLock { $0 } == 1)
}

@MainActor
@Suite(.uiHosting, .timeLimit(.minutes(1)))
struct FirstHostingTests {
  @Test func `a hosting owner excludes another suite`() async { await verifyExclusiveOwner() }
}

@MainActor
@Suite(.uiHosting, .timeLimit(.minutes(1)))
struct SecondHostingTests {
  @Test func `another hosting suite waits for exclusive access`() async { await verifyExclusiveOwner() }
}

struct WaitingTests {
  @Test func `an already satisfied condition finishes immediately`() async throws {
    try await waitUntil(within: .zero) { true }
  }

  @Test func `cancellation stops waiting`() async {
    let task = Task { try await waitUntil { false } }
    task.cancel()
    await #expect(throws: CancellationError.self) { try await task.value }
  }
}

extension WaitingTests {
  @Test func `a zero polling interval reports an issue without evaluating the condition`() async {
    let attempts = Mutex(0)
    await withKnownIssue("Invalid polling input is reported at the caller") {
      try await waitUntil(pollingEvery: .zero) {
        attempts.withLock { $0 += 1 }
        return false
      }
    }
    #expect(attempts.withLock { $0 } == 0)
  }
}
