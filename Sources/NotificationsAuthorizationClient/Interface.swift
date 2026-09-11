import Dependencies
import DependenciesMacros

extension DependencyValues {
  public var notificationsAuthorization: NotificationsAuthorizationClient {
    get { self[NotificationsAuthorizationClient.self] }
    set { self[NotificationsAuthorizationClient.self] = newValue }
  }
}

/// The permission half of notifications: what the system allows and asking it
/// for more. Scheduling and delivery belong to the app, which already owns the
/// content and the triggers.
@DependencyClient
public struct NotificationsAuthorizationClient: Sendable {
  public var status: @Sendable (
  ) async -> NotificationsAuthorization.Status = { .notDetermined }

  /// Returns whether the user granted. Only a ``NotificationsAuthorization/Status/notDetermined``
  /// status surfaces the system prompt; any other status replays the recorded
  /// answer without showing anything.
  public var requestAuthorization: @Sendable (
  ) async throws -> Bool = { false }
}
