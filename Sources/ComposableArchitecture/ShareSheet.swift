#if canImport(UIKit)

@_spi(Internals) import ComposableArchitecture
@_spi(Presentation) import DuckSwiftUI
import SwiftUI

// Dismissed the first time it is interacted with, as an alert is: `ifLet` clears
// the state once the chosen action is sent.
extension ShareSheetState: _EphemeralState {}

extension View {
  /// Presents a share sheet when a piece of optional state held in a store becomes non-`nil`.
  ///
  /// ```swift
  /// @Presents var shareSheet: ShareSheetState<Action.ShareSheet>?
  ///
  /// .shareSheet($store.scope(state: \.shareSheet, action: \.shareSheet))
  /// ```
  @MainActor
  public func shareSheet<Action>(
    _ item: Binding<Store<ShareSheetState<Action>, Action>?>
  ) -> some View {
    shareSheet(
      item: item,
      // Not `withState`, deprecated for `@ObservableState`, which this state cannot
      // adopt. Unobserved is fine: it never changes while presented, and the binding
      // already tracks whether it is there.
      state: { $0.currentState },
      action: { store, action in store.send(action) }
    )
  }
}

#endif
