import SwiftUI

public struct RectCorner: OptionSet {
  public let rawValue: UInt

  public init(rawValue: UInt) {
    self.rawValue = rawValue
  }

  public static let topLeft = RectCorner(rawValue: 1 << 0)
  public static let topRight = RectCorner(rawValue: 1 << 1)
  public static let bottomLeft = RectCorner(rawValue: 1 << 2)
  public static let bottomRight = RectCorner(rawValue: 1 << 3)

  public static let top: Self = [.topLeft, .topRight]
  public static let bottom: Self = [.bottomLeft, .bottomRight]
  public static let left: Self = [.topLeft, .bottomLeft]
  public static let right: Self = [.topRight, .bottomRight]
  
  public static let allCorners: Self = [
    .topLeft,
    .topRight,
    .bottomLeft,
    .bottomRight
  ]
}

extension View {
  public func cornerRadius(
    _ cornerRadius: CGFloat,
    corners: RectCorner
  ) -> some View {
    modifier(
      CornerRadiusModifier(
        cornerRadius: cornerRadius,
        corners: corners
      )
    )
  }
}

private struct CornerRadiusModifier: ViewModifier {
  private struct CornerRadiusShape: Shape {
    private let cornerRadius: CGFloat
    private let corners: RectCorner

    init(
      cornerRadius: CGFloat,
      corners: RectCorner = .allCorners
    ) {
      self.cornerRadius = cornerRadius
      self.corners = corners
    }

    // MARK: - Shape

    func path(in rect: CGRect) -> Path {
      let path = UIBezierPath(
        roundedRect: rect,
        byRoundingCorners: .corner(corners),
        cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
      )
      return Path(path.cgPath)
    }
  }

  private let cornerRadius: CGFloat
  private let corners: RectCorner

  init(
    cornerRadius: CGFloat,
    corners: RectCorner
  ) {
    self.cornerRadius = cornerRadius
    self.corners = corners
  }

  // MARK: - ViewModifier

  func body(content: Content) -> some View {
    if !corners.isEmpty {
      content
        .clipShape(
          CornerRadiusShape(
            cornerRadius: cornerRadius,
            corners: corners
          )
        )
    } else {
      content
    }
  }
}

private extension UIRectCorner {
  static func corner(_ corners: RectCorner) -> Self {
    var _corners = UIRectCorner()

    if corners.contains(.topLeft) {
      _corners.insert(.topLeft)
    }
    if corners.contains(.topRight) {
      _corners.insert(.topRight)
    }
    if corners.contains(.bottomLeft) {
      _corners.insert(.bottomLeft)
    }
    if corners.contains(.bottomRight) {
      _corners.insert(.bottomRight)
    }
    return _corners
  }
}
