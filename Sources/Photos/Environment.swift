import Photos
import SwiftUI

extension EnvironmentValues {
  public var photosImageManager: PHImageManager {
    get { self[PhotosImageManagerKey.self] }
    set { self[PhotosImageManagerKey.self] = newValue }
  }

  private struct PhotosImageManagerKey: EnvironmentKey {
    static let defaultValue = PHImageManager()
  }
}

extension View {
  public func photosImageManager(
    _ imageManager: PHImageManager
  ) -> some View {
    environment(\.photosImageManager, imageManager)
  }
}
