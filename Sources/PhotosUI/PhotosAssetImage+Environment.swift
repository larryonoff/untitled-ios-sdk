import CoreFoundation
import Photos
import SwiftUI

extension EnvironmentValues {
  public var assetImageContentMode: ContentMode {
    get { self[AssetImageContentModeKey.self] }
    set { self[AssetImageContentModeKey.self] = newValue }
  }
}

extension EnvironmentValues {
  public var assetImageTargetSize: CGSize {
    get { self[AssetImageTargetSizeKey.self] }
    set { self[AssetImageTargetSizeKey.self] = newValue }
  }
}

extension View {
  @inlinable nonisolated
  public func assetImageContentMode(
    _ value: ContentMode
  ) -> some View {
    environment(\.assetImageContentMode, value)
  }

  @inlinable nonisolated
  public func assetImageTargetSize(
    _ value: CGSize
  ) -> some View {
    environment(\.assetImageTargetSize, value)
  }
}


extension EnvironmentValues {
  private struct AssetImageContentModeKey: EnvironmentKey {
    static var defaultValue: ContentMode { .fit }
  }

  private struct AssetImageTargetSizeKey: EnvironmentKey {
    static var defaultValue: CGSize { PHImageManagerMaximumSize }
  }
}
