extension CGRect {
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
