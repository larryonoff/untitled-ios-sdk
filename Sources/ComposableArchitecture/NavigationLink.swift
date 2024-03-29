@_spi(Reflection) import CasePaths
@_spi(Presentation) import ComposableArchitecture
import DuckSwiftUI
import SwiftUI

extension View {
  @available(iOS, introduced: 13, deprecated: 16)
  @available(macOS, introduced: 10.15, deprecated: 13)
  @available(tvOS, introduced: 13, deprecated: 16)
  @available(watchOS, introduced: 6, deprecated: 9)
  public func navigationLinkDestination<State, Action, Destination: View>(
    store: Store<PresentationState<State>, PresentationAction<Action>>,
    @ViewBuilder destination: @escaping (Store<State, Action>) -> Destination
  ) -> some View {
    self.presentation(store: store) { `self`, $item, _destination in
      self.navigationLinkDestination(item: $item) { _ in
        _destination(destination)
      }
    }
  }
}
