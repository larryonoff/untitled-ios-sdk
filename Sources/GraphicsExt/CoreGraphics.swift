import CoreGraphics
import QuartzCore

// MARK: - Operators

extension CGSize {
  public static func * (size: CGSize, scale: CGFloat) -> CGSize {
    CGSize(
      width: size.width * scale,
      height: size.height * scale
    )
  }

  public static func *= (size: inout CGSize, scale: CGFloat) {
    size = size * scale
  }

  public static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
    CGSize(
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
    CGSize(
      width: lhs.width / rhs.width,
      height: lhs.height / rhs.height
    )
  }

  public static func /= (lhs: inout CGSize, rhs: CGSize) {
    lhs = lhs / rhs
  }

  public static func / (size: CGSize, scale: CGFloat) -> CGSize {
    CGSize(
      width: size.width / scale,
      height: size.height / scale
    )
  }

  public static func /= (size: inout CGSize, scale: CGFloat) {
    size = size / scale
  }
}

// MARK: - Hashable

extension CGSize: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(width)
    hasher.combine(height)
  }
}
