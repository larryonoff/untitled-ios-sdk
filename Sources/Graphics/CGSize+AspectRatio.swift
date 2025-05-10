extension CGSize {
  public func aspectRatio(
    in bounds: CGRect,
    contentMode: CGContentMode
  ) -> CGSize {
    guard !isEmpty else {
      return bounds.size
    }

    let scaleX = bounds.width / width
    let scaleY = bounds.height / height

    let scale: CGFloat

    switch contentMode {
    case .fill:
      scale = max(scaleX, scaleY)
    case .fit:
      scale = min(scaleX, scaleY)
    }

    return CGSize(
      width: width * scale,
      height: height * scale
    )
  }
}
