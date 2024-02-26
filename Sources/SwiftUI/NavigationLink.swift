import SwiftUI

extension View {
  public func navigationLinkDestination<Item, Content>(
    item: Binding<Item?>,
    @ViewBuilder destination: @escaping (Item) -> Content
  ) -> some View where Item: Identifiable, Content: View {
    background(
      NavigationLink(
        tag: item.wrappedValue?.id,
        selection: Binding(
          get: { item.wrappedValue?.id },
          set: { newValue, transaction in
            guard newValue == nil else { return }
            guard newValue != item.wrappedValue?.id else { return }
            item.transaction(transaction).wrappedValue = nil
          }
        ),
        destination: {
          if let item = item.wrappedValue {
            destination(item)
              .id(item.id)
          }
        },
        label: EmptyView.init
      )
      #if os(iOS)
        .isDetailLink(false)
      #endif
    )
  }

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
      #if os(iOS)
        .isDetailLink(false)
      #endif
    )
  }
}
