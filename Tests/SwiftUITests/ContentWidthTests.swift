#if canImport(UIKit)
import DuckSwiftUI
import DuckTestSupport
import SwiftUI
import Testing
import UIKit

@MainActor
@Suite(.uiHosting, .timeLimit(.minutes(1)))
struct ContentWidthTests {
  @Test(arguments: [500.5, 801.5, 1000.5], [false, true])
  func `scroll content keeps the form cap at fractional viewport widths`(width: Double, isRightToLeft: Bool) async throws {
    try await checkColumn(width: width, isRightToLeft: isRightToLeft, scale: 3, alignment: .center, textSize: .large)
  }

  @Test(arguments: [false, true], [2.0, 3.0])
  func `scroll alignment and enlarged text keep the column within the viewport`(isRightToLeft: Bool, scale: Double) async throws {
    for alignment in [HorizontalAlignment.leading, .center, .trailing] {
      for textSize in [DynamicTypeSize.large, .accessibility1] {
        try await checkColumn(width: 1000, isRightToLeft: isRightToLeft, scale: scale, alignment: alignment, textSize: textSize)
      }
    }
  }

  private func checkColumn(width: Double, isRightToLeft: Bool, scale: Double, alignment: HorizontalAlignment, textSize: DynamicTypeSize) async throws {
    let measured = ColumnFrameProbe.Storage()
    let host = UIHostingController(rootView:
      ScrollView {
        Color.clear
          .frame(height: 2000)
          .frame(maxWidth: .infinity)
          .background(ColumnFrameProbe(storage: measured))
      }
      .contentWidth(.form, alignment: alignment, for: .scrollContent)
      .environment(\.dynamicTypeSize, textSize)
      .environment(\.displayScale, scale)
      .environment(\.layoutDirection, isRightToLeft ? .rightToLeft : .leftToRight)
    )
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: width, height: 640))
    let semantic: UISemanticContentAttribute = isRightToLeft ? .forceRightToLeft : .forceLeftToRight
    window.semanticContentAttribute = semantic
    host.view.semanticContentAttribute = semantic
    window.rootViewController = host
    window.makeKeyAndVisible()
    defer { window.isHidden = true; window.rootViewController = nil }
    host.view.layoutIfNeeded()
    let maximum = maximumColumn(textSize)
    let spare = max(0, width - maximum)
    let leadingShare: CGFloat = alignment == .leading ? 0 : alignment == .trailing ? 1 : 0.5
    let expectedX = spare * (isRightToLeft ? 1 - leadingShare : leadingShare)
    try await waitUntil("Column did not settle: frame \(measured.frame), expected x \(expectedX), cap \(maximum), alignment \(alignment), text \(textSize), scale \(scale), RTL \(isRightToLeft), UIKit RTL \(host.view.effectiveUserInterfaceLayoutDirection == .rightToLeft)") {
      let frame = measured.frame
      return frame.width > 0 && frame.width <= min(width, maximum) + 2 / scale + 0.001 && abs(frame.minX - expectedX) <= 2 / scale + 0.001
    }
    // UIKit defines the Dynamic Type scale; pixel rounding may add less than two pixels.
    let frame = measured.frame
    #expect(frame.width <= min(width, maximum) + 2 / scale + 0.001)
    #expect(abs(frame.minX - expectedX) <= 2 / scale + 0.001)
    let scroll = try #require(firstScrollView(in: host.view))
    let horizontalExtent = scroll.contentSize.width + scroll.adjustedContentInset.left + scroll.adjustedContentInset.right
    let viewportWidth = scroll.bounds.width
    #expect(horizontalExtent <= viewportWidth + 0.001, "frame \(frame), cap \(maximum), alignment \(alignment), text \(textSize), scale \(scale), RTL \(isRightToLeft)")
  }

  private func maximumColumn(_ size: DynamicTypeSize) -> CGFloat {
    UIFontMetrics(forTextStyle: .body).scaledValue(for: 480, compatibleWith: UITraitCollection(preferredContentSizeCategory: UIContentSizeCategory(size)))
  }

  private func firstScrollView(in view: UIView) -> UIScrollView? {
    if let scroll = view as? UIScrollView { return scroll }
    for child in view.subviews {
      if let scroll = firstScrollView(in: child) { return scroll }
    }
    return nil
  }
}
/// UIKit conversion measures the final physical placement, after SwiftUI's RTL transforms.
private struct ColumnFrameProbe: UIViewRepresentable {
  @MainActor
  final class Storage {
    weak var view: UIView?

    var frame: CGRect {
      guard let view, let window = view.window else { return .zero }
      return view.convert(view.bounds, to: window)
    }
  }

  let storage: Storage

  func makeUIView(context: Context) -> UIView {
    let view = UIView()
    storage.view = view
    return view
  }

  func updateUIView(_ uiView: UIView, context: Context) {}
}
#endif
