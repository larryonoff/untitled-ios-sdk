import SwiftUI

/// An indeterminate spinner: an open ring in the `tint`, sized by `controlSize`, with the
/// `ProgressView`'s label above it.
///
/// ```swift
/// ProgressView()
///   .progressViewStyle(.newCircular)
///   .controlSize(.mini)
/// ```
public struct NewCircularProgressViewStyle: ProgressViewStyle {
  public func makeBody(configuration: Configuration) -> some View {
    VStack(spacing: 8) {
      configuration.label
      Spinner()
    }
  }
}

extension ProgressViewStyle where Self == NewCircularProgressViewStyle {
  public static var newCircular: Self {
    NewCircularProgressViewStyle()
  }
}

/// A view of its own, not state on the style: `@State` lives only in a `View`.
private struct Spinner: View {
  @Environment(\.controlSize) private var controlSize

  @State private var isRotating = false

  var body: some View {
    Circle()
      .trim(from: 0.1, to: 0.9)
      .stroke(.tint, style: StrokeStyle(lineWidth: 2, lineCap: .round))
      // Scoped to the rotation: an animation over the view would also carry its first layout,
      // flying the ring in from the corner of an appearing overlay.
      .animation(.linear(duration: 1).repeatForever(autoreverses: false)) {
        $0.rotationEffect(.degrees(isRotating ? 360 : 0))
      }
      // A cap, not just an ideal: an ideal applies only under a nil proposal, so in an overlay or
      // a notice the ring would fill what it's offered. A smaller frame still shrinks it.
      .frame(idealWidth: diameter, maxWidth: diameter, idealHeight: diameter, maxHeight: diameter)
      .onAppear { isRotating = true }
  }

  private var diameter: CGFloat {
    switch controlSize {
    case .mini: 16
    case .small: 20
    case .large, .extraLarge: 44
    // `.regular`, and any size added later.
    default: 22
    }
  }
}
