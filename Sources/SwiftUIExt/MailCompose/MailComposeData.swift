import Foundation

/// A custom type to provide predefined values that will
/// prefill the email fields.
public struct MailComposeData {
  /// Email subject.
  ///
  /// Default valus is an empty string.
  public var subject: String = ""

  /// The potential recipients of the email.
  public var recipients: [String]?


  /// The potential cc recipients of the email.
  public var ccRecipients: [String]?

  /// The potential cc recipients of the email.
  public var bccRecipients: [String]?

  /// The email body.
  ///
  /// Default value is an empty string.
  public var body: String = ""

  /// A boolean value indicating whether the email body provided with the ``MailComposeData/body``
  /// property is HTML or plain text.
  ///
  /// Default value is `false`.
  public var isBodyHTML = false

  /// An array of ``EmailData/AttachmentData`` objects for adding attachments to the email.
  public var attachments = [AttachmentData]()

  /// The preferred email address used to send this message.
  public var preferredSendingEmailAddress: String?

  /// A custom type to keep attachment data for the emails that users will send.
  ///
  /// Provide instances of this type to the ``EmailData/attachments`` array
  /// of your ``EmailData`` instance.
  public struct AttachmentData {
    /// The attachment data.
    public var data: Data

    /// The attachment mime type.
    public var mimeType: String

    /// The attachement file name.
    public var fileName: String

    /// Initialize an ``EmailData/AttachmentData`` instance for an ``EmailData`` object
    /// by providing the actual data, the mime type, and a file name.
    public init(
      data: Data,
      mimeType: String,
      fileName: String
    ) {
      self.data = data
      self.mimeType = mimeType
      self.fileName = fileName
    }
  }

  /// Initialize an EmailData instance.
  ///
  /// It's not necessary to provide values to all possible arguments. Do so only for those actually needed.
  ///
  ///   ```swift
  ///     let emailData = MailComposeData(subject: "Hi there!", recipients: ["some@recipient.xyz"])
  ///   ```
  ///
  /// - Parameters:
  ///   - subject: Email subject. An empty string by default.
  ///   - recipients: The potential recipients of the email. It's `nil` by default.
  ///   - ccRecipients: The potential cc recipients of the email.
  ///   - bccRecipients: The potential cc recipients of the email.
  ///   - body: The email body. An empty string by default.
  ///   - isBodyHTML: A boolean value indicating whether the body provided with the `body`
  ///   property is HTML or plain text. It's `false` by default.
  ///   - attachments: An array of ``MailComposeData/AttachmentData`` objects for adding attachments to the email.
  ///   The array is empty by default.
  ///   - preferredSendingEmailAddress: The preferred email address used to send this message.
  public init(
    subject: String = "",
    recipients: [String]? = nil,
    ccRecipients: [String]? = nil,
    bccRecipients: [String]? = nil,
    body: String = "",
    isBodyHTML: Bool = false,
    attachments: [AttachmentData] = [],
    preferredSendingEmailAddress: String? = nil
  ) {
    self.subject = subject
    self.recipients = recipients
    self.ccRecipients = ccRecipients
    self.bccRecipients = bccRecipients
    self.body = body
    self.isBodyHTML = isBodyHTML
    self.attachments = attachments
    self.preferredSendingEmailAddress = preferredSendingEmailAddress
  }
}

extension MailComposeData: Equatable {}

extension MailComposeData: Hashable {}

extension MailComposeData: Sendable {}

extension MailComposeData.AttachmentData: Equatable {}

extension MailComposeData.AttachmentData: Hashable {}

extension MailComposeData.AttachmentData: Sendable {}
