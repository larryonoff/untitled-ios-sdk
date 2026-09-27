import Dependencies
import DuckAnalyticsClient
import DuckConcurrency
import DuckFoundation
import DuckLogging
import Foundation
import UserNotifications

extension NotificationsAuthorizationClient: DependencyKey {
  public static let liveValue: Self = {
    let impl = NotificationsAuthorizationClientImpl()

    return Self(
      status: {
        await currentStatus()
      },
      statusUpdates: {
        impl.statusUpdates()
      },
      requestAuthorization: {
        try await impl.requestAuthorization($0)
      }
    )
  }()
}

private final class NotificationsAuthorizationClientImpl: Sendable {
  private let updates = AsyncBroadcast<NotificationsAuthorization.Status>()

  /// Re-reads the status on every return to the foreground, until `deinit`.
  private let foregroundObservation: Task<Void, Never>

  init() {
    // `UNUserNotificationCenter` announces no status change, so the status is
    // re-read on every return to the foreground. One loop keeps re-reads
    // ordered: a task per notification lets a stale status land last.
    foregroundObservation = Task { [updates] in
      let didBecomeActive = Notification.Name.applicationDidBecomeActive
      for await _ in NotificationCenter.default.notifications(named: didBecomeActive) {
        updates.yield(await currentStatus())
      }
    }
  }

  deinit {
    foregroundObservation.cancel()
  }

  func statusUpdates() -> AsyncStream<NotificationsAuthorization.Status> {
    updates.stream(bufferingPolicy: .bufferingNewest(1))
  }

  func requestAuthorization(
    _ request: NotificationsAuthorization.Request
  ) async throws -> NotificationsAuthorization.Status {
    @Dependency(\.analytics) var analytics

    let isProvisional = request.options.contains(.provisional)
    // Only a prompt that can actually appear is reported as shown.
    let statusBefore = await currentStatus()
    let showsPrompt = !isProvisional && statusBefore.allowsPrompt

    if showsPrompt {
      analytics.logPromptView(placement: request.placement)
    }

    do {
      let isGranted = try await UNUserNotificationCenter.current()
        .requestAuthorization(options: request.options)

      if showsPrompt {
        analytics.logPromptAction(isGranted ? .authorize : .deny, placement: request.placement)
      }

      // A provisional grant shows no prompt, so no return to the foreground
      // will announce it.
      let status = await currentStatus()
      updates.yield(status)

      logger.info(
        """
        notifications.authorize success | \
        is_provisional: \(isProvisional, privacy: .public) \
        status: \(status.description, privacy: .public)
        """
      )

      return status
    } catch {
      if showsPrompt {
        analytics.logPromptAction(.fail, placement: request.placement)
      }

      logger.error(
        """
        notifications.authorize failed | \
        is_provisional: \(isProvisional, privacy: .public)
        error: \(error, privacy: .public)
        """
      )

      throw error
    }
  }
}

private func currentStatus() async -> NotificationsAuthorization.Status {
  let settings = await UNUserNotificationCenter.current().notificationSettings()
  let status = NotificationsAuthorization.Status(settings.authorizationStatus)

  logger.debug(
    """
    notifications.status | \
    status: \(status.description, privacy: .public)
    """
  )

  return status
}

private let logger = Logger(
  subsystem: ".SDK.NotificationsAuthorizationClient",
  category: "Notifications"
)
