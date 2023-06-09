import SwiftUI

extension View {
  /// Present the mail composer to prepare and send emails.
  ///
  /// - Parameters:
  ///   - isPresented: The binding value of a Bool state property that indicates whether the mail composer should be presented or not.
  ///   - emailData: An `MailComposeData` instance with any predefined values to prefill the mail with. `nil` by default.
  ///   - onDismiss: An optional closure to perform any actions upon the dismissal of the mail composer. It's `nil` by default.
  ///   - result: The mail composing results. On success, it contains an `MailComposeResult` value, otherwise an `Error` object. `nil` by default.
  ///   - cannotSendEmails: Accepts a custom SwiftUI view (or an empty view) that will be displayed if the device cannot send mails. A text with a dismiss button will be presented by default if you omit providing a custom view.
  public func mailCompose<CannotSendContent: View>(
    isPresented: Binding<Bool>,
    emailData: MailComposeData? = nil,
    onDismiss: (() -> Void)? = nil,
    onSubmit: ((Result<MailComposeResult, Error>) -> Void)? = nil,
    @ViewBuilder cannotSendEmails: () -> CannotSendContent
  ) -> some View {
    self.modifier(
      _MailComposeViewModifier<CannotSendContent>(
        isPresented: isPresented,
        emailData: emailData,
        onDismiss: onDismiss,
        onSubmit: onSubmit,
        cannotSendEmails: cannotSendEmails
      )
    )
  }

  /// Present the mail composer to prepare and send emails.
  ///
  /// - Parameters:
  ///   - isPresented: The binding value of a Bool state property that indicates whether the mail composer should be presented or not.
  ///   - emailData: An `MailComposeData` instance with any predefined values to prefill the mail with. `nil` by default.
  ///   - onDismiss: An optional closure to perform any actions upon the dismissal of the mail composer. It's `nil` by default.
  ///   - result: The email composing results. On success, it contains an `MailComposeResult` value, otherwise an `Error` object. `nil` by default.
  public func mailCompose(
    isPresented: Binding<Bool>,
    emailData: MailComposeData? = nil,
    onDismiss: (() -> Void)? = nil,
    onSubmit: ((Result<MailComposeResult, Error>) -> Void)? = nil
  ) -> some View {
    self.modifier(
      _MailComposeViewModifier(
        isPresented: isPresented,
        emailData: emailData,
        onDismiss: onDismiss,
        onSubmit: onSubmit,
        cannotSendEmails: _CannotSendDefaultView.init
      )
    )
  }
}

private struct _MailComposeViewModifier<CannotSendContent: View>: ViewModifier {
  var isPresented: Binding<Bool>
  var emailData: MailComposeData?
  var onDismiss: (() -> Void)?
  var onSubmit: ((Result<MailComposeResult, Error>) -> Void)?
  var cannotSendEmails: CannotSendContent

  init(
    isPresented: Binding<Bool>,
    emailData: MailComposeData? = nil,
    onDismiss: (() -> Void)? = nil,
    onSubmit: ((Result<MailComposeResult, Error>) -> Void)? = nil,
    @ViewBuilder cannotSendEmails: () -> CannotSendContent
  ) {
    self.isPresented = isPresented
    self.emailData = emailData
    self.onDismiss = onDismiss
    self.onSubmit = onSubmit
    self.cannotSendEmails = cannotSendEmails()
  }

  func body(content: Content) -> some View {
    content
      .sheet(isPresented: isPresented, onDismiss: onDismiss) {
        if _MailComposeView.canSendMail() {
          _MailComposeView(emailData: emailData ?? .init()) { result in
            self.onSubmit?(result)
          }
          .ignoresSafeArea()
        } else {
          cannotSendEmails
        }
      }
  }
}

private struct _CannotSendDefaultView: View {
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    VStack {
      Text("Unable to send emails from this device.")
        .padding(.bottom, 20)
        .multilineTextAlignment(.center)
      Button("Dismiss") {
        dismiss()
      }
    }
  }
}
