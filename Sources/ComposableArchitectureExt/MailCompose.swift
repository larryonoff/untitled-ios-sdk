import ComposableArchitecture
import SwiftUI
import SwiftUIExt

extension View {
  @ViewBuilder
  public func mailCompose<Action>(
    _ store: Store<MailComposeData?, Action>,
    dismiss: Action,
    onSubmit: ((Result<MailComposeResult, Error>) -> Void)? = nil
  ) -> some View {
    self.modifier(
      _MailComposeModifier(
        viewStore: ViewStore(store, removeDuplicates: { $0 == $1 }),
        dismiss: dismiss,
        onSubmit: onSubmit
      )
    )
  }
}

private struct _MailComposeModifier<Action>: ViewModifier {
  @StateObject var viewStore: ViewStore<MailComposeData?, Action>
  let dismiss: Action
  let onSubmit: ((Result<MailComposeResult, Error>) -> Void)?

  func body(content: Content) -> some View {
    if let state = viewStore.state {
      content.mailCompose(
        isPresented: viewStore.binding(send: dismiss).isPresent(),
        emailData: viewStore.state,
        onDismiss: { viewStore.send(dismiss) },
        onSubmit: onSubmit
      )
    } else {
      content
    }
  }
}
