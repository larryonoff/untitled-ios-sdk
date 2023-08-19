import DuckGraphics
import SwiftUI

extension View {
  @MainActor
  public func snapshot(
    afterScreenUpdates afterUpdates: Bool = true,
    scale: CGFloat = 1
  ) -> UIImage {
    let controller = UIHostingController(
      rootView: self
        .ignoresSafeArea()
        .fixedSize(horizontal: true, vertical: true)
        .scaleEffect(scale)
    )

    let view = controller.view

    let targetRect = CGRect(
      origin: .zero,
      size: controller.view.intrinsicContentSize * scale
    )
    .integral

    view?.frame = targetRect
    view?.backgroundColor = .clear

    let format = UIGraphicsImageRendererFormat()

    let renderer = UIGraphicsImageRenderer(
      size: targetRect.size,
      format: format
    )

    return renderer.image { _ in
      view?.drawHierarchy(
        in: targetRect,
        afterScreenUpdates: afterUpdates
      )
    }
  }
}
