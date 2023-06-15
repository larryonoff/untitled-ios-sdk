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
}
