@_spi(Presentation) import ComposableArchitecture
import DuckPhotosUI
import PhotosUI
import SwiftUI

@Reducer
public struct PhotosPickerReducer {
  public enum Action: Equatable {
    case setSelection([_PhotosPickerItem])
  }

  @ObservableState
  public struct State: Equatable, Identifiable {
    public let id = UUID()
    public let maxSelectionCount: Int?
    public let selectionBehavior: PhotosPickerSelectionBehavior
    public let filter: PHPickerFilter?
    public let preferredItemEncoding: PhotosPickerItem.EncodingDisambiguationPolicy

    public var selection: [_PhotosPickerItem]

    public init(
      maxSelectionCount: Int? = nil,
      selectionBehavior: PhotosPickerSelectionBehavior = .default,
      matching filter: PHPickerFilter? = nil,
      preferredItemEncoding: PhotosPickerItem.EncodingDisambiguationPolicy = .automatic,
      selection: [_PhotosPickerItem] = []
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

public struct ComposablePhotosPicker: View {
  @Perception.Bindable private var store: StoreOf<PhotosPickerReducer>

  public init(store: StoreOf<PhotosPickerReducer>) {
    self.store = store
  }

  public var body: some View {
    WithPerceptionTracking {
      if #available(iOS 17.0, macOS 14.0, *) {
        PhotosUI.PhotosPicker(
          selection: $store._rawSelection,
          maxSelectionCount: store.maxSelectionCount,
          selectionBehavior: store.selectionBehavior,
          matching: store.filter,
          preferredItemEncoding: store.preferredItemEncoding,
          photoLibrary: .shared(),
          label: { EmptyView() }
        )
        .photosPickerStyle(.inline)
      } else {
        DuckPhotosUI.PhotosPicker(
          selection: $store.selection.sending(\.setSelection),
          maxSelectionCount: store.maxSelectionCount,
          selectionBehavior: store.selectionBehavior,
          matching: store.filter,
          preferredItemEncoding: store.preferredItemEncoding,
          photoLibrary: .shared(),
          label: { EmptyView() }
        )
        ._photosPickerStyle(.inline)
      }
    }
  }
}

private extension StoreOf<PhotosPickerReducer> {
  var _rawSelection: [PhotosPickerItem] {
    get { state.selection.compactMap(\.pickerItem) }
    set { send(.setSelection(newValue.map(_PhotosPickerItem.init))) }
  }
}

