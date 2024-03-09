import CoreGraphics
import CoreImage

extension CIImage {
  public func fitted(in rect: CGRect) -> CIImage {
    let transform = CGAffineTransform
      .transform(extent, fitIn: rect)
    return self
      .transformed(by: transform)
      .cropped(to: rect)
  }

  public func filled(in rect: CGRect) -> CIImage {
    let transform = CGAffineTransform
      .transform(extent, fillIn: rect)
    return self
      .transformed(by: transform)
      .cropped(to: rect)
  }

  public func fitted(in size: CGSize) -> CIImage {
    self.fitted(in: CGRect(origin: .zero, size: size))
  }

  public func filled(in size: CGSize) -> CIImage {
    self.filled(in: CGRect(origin: .zero, size: size))
  }
}
