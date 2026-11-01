import AppTrackingTransparency
import Dependencies
import DuckAnalyticsClient
import DuckDependencies
import DuckPurchasesClient
import DuckUserTracking
import Sharing
import Synchronization
import Testing

@testable import DuckUserTrackingLive

@MainActor
@Suite(.timeLimit(.minutes(1)))
struct AuthorizationTests {
  @Test func `an active application requests authorization from a background caller`() async throws {
    let requests = Mutex(0)
    let impl = UserTrackingImpl(analytics: .noop, purchases: PurchasesClient(), authorization: .init(
      phase: SharedReader(value: .active),
      status: { .notDetermined },
      request: { requests.withLock { $0 += 1 }; return .authorized }
    ))
    let task = Task.detached { try await impl.requestAuthorization(timeoutWaitingForApplicationActive: .seconds(5)) }
    let result = try await task.value
    #expect(result == .authorized)
    #expect(impl.authStatus == .authorized)
    #expect(requests.withLock { $0 } == 1)
  }

  @Test(arguments: [ATTrackingManager.AuthorizationStatus.authorized, .denied, .restricted])
  func `a determined status does not request or wait for an active application`(status: ATTrackingManager.AuthorizationStatus) async throws {
    let requests = Mutex(0)
    let impl = UserTrackingImpl(analytics: .noop, purchases: PurchasesClient(), authorization: .init(
      phase: SharedReader(value: .inactive),
      status: { status },
      request: { requests.withLock { $0 += 1 }; return .notDetermined }
    ))
    let result = try await impl.requestAuthorization(timeoutWaitingForApplicationActive: .zero)
    #expect(result == AuthorizationStatus(rawValue: status.rawValue))
    #expect(requests.withLock { $0 } == 0)
  }

  @Test func `an inactive application requests only after becoming active`() async throws {
    let phase = Shared<ApplicationPhase>(value: .inactive)
    let requests = Mutex(0)
    let clock = TestClock()
    let scheduled = AsyncStream<TestClock<Duration>.Instant>.makeStream(bufferingPolicy: .bufferingNewest(1))
    defer { scheduled.continuation.finish() }
    let impl = UserTrackingImpl(analytics: .noop, purchases: PurchasesClient(), authorization: .init(
      phase: SharedReader(phase),
      status: { .notDetermined },
      request: { requests.withLock { $0 += 1 }; return .denied }
    ))
    let task = Task {
      try await withDependencies { $0.continuousClock = AuthorizationClock(base: clock, scheduled: scheduled.continuation) } operation: {
        try await impl.requestAuthorization(timeoutWaitingForApplicationActive: .seconds(5))
      }
    }
    var deadlines = scheduled.stream.makeAsyncIterator()
    _ = try #require(await deadlines.next())
    #expect(requests.withLock { $0 } == 0)
    phase.withLock { $0 = .active }
    let result = try await task.value
    #expect(result == .denied)
    #expect(requests.withLock { $0 } == 1)
  }

  @Test func `an application that stays inactive times out without requesting`() async throws {
    let requests = Mutex(0)
    let clock = TestClock()
    let scheduled = AsyncStream<TestClock<Duration>.Instant>.makeStream(bufferingPolicy: .bufferingNewest(1))
    defer { scheduled.continuation.finish() }
    let impl = UserTrackingImpl(analytics: .noop, purchases: PurchasesClient(), authorization: .init(
      phase: SharedReader(value: .inactive),
      status: { .notDetermined },
      request: { requests.withLock { $0 += 1 }; return .authorized }
    ))
    let task = Task {
      try await withDependencies { $0.continuousClock = AuthorizationClock(base: clock, scheduled: scheduled.continuation) } operation: {
        try await impl.requestAuthorization(timeoutWaitingForApplicationActive: .seconds(5))
      }
    }
    var deadlines = scheduled.stream.makeAsyncIterator()
    let deadline = try #require(await deadlines.next())
    await clock.advance(to: deadline.advanced(by: .nanoseconds(1)))
    await #expect(throws: ApplicationPhase.TimeoutError(expected: .active, current: .inactive)) { try await task.value }
    #expect(impl.authStatus == .notDetermined)
    #expect(requests.withLock { $0 } == 0)
  }

  @Test(arguments: [ApplicationPhase.active, .inactive])
  func `a cancelled caller never opens a new authorization prompt`(phase: ApplicationPhase) async {
    let requests = Mutex(0)
    let impl = UserTrackingImpl(analytics: .noop, purchases: PurchasesClient(), authorization: .init(
      phase: SharedReader(value: phase),
      status: { .notDetermined },
      request: { requests.withLock { $0 += 1 }; return .authorized }
    ))
    let task = Task { try await impl.requestAuthorization(timeoutWaitingForApplicationActive: .seconds(5)) }
    task.cancel()
    await #expect(throws: CancellationError.self) { try await task.value }
    #expect(requests.withLock { $0 } == 0)
  }
}

extension AuthorizationTests {
  @Test func `a status determined while waiting does not open another prompt`() async throws {
    let phase = Shared<ApplicationPhase>(value: .inactive)
    let status = Mutex(ATTrackingManager.AuthorizationStatus.notDetermined)
    let requests = Mutex(0)
    let clock = TestClock()
    let scheduled = AsyncStream<TestClock<Duration>.Instant>.makeStream(bufferingPolicy: .bufferingNewest(1))
    defer { scheduled.continuation.finish() }
    let impl = UserTrackingImpl(analytics: .noop, purchases: PurchasesClient(), authorization: .init(
      phase: SharedReader(phase),
      status: { status.withLock { $0 } },
      request: { requests.withLock { $0 += 1 }; return .authorized }
    ))
    let task = Task {
      try await withDependencies { $0.continuousClock = AuthorizationClock(base: clock, scheduled: scheduled.continuation) } operation: {
        try await impl.requestAuthorization(timeoutWaitingForApplicationActive: .seconds(5))
      }
    }
    var deadlines = scheduled.stream.makeAsyncIterator()
    _ = try #require(await deadlines.next())
    status.withLock { $0 = .denied }
    phase.withLock { $0 = .active }
    let result = try await task.value
    #expect(result == .denied)
    #expect(impl.authStatus == .denied)
    #expect(requests.withLock { $0 } == 0)
  }

  @Test(arguments: [false, true])
  func `cancellation during the phase wait does not open a prompt`(becomesActive: Bool) async throws {
    let phase = Shared<ApplicationPhase>(value: .inactive)
    let requests = Mutex(0)
    let clock = TestClock()
    let scheduled = AsyncStream<TestClock<Duration>.Instant>.makeStream(bufferingPolicy: .bufferingNewest(1))
    defer { scheduled.continuation.finish() }
    let impl = UserTrackingImpl(analytics: .noop, purchases: PurchasesClient(), authorization: .init(
      phase: SharedReader(phase),
      status: { .notDetermined },
      request: { requests.withLock { $0 += 1 }; return .authorized }
    ))
    let task = Task {
      try await withDependencies { $0.continuousClock = AuthorizationClock(base: clock, scheduled: scheduled.continuation) } operation: {
        try await impl.requestAuthorization(timeoutWaitingForApplicationActive: .seconds(5))
      }
    }
    var deadlines = scheduled.stream.makeAsyncIterator()
    _ = try #require(await deadlines.next())
    if becomesActive { phase.withLock { $0 = .active } }
    task.cancel()
    await #expect(throws: CancellationError.self) { try await task.value }
    #expect(requests.withLock { $0 } == 0)
  }
}

/// Signals only after the deadline is computed so a test cannot advance time before the wait starts.
private struct AuthorizationClock: Clock {
  typealias Instant = TestClock<Duration>.Instant

  let base: TestClock<Duration>
  let scheduled: AsyncStream<Instant>.Continuation

  var now: Instant { base.now }
  var minimumResolution: Duration { base.minimumResolution }

  func sleep(until deadline: Instant, tolerance: Duration?) async throws {
    scheduled.yield(deadline)
    try await base.sleep(until: deadline, tolerance: tolerance)
  }
}
