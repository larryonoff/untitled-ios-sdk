import Foundation
import Synchronization
import Testing
import UserNotifications
@testable import DuckNotificationsClient

@Suite(.timeLimit(.minutes(1)))
struct NotificationsCompletionTests {
  @Test func `a detached consumer acknowledges on the main thread`() async {
    let finished = AsyncStream.makeStream(of: Void.self)
    let completion = Notifications.Completion<Void> { _ in
      #expect(Thread.isMainThread)
      finished.continuation.yield()
    }
    await Task.detached {
      completion(())
    }.value
    for await _ in finished.stream { break }
    finished.continuation.finish()
  }

  @Test func `presentation options reach the main actor unchanged`() async {
    let finished = AsyncStream.makeStream(of: Void.self)
    let expected: UNNotificationPresentationOptions = [.badge, .sound, .banner]
    let completion = Notifications.Completion<UNNotificationPresentationOptions> { options in
      #expect(Thread.isMainThread)
      #expect(options == expected)
      finished.continuation.yield()
    }
    await Task.detached { completion(expected) }.value
    for await _ in finished.stream { break }
    finished.continuation.finish()
  }

  @Test func `repeated and simultaneous acknowledgements invoke the OS callback once`() async {
    let finished = AsyncStream.makeStream(of: Void.self)
    let calls = Mutex(0)
    let completion = Notifications.Completion<Void> { _ in
      #expect(Thread.isMainThread)
      let count = calls.withLock { value in
        value += 1
        return value
      }
      #expect(count == 1)
      finished.continuation.yield()
    }
    await withTaskGroup(of: Void.self) { group in
      for _ in 0..<32 {
        group.addTask {
          completion(())
          completion(())
        }
      }
    }
    for await _ in finished.stream { break }
    #expect(calls.withLock { $0 } == 1)
    finished.continuation.finish()
  }

  @Test func `a cancelled consumer still completes the OS acknowledgement`() async {
    let started = AsyncStream.makeStream(of: Void.self)
    let release = AsyncStream.makeStream(of: Void.self)
    let finished = AsyncStream.makeStream(of: Void.self)
    let completion = Notifications.Completion<Void> { _ in
      #expect(Thread.isMainThread)
      finished.continuation.yield()
    }
    let consumer = Task.detached {
      started.continuation.yield()
      for await _ in release.stream { break }
      #expect(Task.isCancelled)
      completion(())
    }
    for await _ in started.stream { break }
    consumer.cancel()
    await consumer.value
    for await _ in finished.stream { break }
    started.continuation.finish()
    release.continuation.finish()
    finished.continuation.finish()
  }
}
