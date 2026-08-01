import Dependencies
import IssueReporting

extension AppMetricaClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

#if !canImport(AppMetricaCore)
extension AppMetricaClient: DependencyKey {
  /// AppMetrica ships no macOS slice, so it is gated behind the `AppMetrica`
  /// package trait. Without that trait there is no live implementation — report
  /// it instead of silently resolving to `testValue`, which would drop every
  /// event with no indication that analytics is off.
  public static let liveValue: Self = {
    reportIssue(
      """
      AppMetricaClient has no live implementation: the "AppMetrica" package \
      trait is disabled. Enable it on the untitled-ios-sdk dependency to report \
      analytics; it is off by default so the package resolves on macOS.
      """
    )
    return Self.noop
  }()
}
#endif

extension AppMetricaClient {
  public static let noop = Self(
    deviceID: { nil },
    profileID: { nil },
    reportError: { _ in },
    reportExternalAttribution: { _, _ in },
    reset: {}
  )
}
