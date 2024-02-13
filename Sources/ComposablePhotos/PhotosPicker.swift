@_spi(Presentation) import ComposableArchitecture
import DuckPhotosUI
import Foundation
import SwiftUI

@Reducer
public struct PhotosPickerReducer {
  public enum Action: Equatable {
    case setSelection([DuckPhotosUI.PhotosPickerItem])
  }

  public struct State: Equatable, Identifiable {
    public let id = UUID()
    public let maxSelectionCount: Int?
    public let selectionBehavior: DuckPhotosUI.PhotosPickerSelectionBehavior
    public let filter: PHPickerFilter?
    public let preferredItemEncoding: DuckPhotosUI.PhotosPickerItem.EncodingDisambiguationPolicy

    public internal(set) var selection: [DuckPhotosUI.PhotosPickerItem]

    public init(
      maxSelectionCount: Int? = nil,
      selectionBehavior: DuckPhotosUI.PhotosPickerSelectionBehavior = .default,
      matching filter: PHPickerFilter? = nil,
      preferredItemEncoding: DuckPhotosUI.PhotosPickerItem.EncodingDisambiguationPolicy = .automatic,
      selection: [DuckPhotosUI.PhotosPickerItem] = []
    ) {
      self.maxSelectionCount = maxSelectionCount
      self.selectionBehavior = selectionBehavior
      self.filter = filter
      self.preferredItemEncoding = preferredItemEncoding
      self.selection = selection
    }
  }

  public init() {}
}

extension View {
  public func photosPicker(
    _ item: Binding<Store<PhotosPickerReducer.State, PhotosPickerReducer.Action>?>
  ) -> some View {
    self.sheet(item: item) {
      _PhotosPicker(store: $0)
    }
  }

  public func photosPicker(
    store: Store<PresentationState<PhotosPickerReducer.State>, PresentationAction<PhotosPickerReducer.Action>>
  ) -> some View {
    self.photosPicker(store: store, state: { $0 }, action: { $0 })
  }

  public func photosPicker<State, Action>(
    store: Store<PresentationState<State>, PresentationAction<Action>>,
    state toDestinationState: @escaping (_ state: State) -> PhotosPickerReducer.State?,
    action fromDestinationAction: @escaping (_ alertAction: PhotosPickerReducer.Action) -> Action
  ) -> some View {
    self.presentation(
      store: store, state: toDestinationState, action: fromDestinationAction
    ) { `self`, $isPresented, destination in
      self.sheet(isPresented: $isPresented) {
        destination {
          _PhotosPicker(store: $0)
        }
      }
    }
  }
}

private struct _PhotosPicker: View {
  let store: StoreOf<PhotosPickerReducer>

  var body: some View {
    WithViewStore(
      store,
      observe: { $0 },
      removeDuplicates: { $0.id == $1.id }
    ) { viewStore in
      PhotosPicker(
        selection: viewStore.binding(
          get: \.selection,
          send: PhotosPickerReducer.Action.setSelection
        ),
        maxSelectionCount: viewStore.maxSelectionCount,
        selectionBehavior: viewStore.selectionBehavior,
        matching: viewStore.filter,
        preferredItemEncoding: viewStore.preferredItemEncoding,
        label: { EmptyView() }
      )
    }
  }
}
