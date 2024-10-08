import ComposableArchitecture
import DuckSwiftUI
import SwiftUI

extension View {
  @ViewBuilder
  public func mailCompose<Action>(
    _ store: Store<MailComposeData?, Action>,
    dismiss: Action,
    onSubmit: ((Result<MailComposeResult, any Error>) -> Void)? = nil
  ) -> some View {
    self.modifier(
      _MailComposeModifier(
        viewStore: ViewStore(
          store,
          observe: { $0 },
          removeDuplicates: { $0 == $1 }
        ),
        dismiss: dismiss,
        onSubmit: onSubmit
      )
    )
  }
}

private struct _MailComposeModifier<Action>: ViewModifier {
  @StateObject var viewStore: ViewStore<MailComposeData?, Action>
  let dismiss: Action
  let onSubmit: ((Result<MailComposeResult, any Error>) -> Void)?

  func body(content: Content) -> some View {
    content.mailCompose(
      isPresented: Binding(viewStore.binding(send: dismiss)),
      emailData: viewStore.state,
      onDismiss: { viewStore.send(dismiss) },
      onSubmit: onSubmit
    )
  }
}
