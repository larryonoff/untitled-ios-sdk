import DuckCore
import IssueReporting
import UserNotifications

public enum NotificationsAuthorization {
  /// What the system currently allows, collapsed to what an ask can act on.
  public enum Status: Sendable, Hashable {
    /// The one-shot system prompt has not been spent yet.
    case notDetermined
    /// The user said no; only system Settings can change that.
    case denied
    /// Notifications deliver quietly to Notification Center, and the system
    /// prompt is still unspent: asking upgrades to ``authorized`` — or, if the
    /// user declines, ends in ``denied``, quiet delivery included.
    case provisional
    /// Notifications deliver.
    case authorized
  }

  /// What to ask the system for, and where from.
  ///
  /// `placement` only tags the analytics around the system prompt.
  ///
  /// The presets leave out `.providesAppNotificationSettings`: it adds an
  /// in-app settings link to every notification, which only works if the host
  /// handles `userNotificationCenter(_:openSettingsFor:)`. A host that does
  /// builds its request with the option added.
  public struct Request: Sendable, Equatable {
    public static let defaultOptions: UNAuthorizationOptions = [.alert, .sound, .badge]

    public var options: UNAuthorizationOptions
    public var placement: Placement?

    public init(
      options: UNAuthorizationOptions = defaultOptions,
      placement: Placement? = nil
    ) {
      self.options = options
      self.placement = placement
    }

    /// Shows the system prompt while the status ``Status/allowsPrompt``.
    public static func prompt(placement: Placement? = nil) -> Self {
      Self(placement: placement)
    }

    /// Grants quiet delivery without any prompt, keeping the prompt for later.
    /// Acts only while ``Status/notDetermined``; it never downgrades a decision.
    public static func provisional(placement: Placement? = nil) -> Self {
      Self(options: defaultOptions.union(.provisional), placement: placement)
    }
  }
}

extension NotificationsAuthorization.Status: CustomStringConvertible {
  public var description: String {
    switch self {
    case .notDetermined:
      "Status.notDetermined"
    case .denied:
      "Status.denied"
    case .provisional:
      "Status.provisional"
    case .authorized:
      "Status.authorized"
    }
  }
}

extension NotificationsAuthorization.Status {
  public init(_ status: UNAuthorizationStatus) {
    switch status {
    case .notDetermined:
      self = .notDetermined
    case .denied:
      self = .denied
    case .provisional:
      self = .provisional
    // App Clip notifications deliver and have no prompt to upgrade to.
    case .authorized, .ephemeral:
      self = .authorized
    @unknown default:
      reportIssue("UNAuthorizationStatus.(@unknown default, rawValue: \(status.rawValue))")
      self = .notDetermined
    }
  }

  /// Whether notifications reach the user — prominently or quietly.
  public var allowsDelivery: Bool {
    self == .provisional || self == .authorized
  }

  /// Whether asking can still show the system prompt.
  public var allowsPrompt: Bool {
    self == .notDetermined || self == .provisional
  }
}
