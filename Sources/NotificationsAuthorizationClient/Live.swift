import Dependencies
import DuckLogging
import UserNotifications

extension NotificationsAuthorizationClient: DependencyKey {
  public static let liveValue: Self = .init(
    status: {
      let settings = await UNUserNotificationCenter.current().notificationSettings()
      let status = NotificationsAuthorization.Status(settings.authorizationStatus)

      logger.info(
        """
        notifications.status | \
        status: \(status.description, privacy: .public)
        """
      )

      return status
    },
    requestAuthorization: {
      do {
        let isAuthorized = try await UNUserNotificationCenter.current()
          .requestAuthorization(options: [.alert, .sound, .badge])

        logger.info(
          """
          notifications.authorize success | \
          is_authorized: \(isAuthorized, privacy: .public)
          """
        )

        return isAuthorized
      } catch {
        logger.error(
          """
          notifications.authorize failed | \
          error: \(error, privacy: .public)
          """
        )

        throw error
      }
    }
  )
}

private let logger = Logger(
  subsystem: ".SDK.NotificationsAuthorizationClient",
  category: "Notifications"
)
