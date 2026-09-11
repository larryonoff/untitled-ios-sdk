import IssueReporting
import UserNotifications

public enum NotificationsAuthorization {
  /// What the system currently allows, collapsed to what an ask can act on.
  public enum Status: UInt {
    /// The one-shot system prompt has not been spent yet.
    case notDetermined = 0
    /// The user said no; only system Settings can change that.
    case denied
    /// Notifications deliver.
    case authorized
  }
}

extension NotificationsAuthorization.Status: CustomStringConvertible {
  public var description: String {
    switch self {
    case .authorized:
      "Status.authorized"
    case .denied:
      "Status.denied"
    case .notDetermined:
      "Status.notDetermined"
    }
  }
}

extension NotificationsAuthorization.Status: Equatable {}
extension NotificationsAuthorization.Status: Hashable {}
extension NotificationsAuthorization.Status: Sendable {}

extension NotificationsAuthorization.Status {
  public init(_ status: UNAuthorizationStatus) {
    switch status {
    case .notDetermined:
      self = .notDetermined
    case .denied:
      self = .denied
    // `provisional` and `ephemeral` deliver too, so a strict `== .authorized`
    // would re-ask a user who is already receiving quiet notifications.
    case .authorized, .provisional, .ephemeral:
      self = .authorized
    @unknown default:
      reportIssue("UNAuthorizationStatus.(@unknown default, rawValue: \(status.rawValue))")
      self = .notDetermined
    }
  }

  public var isAuthorized: Bool {
    self == .authorized
  }
}
