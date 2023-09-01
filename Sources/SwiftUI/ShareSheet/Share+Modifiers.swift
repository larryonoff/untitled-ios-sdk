import ComposableArchitecture
import CustomDump
@preconcurrency import Foundation
import PhotosUI
import SwiftUI

extension View {
  @ViewBuilder
  public func shareSheet<Data: RandomAccessCollection>(
    isPresented: Binding<Bool>,
    data: Data?,
    onCompletion: @escaping ((Result<Data, Swift.Error>) -> Void),
    onCancellation: @escaping () -> Void = {}
  ) -> some View {
    self.modifier(
      ShareSheetViewModifier(
        isPresented: isPresented,
        data: data,
        onCompletion: onCompletion,
        onCancellation: onCancellation
      )
    )
  }
}

private struct ShareSheetViewModifier<Data: RandomAccessCollection>: ViewModifier {
  let isPresented: Binding<Bool>
  let data: Data?
  let onCompletion: ((Result<Data, Swift.Error>) -> Void)
  let onCancellation: () -> Void

  func body(content: Content) -> some View {
    content.sheet(
      isPresented: isPresented,
      content: {
        if let data {
          ShareView(
            data: data,
            onCompletion: onCompletion,
            onCancellation: onCancellation
          )
        }
      }
    )
  }
}
