import Foundation
import UserNotifications

public enum Notifications {
  public enum Event: Sendable {
    /// The user opened, dismissed, or acted on a notification.
    case response(Response, completion: @Sendable () -> Void)

    /// A notification arrived while the app is in front; answer how to show it.
    case willPresent(
      Notification,
      completion: @Sendable (UNNotificationPresentationOptions) -> Void
    )

    /// The user asked for the app's notification settings, from a notification
    /// or — with `notification == nil` — from system Settings. Requires
    /// `.providesAppNotificationSettings` in the authorization request.
    case openSettings(Notification?)
  }

  public struct Notification: Sendable {
    public var date: Date

    // `UNNotificationRequest` is immutable once created; its `userInfo` holds
    // property-list values only. Nothing can mutate it across threads.
    public nonisolated(unsafe) var request: UNNotificationRequest

    public init(date: Date, request: UNNotificationRequest) {
      self.date = date
      self.request = request
    }

    init(_ notification: UNNotification) {
      self.init(date: notification.date, request: notification.request)
    }
  }

  public struct Response: Sendable {
    public var notification: Notification

    /// The identifier of the chosen action, or one of the `UNNotification…ActionIdentifier`s.
    public var actionIdentifier: String

    /// What the user typed, for a text-input action.
    public var userText: String?

    public init(
      notification: Notification,
      actionIdentifier: String,
      userText: String? = nil
    ) {
      self.notification = notification
      self.actionIdentifier = actionIdentifier
      self.userText = userText
    }

    init(_ response: UNNotificationResponse) {
      self.init(
        notification: Notification(response.notification),
        actionIdentifier: response.actionIdentifier,
        userText: (response as? UNTextInputNotificationResponse)?.userText
      )
    }

    /// The user tapped the notification itself.
    public var isDefaultAction: Bool {
      actionIdentifier == UNNotificationDefaultActionIdentifier
    }

    /// The user dismissed it — reported only for categories with `.customDismissAction`.
    public var isDismissAction: Bool {
      actionIdentifier == UNNotificationDismissActionIdentifier
    }
  }
}
