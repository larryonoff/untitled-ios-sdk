import SwiftUI

extension EnvironmentValues {
  private struct AssetImageContentModeKey: EnvironmentKey {
    static let defaultValue = ContentMode.fit
  }

  var assetImageContentMode: ContentMode {
    get { self[AssetImageContentModeKey.self] }
    set { self[AssetImageContentModeKey.self] = newValue }
  }
}

extension EnvironmentValues {
  private struct AssetImageTargetSizeKey: EnvironmentKey {
    static let defaultValue = PHImageManagerMaximumSize
  }

  var assetImageTargetSize: CGSize {
    get { self[AssetImageTargetSizeKey.self] }
    set { self[AssetImageTargetSizeKey.self] = newValue }
  }
}

extension View {
  public func assetImageContentMode(
    _ value: ContentMode
  ) -> some View {
    environment(\.assetImageContentMode, value)
  }

  public func assetImageTargetSize(
    _ value: CGSize
  ) -> some View {
    environment(\.assetImageTargetSize, value)
  }
}
