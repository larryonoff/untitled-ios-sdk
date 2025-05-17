extension CGRect {
  @inlinable
  mutating
  public func center(in rect: CGRect) {
    self = centered(in: rect)
  }

  @inlinable
  public func centered(in rect: CGRect) -> CGRect {
    .init(
      x: rect.minX + (rect.width - width) * 0.5,
      y: rect.minY + (rect.height - height) * 0.5,
      width: size.width,
      height: size.height
    )
  }

  @inlinable
  public func rounded(
    _ rule: FloatingPointRoundingRule
  ) -> Self {
    .init(
      x: origin.x.rounded(rule),
      y: origin.y.rounded(rule),
      width: size.width.rounded(rule),
      height: size.height.rounded(rule)
    )
  }
}
