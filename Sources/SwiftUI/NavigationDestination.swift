import SwiftUI

extension View {
  @available(iOS, introduced: 16, deprecated: 17)
  @available(macOS, introduced: 13, deprecated: 14)
  @available(tvOS, introduced: 16, deprecated: 17)
  @available(watchOS, introduced: 9, deprecated: 10)
  @ViewBuilder
  public func _navigationDestination<D: Hashable, C: View>(
    item: Binding<D?>,
    @ViewBuilder destination: @escaping (D) -> C
  ) -> some View {
    navigationDestination(isPresented: item.isPresent()) {
      if let item = item.wrappedValue {
        destination(item)
      }
    }
  }
}
