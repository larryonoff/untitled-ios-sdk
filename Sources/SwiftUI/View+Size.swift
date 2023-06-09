import SwiftUI

extension View {
  public func onSizeChange(perform: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometry in
        Color.clear
          .preference(key: SizePreferenceChangeKey.self, value: geometry.size)
      }
    )
    .onPreferenceChange(SizePreferenceChangeKey.self, perform: perform)
  }
}

private struct SizePreferenceChangeKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
