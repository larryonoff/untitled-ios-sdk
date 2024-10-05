import Dependencies
import DependenciesMacros
import DuckAnalyticsClient

extension DependencyValues {
  public var firebase: FirebaseClient {
    get { self[FirebaseClient.self] }
    set { self[FirebaseClient.self] = newValue }
  }
}

@DependencyClient
public struct FirebaseClient: Sendable {
  /// Returns the unique ID for this instance of the application
  /// or nil if analyticsStorage is denied.
  public var appInstanceID: @Sendable () -> String?

  /// Adds FirebaseAnalytics logging
  ///
  /// - Parameters:
  ///   - name: Event to log
  ///   - parameters: Event parameters to log
  public var logEvent: @Sendable (
    _ _: AnalyticsClient.EventName,
    _ parameters: [AnalyticsClient.EventParameterName: Any]?
  ) async -> Void

  /// Adds logging that is sent with your crash data. The logging does not appear in app
  /// logs and is only visible in the Crashlytics dashboard.
  ///
  /// - Parameters:
  ///   - message: Message to log
  public var logMessage: @Sendable (
    _ _: String
  ) async -> Void

  @DependencyEndpoint(method: "record")
  public var recordError: @Sendable (
    _ _: any Error,
    _ userInfo: [String: Any]?
  ) async -> Void

  public var reset: @Sendable () -> Void
}
