import ComposableArchitecture
import CustomDump
@preconcurrency import Foundation
@preconcurrency import PhotosUI
import SwiftUI

public struct PhotosPickerState {
  public let id = UUID()
  public var maxSelectionCount: Int?
  public var selectionBehavior: PhotosPickerSelectionBehavior
  public var filter: PHPickerFilter?
  public var preferredItemEncoding: PhotosPickerItem.EncodingDisambiguationPolicy
  
  public init(
    maxSelectionCount: Int? = nil,
    selectionBehavior: PhotosPickerSelectionBehavior = .default,
    matching filter: PHPickerFilter? = nil,
    preferredItemEncoding: PhotosPickerItem.EncodingDisambiguationPolicy = .automatic
  ) {
    self.maxSelectionCount = maxSelectionCount
    self.selectionBehavior = selectionBehavior
    self.filter = filter
    self.preferredItemEncoding = preferredItemEncoding
  }
}

extension View {
  @ViewBuilder
  public func photosPicker<Action>(
    _ store: Store<PhotosPickerState?, Action>,
    selection: Binding<[PhotosPickerItem]>,
    dismiss: Action
  ) -> some View {
    self.modifier(
      PhotosPickerModifier(
        viewStore: ViewStore(
          store,
          observe: { $0 },
          removeDuplicates: { $0?.id == $1?.id }
        ),
        selection: selection,
        dismiss: dismiss
      )
    )
  }
}

private struct PhotosPickerModifier<Action>: ViewModifier {
  @ObservedObject var viewStore: ViewStore<PhotosPickerState?, Action>
  
  let selection: Binding<[PhotosPickerItem]>
  let dismiss: Action
  
  func body(content: Content) -> some View {
    content.sheet(
      isPresented: viewStore.binding(send: dismiss).isPresent(),
      content: {
        if let state = viewStore.state {
          PhotosPicker(
            selection: selection,
            maxSelectionCount: state.maxSelectionCount,
            selectionBehavior: state.selectionBehavior,
            matching: state.filter,
            preferredItemEncoding: state.preferredItemEncoding,
            label: { EmptyView() }
          )
        }
      }
    )
  }
}

extension PhotosPickerState: CustomDumpReflectable {
  public var customDumpMirror: Mirror {
    Mirror(
      self,
      children: [
        "maxSelectionCount": self.maxSelectionCount as Any,
        "selectionBehavior": self.selectionBehavior,
        "filter": self.filter as Any,
        "preferredItemEncoding": self.preferredItemEncoding
      ],
      displayStyle: .struct
    )
  }
}

extension PhotosPickerState: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.maxSelectionCount == rhs.maxSelectionCount &&
    lhs.selectionBehavior == rhs.selectionBehavior &&
    lhs.filter == rhs.filter &&
    lhs.preferredItemEncoding == rhs.preferredItemEncoding
  }
}

extension PhotosPickerState: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.maxSelectionCount)
    hasher.combine(self.selectionBehavior)
    hasher.combine(self.filter)
    hasher.combine(self.preferredItemEncoding)
  }
}

extension PhotosPickerState: Identifiable {}

extension PhotosPickerState: Sendable {}

extension Binding {
  func isPresent<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
    .init(
      get: { self.wrappedValue != nil },
      set: { isPresent, transaction in
        guard !isPresent else { return }
        self.transaction(transaction).wrappedValue = nil
      }
    )
  }
}