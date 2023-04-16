import ComposableArchitecture
import CustomDump
@preconcurrency import Foundation
import PhotosUI
import SwiftUI

public struct ShareSheetState<Data: RandomAccessCollection> {
  public let id = UUID()
  public var data: Data

  public init(
    data: Data
  ) {
    self.data = data
  }
}

extension View {
  @ViewBuilder
  public func shareSheet<Data: RandomAccessCollection, Action>(
    _ store: Store<ShareSheetState<Data>?, Action>,
    onComplete: ((Result<ShareResult<Data>, Swift.Error>) -> Void)?,
    dismiss: Action
  ) -> some View {
    self.modifier(
      ShareSheetViewModifier(
        viewStore: ViewStore(
          store,
          removeDuplicates: { $0?.id == $1?.id }
        ),
        onComplete: onComplete,
        dismiss: dismiss
      )
    )
  }
}

private struct ShareSheetViewModifier<Data: RandomAccessCollection, Action>: ViewModifier {
  @ObservedObject var viewStore: ViewStore<ShareSheetState<Data>?, Action>

  let onComplete: ((Result<ShareResult<Data>, Swift.Error>) -> Void)?
  let dismiss: Action

  func body(content: Content) -> some View {
    content.sheet(
      isPresented: viewStore.binding(send: dismiss).isPresent(),
      content: {
        if let state = viewStore.state {
          ShareView(
            data: state.data,
            onComplete: onComplete
          )
        }
      }
    )
  }
}

extension ShareSheetState: CustomDumpReflectable {
  public var customDumpMirror: Mirror {
    Mirror(
      self,
      children: [
        "data": self.data as Any
      ],
      displayStyle: .struct
    )
  }
}

extension ShareSheetState: Equatable where Data: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.data == rhs.data
  }
}

extension ShareSheetState: Hashable where Data: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.data)
  }
}

extension ShareSheetState: Sendable where Data: Sendable {}

extension ShareSheetState: Identifiable {}
