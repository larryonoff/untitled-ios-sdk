import SwiftUI

public struct NewCircularProgressViewStyle: ProgressViewStyle {
  let tint: Color

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
    }
    .frame(idealWidth: 22, idealHeight: 22)
    .onAppear {
      isRotating = true
    }
  }
}

extension ProgressViewStyle where Self == NewCircularProgressViewStyle {
  public static func newCircular(
    tint: Color
  ) -> Self {
    NewCircularProgressViewStyle(
      tint: tint
    )
  }
}
