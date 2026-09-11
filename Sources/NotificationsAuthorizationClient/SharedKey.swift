import Dependencies
import DuckFoundation
import Foundation
import Sharing

extension SharedReaderKey where Self == NotificationsAuthorizationKey.Default {
  /// A shared, read-only view of the notifications authorization status.
  ///
  /// ```swift
  /// @SharedReader(.notificationsAuthorization) var status
  /// ```
  public static var notificationsAuthorization: Self {
    Self[NotificationsAuthorizationKey(), default: .notDetermined]
  }
}

public struct NotificationsAuthorizationKey: SharedReaderKey, Sendable {
  private let notificationsAuthorization: NotificationsAuthorizationClient

  /// Resolved at initialization rather than through a stored `@Dependency`,
  /// which resolves on _access_ — long after `withDependencies` has exited, so
  /// an overridden client would never reach `load`/`subscribe`.
  public init() {
    @Dependency(\.notificationsAuthorization) var notificationsAuthorization
    self.notificationsAuthorization = notificationsAuthorization
  }

  public typealias Value = NotificationsAuthorization.Status

  public var id: NotificationsAuthorizationKeyID {
    NotificationsAuthorizationKeyID()
  }

  public func load(context: LoadContext<Value>, continuation: LoadContinuation<Value>) {
    // The system always has a status, so there is no "no value" case to resume
    // with the initial value.
    Task {
      continuation.resume(returning: await notificationsAuthorization.status())
    }
  }

  public func subscribe(
    context: LoadContext<Value>,
    subscriber: SharedSubscriber<Value>
  ) -> SharedSubscription {
    // `UNUserNotificationCenter` announces nothing when the status changes — a
    // switch flipped in system Settings posts no notification — so returning to
    // the foreground is the only moment a decision made outside the app becomes
    // visible. One sequential loop also keeps re-reads ordered: a task per
    // notification lets a stale status land last.
    let task = Task {
      let didBecomeActive = Notification.Name.applicationDidBecomeActive
      for await _ in NotificationCenter.default.notifications(named: didBecomeActive) {
        subscriber.yield(await notificationsAuthorization.status())
      }
    }

    return SharedSubscription {
      task.cancel()
    }
  }
}

public struct NotificationsAuthorizationKeyID: Hashable {}
