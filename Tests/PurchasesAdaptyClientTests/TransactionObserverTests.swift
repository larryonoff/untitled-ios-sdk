import Adapty
import Dependencies
import DuckTestSupport
import DuckUserSettings
import Foundation
import Synchronization
import Testing

@testable import DuckPurchasesAdaptyClient

/// Adapty sends a profile before the transaction behind it finishes: the observer waits 2 seconds
/// of `\.continuousClock`, then stamps the date new transactions must follow with `\.date`.
@Suite(.timeLimit(.minutes(1)))
struct TransactionObserverTests {
  let clock = TestClock()
  let now = Date(timeIntervalSince1970: 1_700_000_000)
  let settings = CandidatesDateSettings()

  // Catches a wait on real time (`Task.sleep`) or a shorter one: transactions would be read
  // before Adapty finished them.
  @Test func `a profile is handled 2 seconds of the clock after it arrives`() async throws {
    try handleProfile()

    await #expect(throws: (any Error).self, "The observer must sleep on the injected clock") {
      try await clock.checkSuspension()
    }
    await clock.advance(by: .milliseconds(1_999))
    #expect(settings.candidatesDate == nil)

    await clock.advance(by: .milliseconds(1))
    try await waitUntil { settings.candidatesDate != nil }
  }

  // Catches the first candidates date taken from `Date()`: transactions bought before the
  // injected now would count as new.
  @Test func `the first candidates date is the injected now`() async throws {
    try handleProfile()

    await clock.advance(by: .seconds(2))

    try await waitUntil { settings.candidatesDate != nil }
    #expect(settings.candidatesDate == now)
  }

  /// The observer's task keeps it alive until the task ends.
  private func handleProfile() throws {
    let profile = try JSONDecoder().decode(
      AdaptyProfile.self,
      from: Data(#"{"profile_id": "profile", "segment_hash": "segment"}"#.utf8)
    )
    let observer = withDependencies {
      $0.continuousClock = clock
      $0.date.now = now
    } operation: {
      TransactionObserver(store: TransactionCache(userSettings: settings.client))
    }
    observer.handle(profile)
  }
}

/// The candidates date `TransactionCache` keeps. Storing it ends the observer's task: StoreKit,
/// read next, answers a test bundle without a host app only after up to minutes, holding
/// cooperative threads the tests need meanwhile.
final class CandidatesDateSettings: Sendable {
  private let date = Mutex<Date?>(nil)

  var candidatesDate: Date? { date.withLock { $0 } }

  var client: UserSettingsClient {
    var client = UserSettingsClient()
    client.objectForKey = { _ in self.date.withLock { $0 } }
    client.setObject = { value, _ in
      self.date.withLock { $0 = value as? Date }
      // SAFETY: the handle is the calling task's own and never leaves the closure.
      withUnsafeCurrentTask { $0?.cancel() }
    }
    return client
  }
}
