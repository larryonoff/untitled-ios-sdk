#if canImport(MessageUI)

import ComposableArchitecture
import DuckSwiftUI
import SwiftUI

@Reducer
public struct MailCompose {
  public enum Action {
    public enum Delegate {
      case completed(Result<MailComposeResult, any Error>)
      case dismissed
    }

    case delegate(Delegate)
  }

  @ObservableState
  public struct State {
    public let data: MailComposeData

    public init(
      data: MailComposeData = MailComposeData()
    ) {
      self.data = data
    }
  }

  public init() {}
}

extension View {
  /// Presents a mail composer when a piece of optional state held in a store becomes non-`nil`,
  /// and dismisses it when the state becomes `nil`.
  public func mailCompose(
    _ item: Binding<StoreOf<MailCompose>?>
  ) -> some View {
    // The store is captured while the state is still non-`nil`. It must not be
    // re-read inside the callbacks: `isPresented` nils the state out before they
    // run, so reading it there would drop the delegate action entirely.
    let store = item.wrappedValue

    return self.mailCompose(
      isPresented: Binding(item),
      emailData: store?.data,
      onDismiss: {
        store?.send(.delegate(.dismissed))
      },
      onSubmit: { result in
        store?.send(.delegate(.completed(result)))
      }
    )
  }
}

#endif
