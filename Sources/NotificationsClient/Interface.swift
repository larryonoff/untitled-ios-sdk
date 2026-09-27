import Dependencies
import DependenciesMacros
import UserNotifications

extension DependencyValues {
  public var notifications: NotificationsClient {
    get { self[NotificationsClient.self] }
    set { self[NotificationsClient.self] = newValue }
  }
}

/// The delivery half of notifications: scheduling, removing, and what the user
/// does with them. Permission lives in `DuckNotificationsAuthorizationClient`;
/// what to notify about and when belongs to the app.
@DependencyClient
public struct NotificationsClient: Sendable {
  /// Makes this client the notification center's delegate.
  ///
  /// Call before the app finishes launching — in
  /// `application(_:willFinishLaunchingWithOptions:)` — so the tap that
  /// launched the app is not missed. Calling again does nothing.
  public var activate: @Sendable () -> Void

  /// What the user does with notifications, and the system asking how to show
  /// one while the app is in front.
  ///
  /// Events that arrive while nobody iterates are held and handed to the next
  /// stream, so a cold-launch tap outlives the wait for the first subscriber.
  /// Every event carries a completion the host must call once it has handled
  /// it — the system may suspend the app as soon as it does.
  public var events: @Sendable () -> AsyncStream<Notifications.Event> = { .finished }

  /// Schedules `request`, replacing a pending or delivered one with its identifier.
  @DependencyEndpoint(method: "add")
  public var addRequest: @Sendable (_ _: UNNotificationRequest) async throws -> Void

  @DependencyEndpoint(method: "removePendingRequests")
  public var removePendingRequestsWithIdentifiers: @Sendable (_ withIdentifiers: [String]) -> Void

  @DependencyEndpoint(method: "removeDeliveredNotifications")
  public var removeDeliveredNotificationsWithIdentifiers: @Sendable (_ withIdentifiers: [String]) -> Void

  /// Registers the actions notifications can offer, replacing earlier ones.
  public var setCategories: @Sendable (_ _: Set<UNNotificationCategory>) -> Void
}
