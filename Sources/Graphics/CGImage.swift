import CoreGraphics

extension CGImage {
  public func scaledToFit(
    size: CGSize
  ) -> CGImage? {
    guard !size.width.isZero, !size.height.isZero else {
      return self
    }

    guard let space = colorSpace else { return nil }

    let ratio = min(
      size.width / CGFloat(width),
      size.height / CGFloat(height)
    )

    let scaledWidth = CGFloat(width) * ratio
    let scaledHeight = CGFloat(height) * ratio

    guard
      let context = CGContext(
        data: nil,
        width: Int(size.width),
        height: Int(size.height),
        bitsPerComponent: bitsPerComponent,
        bytesPerRow: bytesPerRow,
        space: space,
        bitmapInfo: alphaInfo.rawValue
      )
    else { return nil }

    context.interpolationQuality = .high
    context.draw(
      self,
      in: CGRect(
        x: (size.width - scaledWidth) * 0.5,
        y: (size.height - scaledHeight) * 0.5,
        width: scaledWidth,
        height: scaledHeight
      )
    )

    return context.makeImage()
  }
}
