@_spi(Presentation) import ComposableArchitecture
import DuckSwiftUI
import SwiftUI

@Reducer
public struct ShareSheet<Data: RandomAccessCollection> {
  public enum Action {
    public enum Delegate {
      case completed(Result<Data, any Error>)
      case cancelled
    }

    case delegate(Delegate)
  }

  @ObservableState
  public struct State {
    public let data: Data

    public init(
      data: Data
    ) {
      self.data = data
    }
  }

  public init() {}
}

extension View {
  /// Presents a share sheet when a piece of optional state held in a store becomes non-`nil`.
  public func shareSheet<Data: RandomAccessCollection>(
    _ item: Binding<StoreOf<ShareSheet<Data>>?>
  ) -> some View {
    let store = item.wrappedValue
    let state = store?.withState { $0 }

    return self.shareSheet(
      isPresented: Binding(item),
      data: state?.data,
      onCompletion: { result in
        store?.send(.delegate(.completed(result)))
      },
      onCancellation: {
        store?.send(.delegate(.cancelled))
      }
    )
  }
}

extension View {
  /// Displays a share sheet when then store's state becomes non-`nil`, and dismisses it when it becomes
  /// `nil`.
  ///
  /// - Parameters:
  ///   - store: A store that is focused on ``PresentationState`` and ``PresentationAction`` for an
  ///     share sheet.
  public func shareSheet<Data: RandomAccessCollection>(
    store: Store<
      PresentationState<ShareSheet<Data>.State>,
      PresentationAction<ShareSheet<Data>.Action>
    >
  ) -> some View {
    self._shareSheet(store: store, state: { $0 }, action: { $0 })
  }

  private func _shareSheet<State, Action, Data: RandomAccessCollection>(
    store: Store<PresentationState<State>, PresentationAction<Action>>,
    state toDestinationState: @escaping (_ state: State) -> ShareSheet<Data>.State?,
    action fromDestinationAction: @escaping (_ sheetAction: ShareSheet<Data>.Action) -> Action
  ) -> some View {
    self.presentation(
      store: store,
      state: toDestinationState,
      action: fromDestinationAction
    ) { `self`, $isPresented, destination in
      let shareState = store.withState(\.wrappedValue).flatMap(toDestinationState)

      self.shareSheet(
        isPresented: $isPresented,
        data: shareState?.data,
        onCompletion: { result in
          let action = fromDestinationAction(.delegate(.completed(result)))
          store.send(.presented(action))
        },
        onCancellation: {
          store.send(.presented(fromDestinationAction(.delegate(.cancelled))))
        }
      )
    }
  }
}
