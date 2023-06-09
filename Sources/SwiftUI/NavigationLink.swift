import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension NavigationLink where Label == EmptyView {
  public init(
    isActive: Binding<Bool>,
    @ViewBuilder destination: () -> Destination
  ) {
    self.init(
      isActive: isActive,
      destination: destination,
      label: EmptyView.init
    )
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
  @ViewBuilder
  public func pushToNavigationStack<Content: View>(
    isPresented: Binding<Bool>,
    @ViewBuilder content: () -> Content
  ) -> some View {
    background(
      NavigationLink(
        isActive: isPresented,
        destination: content
      )
    )
  }
}
