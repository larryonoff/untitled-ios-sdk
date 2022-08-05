import CoreGraphics
import Foundation
import SwiftUI

extension CGSize {
  public func aligned(
    in bounds: CGRect,
    contentMode: ContentMode
  ) -> CGSize {
    guard !isEmpty else { return bounds.size }

    var alignedSize = bounds.size

    let scaleX = alignedSize.width / width
    let scaleY = alignedSize.height / height

    switch contentMode {
    case .fill:
      let scale = max(scaleX, scaleY)
      alignedSize = CGSize(
        width: width * scale,
        height: height * scale
      )
    case .fit:
      let scale = min(scaleX, scaleY)
      alignedSize = CGSize(
        width: width * scale,
        height: height * scale
      )
    }

    return alignedSize
  }

  public func scaledToFill(
    in bounds: CGRect
  ) -> CGSize {
    aligned(in: bounds, contentMode: .fill)
  }

  public func scaledToFit(
    in bounds: CGRect
  ) -> CGSize {
    aligned(in: bounds, contentMode: .fit)
  }

  @inlinable
  public var isEmpty: Bool {
      height.isZero || width.isZero
  }
}
