import CoreGraphics

extension CGRect {
  func fitted(in rect: CGRect) -> CGRect {
    let size = self.size.fitted(in: rect.size)
    let x = rect.origin.x + (rect.size.width - size.width) / 2
    let y = rect.origin.y + (rect.size.height - size.height) / 2
    return CGRect(x: x, y: y, width: size.width, height: size.height)
  }

  func filled(in rect: CGRect) -> CGRect {
    let size = self.size.filled(in: rect.size)
    let x = rect.origin.x + (rect.size.width - size.width) / 2
    let y = rect.origin.y + (rect.size.height - size.height) / 2
    return CGRect(x: x, y: y, width: size.width, height: size.height)
  }
}

extension CGSize {
  func fitted(in size: CGSize) -> CGSize {
    var aspectFitSize = size
    let widthRatio = size.width / width
    let heightRatio = size.height / height
    if heightRatio < widthRatio {
      aspectFitSize.width = round(heightRatio * width)
    } else if widthRatio < heightRatio {
      aspectFitSize.height = round(widthRatio * height)
    }
    return aspectFitSize
  }

  func filled(in size: CGSize) -> CGSize {
    var aspectFillSize = size
    let widthRatio = size.width / width
    let heightRatio = size.height / height
    if heightRatio > widthRatio {
      aspectFillSize.width = heightRatio * width
    } else if widthRatio > heightRatio {
      aspectFillSize.height = widthRatio * height
    }
    return aspectFillSize
  }
}

extension CGAffineTransform {
  static func transform(
    _ sourceRect: CGRect,
    fitIn targetRect: CGRect
  ) -> CGAffineTransform {
    let fitRect = sourceRect.fitted(in: targetRect)
    let xRatio = fitRect.size.width / sourceRect.size.width
    let yRatio = fitRect.size.height / sourceRect.size.height
    return CGAffineTransform(
      translationX: fitRect.origin.x - sourceRect.origin.x * xRatio,
      y: fitRect.origin.y - sourceRect.origin.y * yRatio
    )
    .scaledBy(x: xRatio, y: yRatio)
  }

  static func transform(
    _ size: CGSize,
    fitIn targetSize: CGSize
  ) -> CGAffineTransform {
    let sourceRect = CGRect(origin: .zero, size: size)
    let targetRect = CGRect(origin: .zero, size: targetSize)
    return transform(sourceRect, fitIn: targetRect)
  }

  static func transform(
    _ sourceRect: CGRect,
    fillIn targetSize: CGRect
  ) -> CGAffineTransform {
    let fillRect = sourceRect.filled(in: targetSize)
    let xRatio = fillRect.size.width / sourceRect.size.width
    let yRatio = fillRect.size.height / sourceRect.size.height
    return CGAffineTransform(
      translationX: fillRect.origin.x - sourceRect.origin.x * xRatio,
      y: fillRect.origin.y - sourceRect.origin.y * yRatio
    )
    .scaledBy(x: xRatio, y: yRatio)
  }

  static func transform(
    _ size: CGSize,
    fillIn targetSize: CGSize
  ) -> CGAffineTransform {
    let sourceRect = CGRect(origin: .zero, size: size)
    let targetRect = CGRect(origin: .zero, size: targetSize)
    return transform(sourceRect, fillIn: targetRect)
  }
}
