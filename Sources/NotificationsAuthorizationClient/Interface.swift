import Dependencies
import DependenciesMacros

extension DependencyValues {
  public var notificationsAuthorization: NotificationsAuthorizationClient {
    get { self[NotificationsAuthorizationClient.self] }
    set { self[NotificationsAuthorizationClient.self] = newValue }
  }
}

/// The permission half of notifications: what the system allows and asking it
/// for more. Delivery lives in `DuckNotificationsClient`; what to notify about
/// and when belongs to the app.
@DependencyClient
public struct NotificationsAuthorizationClient: Sendable {
  public var status: @Sendable (
  ) async -> NotificationsAuthorization.Status = { .notDetermined }

  /// Every status read after a change could have happened: after each
  /// ``requestAuthorization`` and on each return to the foreground — the only
  /// moment a switch flipped in system Settings becomes visible.
  public var statusUpdates: @Sendable (
  ) -> AsyncStream<NotificationsAuthorization.Status> = { .finished }

  /// Asks the system and returns the status afterwards.
  ///
  /// A prompt request surfaces the system prompt only while the status
  /// ``NotificationsAuthorization/Status/allowsPrompt``; otherwise the recorded
  /// answer stands and nothing is shown. A provisional request never shows
  /// anything.
  public var requestAuthorization: @Sendable (
    _ _: NotificationsAuthorization.Request
  ) async throws -> NotificationsAuthorization.Status = { _ in .notDetermined }
}
