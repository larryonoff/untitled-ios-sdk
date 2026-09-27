import Dependencies
import DuckConcurrency
import DuckFoundation
import DuckLogging
import UserNotifications

extension NotificationsClient: DependencyKey {
  public static let liveValue: Self = {
    let impl = NotificationsClientImpl()

    return Self(
      activate: {
        impl.activate()
      },
      events: {
        impl.eventStream()
      },
      addRequest: {
        try await impl.add($0)
      },
      removePendingRequestsWithIdentifiers: {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: $0)
      },
      removeDeliveredNotificationsWithIdentifiers: {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: $0)
      },
      setCategories: {
        UNUserNotificationCenter.current().setNotificationCategories($0)
      }
    )
  }()
}

private final class NotificationsClientImpl: Sendable {
  /// Holds events while nobody iterates, so a cold-launch tap outlives the
  /// wait for the first subscriber.
  private let events = AsyncBroadcast<Notifications.Event>(holdsUntilSubscribed: true)
  private let delegate: Delegate

  init() {
    delegate = Delegate(events: events)
  }

  func activate() {
    // The center holds its delegate weakly; `delegate` lives as long as this
    // instance, which is the process.
    let center = UNUserNotificationCenter.current()
    guard center.delegate !== delegate else { return }
    center.delegate = delegate

    logger.info("notifications.activate success")
  }

  func eventStream() -> AsyncStream<Notifications.Event> {
    events.stream()
  }

  func add(_ request: UNNotificationRequest) async throws {
    let identifier = request.identifier

    do {
      try await UNUserNotificationCenter.current().add(request)

      logger.info(
        """
        notifications.add success | \
        request_id: \(identifier, privacy: .public)
        """
      )
    } catch {
      logger.error(
        """
        notifications.add failed | \
        request_id: \(identifier, privacy: .public)
        error: \(error, privacy: .public)
        """
      )

      throw error
    }
  }
}

private final class Delegate: NSObject, UNUserNotificationCenterDelegate, Sendable {
  private let events: AsyncBroadcast<Notifications.Event>

  init(events: AsyncBroadcast<Notifications.Event>) {
    self.events = events
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    // The system calls it once, from any thread.
    nonisolated(unsafe) let completionHandler = completionHandler

    logger.info(
      """
      notifications.response received | \
      request_id: \(response.notification.request.identifier, privacy: .public) \
      action_id: \(response.actionIdentifier, privacy: .public)
      """
    )

    events.yield(.response(.init(response), completion: { completionHandler() }))
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // The system calls it once, from any thread.
    nonisolated(unsafe) let completionHandler = completionHandler

    events.yield(.willPresent(.init(notification), completion: { completionHandler($0) }))
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    openSettingsFor notification: UNNotification?
  ) {
    events.yield(.openSettings(notification.map(Notifications.Notification.init)))
  }
}

private let logger = Logger(
  subsystem: ".SDK.NotificationsClient",
  category: "Notifications"
)
