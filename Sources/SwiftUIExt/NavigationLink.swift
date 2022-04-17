import SwiftUI

#if os(iOS) || os(watchOS) || os(tvOS)

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

extension View {
  @ViewBuilder
  public func route<Content: View>(
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

#endif
