import SwiftUI

public struct NewCircularProgressViewStyle: ProgressViewStyle {
  private let tint: Color

  init(tint: Color) {
    self.tint = tint
  }

  @State
  private var isRotating: Bool = false

  public func makeBody(configuration: Configuration) -> some View {
    VStack(spacing: 8) {
      configuration.label

      Circle()
        .trim(from: 0.1, to: 0.9)
        .stroke(tint, style: .init(lineWidth: 2, lineCap: .round))
        .rotationEffect(.degrees(isRotating ? 360 : 0))
        .animation(
          .linear(duration: 1)
          .repeatForever(autoreverses: false),
          value: isRotating
        )
        .frame(width: 28, height: 28)
    }
    .onAppear {
      isRotating = true
    }
  }
}

extension ProgressViewStyle where Self == NewCircularProgressViewStyle {
  public static func newCicrular(tint: Color) -> Self {
    NewCircularProgressViewStyle(tint: tint)
  }
}
