import SwiftUI
import MessageUI

struct _MailComposeView: UIViewControllerRepresentable {
  @Environment(\.dismiss) private var dismiss

  let emailData: MailComposeData
  let completion: (Result<MailComposeResult, any Error>) -> Void

  func makeUIViewController(
    context: Context
  ) -> MFMailComposeViewController {
    let viewController = MFMailComposeViewController()
    viewController.mailComposeDelegate = context.coordinator
    viewController.setSubject(emailData.subject)
    viewController.setToRecipients(emailData.recipients)
    viewController.setCcRecipients(emailData.ccRecipients)
    viewController.setBccRecipients(emailData.bccRecipients)
    viewController.setMessageBody(emailData.body, isHTML: emailData.isBodyHTML)

    for attachment in emailData.attachments {
      viewController.addAttachmentData(
        attachment.data,
        mimeType: attachment.mimeType,
        fileName: attachment.fileName
      )
    }

    if let preferredSendingEmailAddress = emailData.preferredSendingEmailAddress {
      viewController.setPreferredSendingEmailAddress(preferredSendingEmailAddress)
    }

    return viewController
  }

  func updateUIViewController(
    _ uiViewController: MFMailComposeViewController,
    context: Context
  ) {
    uiViewController.setSubject(emailData.subject)
    uiViewController.setToRecipients(emailData.recipients)
    uiViewController.setCcRecipients(emailData.ccRecipients)
    uiViewController.setBccRecipients(emailData.bccRecipients)
    uiViewController.setMessageBody(emailData.body, isHTML: emailData.isBodyHTML)

    if let preferredSendingEmailAddress = emailData.preferredSendingEmailAddress {
      uiViewController.setPreferredSendingEmailAddress(
        preferredSendingEmailAddress
      )
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  /// Determine if the device can send emails or not.
  /// - Returns: true if the device can send emails, false otherwise.
  static func canSendMail() -> Bool {
    MFMailComposeViewController.canSendMail()
  }

  final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
    var parent: _MailComposeView

    init(_ parent: _MailComposeView) {
      self.parent = parent
    }

    func mailComposeController(
      _ controller: MFMailComposeViewController,
      didFinishWith result: MFMailComposeResult,
      error: (any Error)?
    ) {
      if let error = error {
        return parent.completion(.failure(error))
      }

      parent.completion(.success((.init(rawValue: result.rawValue)!)))
      parent.dismiss()
    }
  }
}
