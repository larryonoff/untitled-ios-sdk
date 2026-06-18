@_spi(Presentation) import ComposableArchitecture
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
    let store = item.wrappedValue
    let state = store?.withState { $0 }

    return self.mailCompose(
      isPresented: Binding(item),
      emailData: state?.data,
      onDismiss: {
        store?.send(.delegate(.dismissed))
      },
      onSubmit: { result in
        store?.send(.delegate(.completed(result)))
      }
    )
  }
}
