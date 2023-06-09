import AVFoundation
import CoreGraphics
import SwiftUI

extension CGSize {
  public func aligned(
    in bounds: CGRect,
    videoGravity: AVLayerVideoGravity
  ) -> CGSize {
    guard !isEmpty else { return bounds.size }

    var alignedSize = bounds.size

    let scaleX = alignedSize.width / width
    let scaleY = alignedSize.height / height

    switch videoGravity {
    case .resizeAspectFill:
      let scale = max(scaleX, scaleY)
      alignedSize = CGSize(
        width: width * scale,
        height: height * scale
      )
    case .resizeAspect:
      let scale = min(scaleX, scaleY)
      alignedSize = CGSize(
        width: width * scale,
        height: height * scale
      )
    case .resize:
      alignedSize = CGSize(
        width: width * scaleX,
        height: height * scaleY
      )
    default:
      alignedSize = self
    }

    return alignedSize
  }

  public func aligned(
    in bounds: CGRect,
    videoAlignment: Alignment = .center,
    videoGravity: AVLayerVideoGravity
  ) -> CGRect {
    let contentSize = self.aligned(
      in: bounds,
      videoGravity: videoGravity
    )

    guard !contentSize.isEmpty else { return .zero }

    var alignedFrame = CGRect(
      origin: CGPoint(
        x: bounds.minX + (bounds.width - contentSize.width) * 0.5,
        y: bounds.minY + (bounds.height - contentSize.height) * 0.5
      ),
      size: contentSize
    )

    switch videoAlignment.horizontal {
    case .center:
      // we already in center
      break
    case .leading:
      alignedFrame.origin.x = 0
    case .trailing:
      alignedFrame.origin.x = bounds.maxX - alignedFrame.width
    default: // consider center
      break
    }

    switch videoAlignment.vertical {
    case .center:
      // we already in center
      break
    case .top:
      alignedFrame.origin.y = 0
    case .bottom:
      alignedFrame.origin.y = bounds.maxY - alignedFrame.height
    default: // consider center
      break
    }

    return alignedFrame.integral
  }
}
