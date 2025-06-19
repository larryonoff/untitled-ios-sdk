import CoreGraphics

extension CGVector {
  @inlinable
  public static func + (lhs: Self, rhs: Self) -> Self {
    .init(
      dx: lhs.dx + rhs.dx,
      dy: lhs.dy + rhs.dy
    )
  }

  @inlinable
  public static func += (lhs: inout Self, rhs: Self) {
    lhs.dx += rhs.dx
    lhs.dy += rhs.dy
  }

  @inlinable
  public static func + (lhs: Self, rhs: CGFloat) -> Self {
    .init(
      dx: lhs.dx + rhs,
      dy: lhs.dy + rhs
    )
  }

  @inlinable
  public static func += (lhs: inout Self, rhs: CGFloat) {
    lhs.dx += rhs
    lhs.dy += rhs
  }

  @inlinable
  public static func + (lhs: Self, rhs: CGSize) -> Self {
    .init(
      dx: lhs.dx + rhs.width,
      dy: lhs.dy + rhs.height
    )
  }

  @inlinable
  public static func += (lhs: inout Self, rhs: CGSize) {
    lhs.dx += rhs.width
    lhs.dy += rhs.height
  }

  @inlinable
  public static func - (lhs: Self, rhs: Self) -> Self {
    .init(
      dx: lhs.dx - rhs.dx,
      dy: lhs.dy - rhs.dy
    )
  }

  @inlinable
  public static func -= (lhs: inout Self, rhs: Self) {
    lhs.dx -= rhs.dx
    lhs.dy -= rhs.dy
  }

  @inlinable
  public static func - (lhs: Self, rhs: CGFloat) -> Self {
    .init(
      dx: lhs.dx + rhs,
      dy: lhs.dy + rhs
    )
  }

  @inlinable
  public static func -= (lhs: inout Self, rhs: CGFloat) {
    lhs.dx -= rhs
    lhs.dy -= rhs
  }

  @inlinable
  public static func * (lhs: Self, scale: CGFloat) -> Self {
    .init(
      dx: lhs.dx * scale,
      dy: lhs.dy * scale
    )
  }

  @inlinable
  public static func *= (lhs: inout Self, scale: CGFloat) {
    lhs = lhs * scale
  }

  @inlinable
  public static func * (lhs: Self, rhs: Self) -> Self {
    .init(
      dx: lhs.dx * rhs.dx,
      dy: lhs.dy * rhs.dy
    )
  }

  @inlinable
  public static func *= (lhs: inout Self, rhs: Self) {
    lhs = lhs * rhs
  }

  @inlinable
  public static func * (lhs: Self, size: CGSize) -> Self {
    .init(
      dx: lhs.dx * size.width,
      dy: lhs.dy * size.height
    )
  }

  @inlinable
  public static func *= (lhs: inout Self, size: CGSize) {
    lhs = lhs * size
  }

  @inlinable
  public static func / (lhs: Self, rhs: Self) -> Self {
    .init(
      dx: lhs.dx / rhs.dx,
      dy: lhs.dy / rhs.dy
    )
  }

  @inlinable
  public static func /= (lhs: inout Self, rhs: Self) {
    lhs = lhs / rhs
  }

  @inlinable
  public static func / (lhs: Self, scale: CGFloat) -> Self {
    .init(
      dx: lhs.dx / scale,
      dy: lhs.dy / scale
    )
  }

  @inlinable
  public static func /= (lhs: inout Self, scale: CGFloat) {
    lhs = lhs / scale
  }

  @inlinable
  public static func / (lhs: Self, size: CGSize) -> Self {
    .init(
      dx: lhs.dx / size.width,
      dy: lhs.dy / size.height
    )
  }

  @inlinable
  public static func /= (lhs: inout Self, size: CGSize) {
    lhs = lhs / size
  }

  @inlinable
  public static func / (scale: CGFloat, size: Self) -> Self {
    .init(
      dx: scale / size.dx,
      dy: scale / size.dy
    )
  }

  @inlinable
  public static func /= (scale: CGFloat, size: inout Self) {
    size = scale / size
  }

  @inlinable
  public static func < (lhs: Self, rhs: CGFloat) -> Bool {
    lhs.dx < rhs && lhs.dy < rhs
  }

  @inlinable
  public static func <= (lhs: Self, rhs: CGFloat) -> Bool {
    lhs.dx <= rhs && lhs.dy <= rhs
  }

  @inlinable
  public static func > (lhs: Self, rhs: CGFloat) -> Bool {
    lhs.dx > rhs && lhs.dy > rhs
  }

  @inlinable
  public static func >= (lhs: Self, rhs: CGFloat) -> Bool {
    lhs.dx >= rhs && lhs.dy >= rhs
  }
}

@inlinable
prefix public func - (_ size: CGVector) -> CGVector {
  .init(dx: -size.dx, dy: -size.dy)
}
