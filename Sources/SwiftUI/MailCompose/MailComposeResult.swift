import Foundation

/// A custom type representing the email composing results.
///
/// Available values:
/// - `cancelled = 0`
/// - `saved = 1`
/// - `sent = 2`
/// - `failed = 3`
/// - `cannotSendMails = 4`
///
/// This is a convenient type in place of [MFMailComposeResult](https://developer.apple.com/documentation/messageui/mfmailcomposeresult),
/// with the addition of one more case to indicate whether a device is
/// unable to send emails.
public enum MailComposeResult: Int {
  /// Email sending was cancelled.
  ///
  /// ```swift
  /// // Raw value:
  /// cancelled = 0
  /// ```
  case cancelled

  /// Email was saved.
  ///
  /// ```swift
  /// // Raw value:
  /// saved = 1
  /// ```
  case saved

  /// Email was sent.
  ///
  /// ```swift
  /// // Raw value:
  /// sent = 2
  /// ```
  case sent

  /// Email failed to be sent.
  ///
  /// ```swift
  /// // Raw value:
  /// failed = 3
  /// ```
  case failed

  /// Current device is unable to send emails.
  ///
  /// ```swift
  /// // Raw value:
  /// cannotSendMails = 4
  /// ```
  case cannotSendMails
}

extension MailComposeResult: CustomStringConvertible {
  /// A textual description of each case in EmailComposerResult.
  public var description: String {
    switch self {
    case .cancelled: return NSLocalizedString("Cancelled", comment: "")
    case .saved: return NSLocalizedString("Saved", comment: "")
    case .sent: return NSLocalizedString("Sent", comment: "")
    case .failed: return NSLocalizedString("Failed", comment: "")
    case .cannotSendMails: return NSLocalizedString("Unable to send emails from this device.", comment: "")
    }
  }
}

extension MailComposeResult: Equatable {}

extension MailComposeResult: Hashable {}

extension MailComposeResult: Sendable {}
