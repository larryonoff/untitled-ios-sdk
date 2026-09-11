import SwiftUI

extension View {
  /// Sizes the enclosing sheet to its content's ideal height.
  ///
  /// A compact-width iPhone sheet takes its height from its detents, and
  /// `.presentationSizing(.fitted)` does not resolve them, so the height is
  /// measured and fed back as a `.height` detent — the same approach BEAT's
  /// `_presentationSizingFitted` uses. macOS sheets size to their content on
  /// their own, so there is nothing to do there.
  ///
  /// The content has to be self-sizing vertically — no `frame(maxHeight:)`,
  /// no bare `Spacer()` at the root — or it measures the space it was given
  /// and pins the sheet to whatever it first got.
  public func presentationSizingFitted(
    maximumHeight: CGFloat? = nil
  ) -> some View {
    modifier(_FittedPresentationSizingModifier(maximumHeight: maximumHeight))
  }
}

private struct _FittedPresentationSizingModifier: ViewModifier {
  let maximumHeight: CGFloat?

  /// Height the content wants. `nil` until the first layout pass.
  @State private var contentHeight: CGFloat?

  func body(content: Content) -> some View {
    #if os(iOS)
      content
        // Measure the content's own ideal height rather than the frame the
        // sheet grants it: reading the granted frame would feed the detent its
        // own output.
        .background {
          GeometryReader { geometry in
            Color.clear
              .preference(key: ContentHeightKey.self, value: geometry.size.height)
          }
        }
        .onPreferenceChange(ContentHeightKey.self) { height in
          guard height > 0, height != contentHeight else { return }
          contentHeight = height
        }
        .presentationDetents([detent])
    #else
      content
    #endif
  }

  /// `.medium` stands in for the frame before the first measurement lands.
  /// A fresh `.height` value per measurement is what makes the sheet follow
  /// the content instead of pinning to the first frame it got.
  private var detent: PresentationDetent {
    guard let contentHeight else { return .medium }

    return .height(maximumHeight.map { min(contentHeight, $0) } ?? contentHeight)
  }
}

private struct ContentHeightKey: PreferenceKey {
  static let defaultValue: CGFloat = 0

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = max(value, nextValue())
  }
}
