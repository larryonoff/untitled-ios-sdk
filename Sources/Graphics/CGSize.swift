extension CGSize {
  @inlinable
  public var isEmpty: Bool {
    height.isZero || width.isZero
  }

  @inlinable
  public func rounded(
    _ rule: FloatingPointRoundingRule
  ) -> Self {
    CGSize(
      width: width.rounded(rule),
      height: height.rounded(rule)
    )
  }

  @inlinable
  public func toRect(
    with origin: CGPoint = .zero
  ) -> CGRect {
    .init(
      x: origin.x,
      y: origin.y,
      width: width,
      height: height
    )
  }
}

// MARK: - Operators

extension CGSize {
  @inlinable
  public static func * <Number: BinaryFloatingPoint> (
    size: CGSize,
    scale: Number
  ) -> CGSize {
    .init(
      width: size.width * CGFloat(scale),
      height: size.height * CGFloat(scale)
    )
  }

  @inlinable
  public static func *= <Number: BinaryFloatingPoint> (
    size: inout CGSize,
    scale: Number
  ) {
    size = size * CGFloat(scale)
  }

  @inlinable
  public static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
    .init(
      width: lhs.width * rhs.width,
      height: lhs.height * rhs.height
    )
  }

  @inlinable
  public static func *= (lhs: inout CGSize, rhs: CGSize) {
    lhs = lhs * rhs
  }

  /// Returns a size by applying a transform.
  @inlinable
  public static func * (size: CGSize, transform: CGAffineTransform) -> CGSize {
    size.applying(transform)
  }

  /// Modifies all values by applying a transform.
  @inlinable
  public static func *= (size: inout CGSize, transform: CGAffineTransform) {
    size = size.applying(transform)
  }

  @inlinable
  public static func / (lhs: CGSize, rhs: CGSize) -> CGSize {
    .init(
      width: lhs.width / rhs.width,
      height: lhs.height / rhs.height
    )
  }

  @inlinable
  public static func /= (lhs: inout CGSize, rhs: CGSize) {
    lhs = lhs / rhs
  }

  @inlinable
  public static func / <Number: BinaryFloatingPoint> (
    size: CGSize,
    scale: Number
  ) -> CGSize {
    .init(
      width: size.width / CGFloat(scale),
      height: size.height / CGFloat(scale)
    )
  }

  @inlinable
  public static func /= <Number: BinaryFloatingPoint> (
    size: inout CGSize,
    scale: Number
  ) {
    size = size / CGFloat(scale)
  }
}

// MARK: - Hashable

extension CGSize: Hashable {
  @inlinable
  public func hash(into hasher: inout Hasher) {
    hasher.combine(width)
    hasher.combine(height)
  }
}
