import Photos
import SwiftUI

private struct PHImageManagerKey: EnvironmentKey {
  static let defaultValue = PHImageManager()
}

extension EnvironmentValues {
  public var phImageManager: PHImageManager {
    get { self[PHImageManagerKey.self] }
    set { self[PHImageManagerKey.self] = newValue }
  }
}

extension View {
  public func phImageManager(
    _ imageManager: PHImageManager
  ) -> some View {
    environment(\.phImageManager, imageManager)
  }
}
