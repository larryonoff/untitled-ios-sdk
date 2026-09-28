import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// The widest a column of content is allowed to grow.
///
/// A layout drawn for a phone rarely improves by filling an iPad or an unfolded
/// iPhone Duo: running text overshoots a comfortable measure, and a row of
/// controls pulls its ends so far apart that they read as unrelated. Both caps
/// are wider than any phone, so they only take effect on a wide container.
/// Each grows with Dynamic Type, so larger text keeps about as many words to a
/// line instead of wrapping sooner.
public struct ContentWidth: Hashable, Sendable {
  private let maximum: Maximum

  /// A cap of `maximum` points at the default text size, scaled with Dynamic Type.
  public init(maximum: CGFloat) {
    self.maximum = .scaled(maximum)
  }

  private init(_ maximum: Maximum) {
    self.maximum = maximum
  }

  /// Running text: paragraphs, articles, long-form copy. UIKit's
  /// `readableContentGuide`, measured at the current text size.
  public static let readable = Self(.readable)

  /// Controls and fields: pickers, plan rows, a primary button. Narrower than
  /// ``readable``: a control is read as one object, and stretched further its
  /// leading label and trailing value stop looking related.
  public static let form = Self(maximum: 480)

  private enum Maximum: Hashable, Sendable {
    case readable
    case scaled(CGFloat)
  }
}

/// Where ``SwiftUI/View/contentWidth(_:alignment:for:)`` narrows the column.
public enum ContentWidthPlacement: Sendable {
  /// The view itself: works on any view, nested panels included.
  case automatic

  /// A `ScrollView`'s content, through its content margins, leaving the scroll
  /// view — its scrolling area and indicators — the full width. Apply it to the
  /// scroll view, not to the stack inside it.
  case scrollContent
}

extension View {
  /// Caps this view at `width` and places it in the width it is offered, so only
  /// the content narrows while the view still spans its container. Backgrounds
  /// belong outside it.
  ///
  /// ```swift
  /// VStack { plans; purchaseButton }
  ///   .contentWidth(.form)
  ///
  /// ScrollView { article }
  ///   .contentWidth(.readable, for: .scrollContent)
  /// ```
  public func contentWidth(
    _ width: ContentWidth,
    alignment: HorizontalAlignment = .center,
    for placement: ContentWidthPlacement = .automatic
  ) -> some View {
    modifier(ContentWidthModifier(width: width, alignment: alignment, placement: placement))
  }
}

private struct ContentWidthModifier: ViewModifier {
  let width: ContentWidth
  let alignment: HorizontalAlignment
  let placement: ContentWidthPlacement

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @State private var containerWidth: CGFloat = 0

  func body(content: Content) -> some View {
    let maximum = width.maximum(for: dynamicTypeSize)

    switch placement {
    case .automatic:
      let alignment = Alignment(horizontal: alignment, vertical: .center)
      content
        .frame(maxWidth: maximum, alignment: alignment)
        .frame(maxWidth: .infinity, alignment: alignment)
    case .scrollContent:
      let spare = max(0, containerWidth - maximum)
      let leading = spare * alignment.leadingShare
      content
        .contentMargins(.leading, leading, for: .scrollContent)
        .contentMargins(.trailing, spare - leading, for: .scrollContent)
        .onGeometryChange(for: CGFloat.self) { proxy in
          // Already inside the parent's safe area; subtracting the insets
          // again would count an uneven one twice.
          proxy.size.width
        } action: {
          containerWidth = $0
        }
    }
  }
}

private extension HorizontalAlignment {
  /// The part of the spare width that goes before the column.
  var leadingShare: CGFloat {
    switch self {
    case .leading: 0
    case .trailing: 1
    default: 0.5
    }
  }
}

private extension ContentWidth {
  @MainActor
  func maximum(for dynamicTypeSize: DynamicTypeSize) -> CGFloat {
    switch maximum {
    case .readable: Self.readableWidth(for: dynamicTypeSize)
    case let .scaled(maximum): Self.scaled(maximum, for: dynamicTypeSize)
    }
  }

  #if canImport(UIKit)
  @MainActor
  static func scaled(_ value: CGFloat, for dynamicTypeSize: DynamicTypeSize) -> CGFloat {
    UIFontMetrics(forTextStyle: .body).scaledValue(
      for: value,
      compatibleWith: UITraitCollection(
        preferredContentSizeCategory: UIContentSizeCategory(dynamicTypeSize)
      )
    )
  }

  /// UIKit's readable width at `dynamicTypeSize`, measured once per size.
  @MainActor
  static func readableWidth(for dynamicTypeSize: DynamicTypeSize) -> CGFloat {
    if let width = readableWidths[dynamicTypeSize] {
      return width
    }

    // The guide takes its width from the text size alone; a container wider
    // than any screen leaves it at its cap.
    measuringView.traitOverrides.preferredContentSizeCategory = UIContentSizeCategory(dynamicTypeSize)
    measuringView.frame = CGRect(x: 0, y: 0, width: 10_000, height: 1)
    measuringView.layoutIfNeeded()

    let measured = measuringView.readableContentGuide.layoutFrame.width
    // Unmeasurable (no layout pass yet): the guide's width at the default size.
    let width = measured > 0 ? measured : scaled(672, for: dynamicTypeSize)
    readableWidths[dynamicTypeSize] = width
    return width
  }

  @MainActor private static var readableWidths: [DynamicTypeSize: CGFloat] = [:]

  @MainActor private static let measuringView: UIView = {
    let container = UIView()
    let column = UIView()
    column.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(column)
    // The guide only gets a frame offscreen once it takes part in layout.
    NSLayoutConstraint.activate([
      column.leadingAnchor.constraint(equalTo: container.readableContentGuide.leadingAnchor),
      column.trailingAnchor.constraint(equalTo: container.readableContentGuide.trailingAnchor),
      column.topAnchor.constraint(equalTo: container.topAnchor),
      column.bottomAnchor.constraint(equalTo: container.bottomAnchor)
    ])
    return container
  }()
  #else
  static func scaled(_ value: CGFloat, for dynamicTypeSize: DynamicTypeSize) -> CGFloat {
    value
  }

  static func readableWidth(for dynamicTypeSize: DynamicTypeSize) -> CGFloat {
    672
  }
  #endif
}
