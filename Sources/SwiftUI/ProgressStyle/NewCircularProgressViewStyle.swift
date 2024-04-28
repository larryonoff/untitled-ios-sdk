import SwiftUI

public struct NewCircularProgressViewStyle: ProgressViewStyle {
  @State
  private var isRotating: Bool = false

  public func makeBody(configuration: Configuration) -> some View {
    VStack(spacing: 8) {
      configuration.label

      Circle()
        .trim(from: 0.1, to: 0.9)
        .stroke(.tint, style: .init(lineWidth: 2, lineCap: .round))
        .rotationEffect(.degrees(isRotating ? 360 : 0))
        .animation(
          .linear(duration: 1)
          .repeatForever(autoreverses: false),
          value: isRotating
        )
    }
    .frame(idealWidth: 22, idealHeight: 22)
    .task {
      try? await Task.sleep(nanoseconds: 1_00_000_00)
      isRotating = true
    }
  }
}

extension ProgressViewStyle where Self == NewCircularProgressViewStyle {
  public static var newCircular: Self {
    NewCircularProgressViewStyle()
  }
}
