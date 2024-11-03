import Photos
import SwiftUI

extension EnvironmentValues {
  public var photosImageManager: PHImageManager {
    get { self[PhotosImageManagerKey.self] }
    set { self[PhotosImageManagerKey.self] = newValue }
  }
}

extension View {
  @inlinable nonisolated
  public func photosImageManager(
    _ imageManager: PHImageManager
  ) -> some View {
    environment(\.photosImageManager, imageManager)
  }
}

extension EnvironmentValues {
  private struct PhotosImageManagerKey: EnvironmentKey {
    static var defaultValue: PHImageManager { .default() }
  }
}
