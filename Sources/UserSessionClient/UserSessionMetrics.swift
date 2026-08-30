import DuckDependencies
import Foundation

public struct UserSessionMetrics {
  /// Version of the app when it was first installed
  public var installationVersion: Version?

  /// Date when the app was first installed
  public var installationDate: Date

  /// The foreground time recorded in the most recent session
  public var lastSessionForegroundTime: TimeInterval = 0

  /// The version of the app during the last session
  public var lastTrackedVersion: Version?

  /// The total foreground time the app has accumulated across all sessions
  public var totalForegroundTime: TimeInterval = 0

  /// The total number of sessions the user has had
  public var totalSessionCount: Int32 = 0

  /// The total foreground time accumulated since the last metrics update
  public var foregroundTimeSinceLastUpdate: TimeInterval = 0

  /// The number of sessions recorded since the last metrics update
  public var sessionCountSinceLastUpdate: Int32 = 0

  /// The date when the app was restored (brought back to the foreground)
  public var restoreDate: Date

  /// The date when the metrics were updated
  public var updateDate: Date

  /// Indicates if this is the first session (i.e., no previous sessions recorded).
  public var isFirstSession: Bool {
    totalSessionCount == 0 && totalForegroundTime == 0
  }

  /// Indicates if the app have never been updated since it was installed.
  public var isVersionNeverUpdated: Bool {
    totalSessionCount == sessionCountSinceLastUpdate
  }

  public init(
    date: Date = Date(),
    version: Version? = nil
  ) {
    installationVersion = version
    installationDate = date
    lastSessionForegroundTime = 0
    restoreDate = date
    lastTrackedVersion = version
    updateDate = date
    totalForegroundTime = 0
    totalSessionCount = 0
    foregroundTimeSinceLastUpdate = 0
    sessionCountSinceLastUpdate = 0
  }

  /// Records which build is running.
  ///
  /// Separate from opening a session because it is true of every launch,
  /// including one the user never saw: the counters "since last update" are
  /// scoped to a build, so they reset when the build changes and not when
  /// someone opens the app.
  ///
  /// - Returns: whether this is the first launch of a new build.
  @discardableResult
  mutating
  func trackVersion(_ version: Version?) -> Bool {
    guard lastTrackedVersion != version else { return false }

    lastTrackedVersion = version
    sessionCountSinceLastUpdate = 0
    foregroundTimeSinceLastUpdate = 0

    return true
  }

  /// Opens a session — the app has appeared in front of the user.
  ///
  /// A return that comes too soon after the last one is the same session
  /// resuming, not a new one, so only the foreground clock restarts.
  mutating
  func open(
    at date: Date,
    minSessionDuration: TimeInterval
  ) {
    if date.timeIntervalSince(updateDate) > minSessionDuration {
      totalSessionCount += 1
      sessionCountSinceLastUpdate += 1
      updateDate = date
    }

    // Always, even when no new session was counted: `suspend` measures
    // foreground time from here, and leaving it where the last process
    // stopped would charge this session for the time in between.
    restoreDate = date
  }

  mutating
  func suspend(
    at date: Date
  ) {
    let foregroundTime = date.timeIntervalSince(restoreDate)

    lastSessionForegroundTime = foregroundTime
    totalForegroundTime += foregroundTime
    foregroundTimeSinceLastUpdate += foregroundTime
    updateDate = date
  }
}

extension UserSessionMetrics: Codable {}
extension UserSessionMetrics: Equatable {}
extension UserSessionMetrics: Hashable {}
extension UserSessionMetrics: Sendable {}
