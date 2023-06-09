import SwiftUI

extension View {
  public func synchronize<Value>(
    _ first: Binding<Value>,
    _ second: FocusState<Value>.Binding
  ) -> some View {
    self
      .onChange(of: first.wrappedValue) {
        guard second.wrappedValue != $0 else { return }
        second.wrappedValue = $0
      }
      .onChange(of: second.wrappedValue) {
        guard first.wrappedValue != $0 else { return }
        first.wrappedValue = $0
      }
  }
}
