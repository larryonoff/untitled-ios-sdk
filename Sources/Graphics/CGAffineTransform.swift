import CoreGraphics

extension CGAffineTransform {
  public struct _Components {
    /// initial scaling in X and Y dimensions. {sx,sy}
    /// Negative values indicate the image has been flipped in this dimension.
    public var scale: CGSize

    /// Shear distortion (sh). Turns rectangles to parallelograms. 0 for no shear. Typically 0.
    public var horizontalShear: CGFloat

    /// Rotation angle in radians about the origin. (t) Sign convention for clockwise rotation
    /// may differ between various Apple frameworks based on origin placement. Please see discussion.
    public var rotation: CGFloat

    /// Displacement from the origin (ty, ty)
    public var translation: CGVector
  }

  public var components: _Components {
    .init(
      scale: scale,
      horizontalShear: horizontalShear,
      rotation: rotationInRadians,
      translation: translation
    )
  }

  /// The horizontal shear component (`c`) of the transform matrix.
  /// Note: This value is influenced by rotation and scaling. It represents pure horizontal shear
  /// only if no rotation or y-scaling is applied. There is no setter as modifying shear
  /// independently without affecting scale/rotation is complex.
  @inlinable @inline(__always)
  public var horizontalShear: CGFloat {
    get { c }
    // No setter provided due to complexity of isolating shear modification.
  }

  /// The scale component of the transform. Always returns positive values.
  /// Assumes no shear. Setting the scale reconstructs the transform using the current rotation and translation.
  @inlinable @inline(__always)
  public var scale: CGSize {
    get {
      .init(
        width: sqrt(pow(a, 2) + pow(c, 2)),
        height: sqrt(pow(b, 2) + pow(d, 2))
      )
    }
    set {
      let currentRotation = self.rotationInRadians
      let currentTranslation = self.translation

      self = .identity
        .translatedBy(x: currentTranslation.dx, y: currentTranslation.dy)
        .scaledBy(x: newValue.width, y: newValue.height)
        .rotated(by: currentRotation)
    }
  }

  /// The translation component of the transform.
  @inlinable @inline(__always)
  public var translation: CGVector {
    get { .init(dx: tx, dy: ty) }
    set {
      tx = newValue.dx
      ty = newValue.dy
    }
  }

  /// The rotation component (in radians) of the transform.
  /// Assumes no shear and positive scale. Calculation might be inaccurate otherwise.
  /// Setting the rotation reconstructs the transform using the current scale and translation.
  @inlinable @inline(__always)
  public var rotationInRadians: CGFloat {
    get { atan2(b, a) }
    set {

      let currentScale = self.scale
      let currentTranslation = self.translation

      self = .identity
        .translatedBy(x: currentTranslation.dx, y: currentTranslation.dy)
        .scaledBy(x: currentScale.width, y: currentScale.height)
        .rotated(by: newValue)
    }
  }
}

#if canImport(SwiftUI)

import SwiftUI

extension CGAffineTransform {
  @inlinable @inline(__always)
  public var angle: Angle {
    get { .init(radians: rotationInRadians) }
    set { self.rotationInRadians = newValue.radians }
  }

  @inlinable @inline(__always)
  public func angle(_ newValue: Angle) -> Self {
    var new = self
    new.angle = newValue
    return new
  }
}

#endif
