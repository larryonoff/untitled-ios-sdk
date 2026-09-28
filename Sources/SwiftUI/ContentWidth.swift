import SwiftUI

/// The widest a column of content is allowed to grow.
///
/// A layout drawn for a phone rarely improves by filling an iPad or an unfolded
/// iPhone Duo: running text overshoots a comfortable measure, and a row of
/// controls pulls its ends so far apart that they read as unrelated. Both caps
/// are wider than any phone, so they only take effect on a wide container.
public struct ContentWidth: Hashable, Sendable {
  public var maximum: CGFloat

  public init(maximum: CGFloat) {
    self.maximum = maximum
  }

  /// Running text: paragraphs, articles, long-form copy. What UIKit's
  /// `readableContentGuide` settles on at the default text size; scales with
  /// Dynamic Type from there.
  public static let readable = Self(maximum: 672)

  /// Controls and fields: pickers, plan rows, a primary button. Narrower than
  /// ``readable``: a control is read as one object, and stretched further its
  /// leading label and trailing value stop looking related.
  public static let form = Self(maximum: 480)
}

extension View {
  /// Caps this view at `width` and centres it in the width it is offered, so
  /// only the content narrows while the view still spans its container.
  ///
  /// ```swift
  /// VStack { plans; purchaseButton }
  ///   .contentWidth(.form)
  /// ```
  public func contentWidth(_ width: ContentWidth) -> some View {
    modifier(ContentWidthModifier(width: width))
  }
}

private struct ContentWidthModifier: ViewModifier {
  /// Grows with Dynamic Type, as UIKit's readable guide does: larger text keeps
  /// about as many words to a line instead of wrapping sooner. The container
  /// still bounds it.
  @ScaledMetric private var maximum: CGFloat

  init(width: ContentWidth) {
    _maximum = ScaledMetric(wrappedValue: width.maximum, relativeTo: .body)
  }

  func body(content: Content) -> some View {
    content
      .frame(maxWidth: maximum)
      .frame(maxWidth: .infinity)
  }
}

