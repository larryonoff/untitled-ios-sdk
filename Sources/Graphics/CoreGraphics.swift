import CoreGraphics
import QuartzCore

// MARK: - Operators

extension CGSize {
  public static func * <Number: BinaryFloatingPoint> (
    size: CGSize,
    scale: Number
  ) -> CGSize {
    .init(
      width: size.width * CGFloat(scale),
      height: size.height * CGFloat(scale)
    )
  }

  public static func *= <Number: BinaryFloatingPoint> (
    size: inout CGSize,
    scale: Number
  ) {
    size = size * CGFloat(scale)
  }

  public static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
    .init(
      width: lhs.width * rhs.width,
      height: lhs.height * rhs.height
    )
  }

  public static func *= (lhs: inout CGSize, rhs: CGSize) {
    lhs = lhs * rhs
  }

  /// Returns a size by applying a transform.
  public static func * (size: CGSize, transform: CGAffineTransform) -> CGSize {
    size.applying(transform)
  }

  /// Modifies all values by applying a transform.
  public static func *= (size: inout CGSize, transform: CGAffineTransform) {
    size = size.applying(transform)
  }

  public static func / (lhs: CGSize, rhs: CGSize) -> CGSize {
    .init(
      width: lhs.width / rhs.width,
      height: lhs.height / rhs.height
    )
  }

  public static func /= (lhs: inout CGSize, rhs: CGSize) {
    lhs = lhs / rhs
  }

  public static func / <Number: BinaryFloatingPoint> (
    size: CGSize,
    scale: Number
  ) -> CGSize {
    .init(
      width: size.width / CGFloat(scale),
      height: size.height / CGFloat(scale)
    )
  }

  public static func /= <Number: BinaryFloatingPoint> (
    size: inout CGSize,
    scale: Number
  ) {
    size = size / CGFloat(scale)
  }
}

// MARK: - Hashable

extension CGSize: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(width)
    hasher.combine(height)
  }
}
