import CoreGraphics
import SwiftUI

extension CGRect {
  public func aligned(
    in bounds: CGRect,
    contentMode: ContentMode,
    alignment: Alignment
  ) -> CGRect {
    let newSize = size.aligned(
      in: bounds,
      contentMode: contentMode
    )

    let newOrigin: CGPoint

    switch alignment {
    case .center:
      newOrigin = CGPoint(
        x: (bounds.width - newSize.width) * 0.5,
        y: (bounds.height - newSize.height) * 0.5
      )
    case .leading:
      newOrigin = CGPoint(
        x: 0,
        y: (bounds.height - newSize.height) * 0.5
      )
    case .trailing:
      newOrigin = CGPoint(
        x: bounds.width,
        y: (bounds.height - newSize.height) * 0.5
      )
    case .top:
      newOrigin = CGPoint(
        x: (bounds.width - newSize.width) * 0.5,
        y: 0
      )
    case .bottom:
      newOrigin = CGPoint(
        x: (bounds.width - newSize.width) * 0.5,
        y: bounds.height
      )
    case .topLeading:
      newOrigin = CGPoint(
        x: 0,
        y: 0
      )
    case .topTrailing:
      newOrigin = CGPoint(
        x: bounds.width,
        y: 0
      )
    case .bottomLeading:
      newOrigin = CGPoint(
        x: 0,
        y: bounds.height
      )
    case .bottomTrailing:
      newOrigin = CGPoint(
        x: bounds.width,
        y: bounds.height
      )
    default:
      assertionFailure("Alignment.(default, value: \(alignment))")

      newOrigin = CGPoint(
        x: bounds.width - newSize.width * 0.5,
        y: bounds.height - newSize.height * 0.5
      )
    }

    return CGRect(
      origin: newOrigin,
      size: newSize
    )
  }

  public func scaledToFill(
    in bounds: CGRect,
    alignment: Alignment
  ) -> CGRect {
    aligned(
      in: bounds,
      contentMode: .fill,
      alignment: alignment
    )
  }

  public func scaledToFit(
    in bounds: CGRect,
    alignment: Alignment
  ) -> CGRect {
    aligned(
      in: bounds,
      contentMode: .fit,
      alignment: alignment
    )
  }
}
