#if canImport(UIKit)
import UIKit

extension UIImage {
  /// Returns normalized image for current image.
  /// This method will try to redraw an image with orientation and scale considered.
  public var normalized: UIImage {
    // prevent animated image (GIF) lose it's images
    // `UIImage` is immutable, so `self` stands in for a copy.
    guard images == nil else {
      return self
    }

    // no need to do anything if already up
    guard imageOrientation != .up else {
      return self
    }

    let format = UIGraphicsImageRendererFormat.default()
    format.opaque = true
    format.preferredRange = .standard
    format.scale = scale

    let renderer = UIGraphicsImageRenderer(size: size, format: format)

    return renderer.image { _ in
      draw(in: CGRect(origin: .zero, size: size))
    }
  }
}

#endif
