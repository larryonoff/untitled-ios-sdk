import SwiftUI

extension View {
  public func navigationLinkDestination<Content: View>(
    isPresented: Binding<Bool>,
    @ViewBuilder content: () -> Content
  ) -> some View {
    background(
      NavigationLink(
        isActive: isPresented,
        destination: content,
        label: EmptyView.init
      )
    )
  }

  @ViewBuilder
  public func navigationLinkDestination<D: Hashable, Content: View>(
    item: Binding<D?>,
    @ViewBuilder destination: @escaping (D) -> Content
  ) -> some View {
    navigationLinkDestination(isPresented: item.isPresent()) {
      if let item = item.wrappedValue {
        destination(item)
      }
    }
  }
}
