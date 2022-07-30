import Photos
import PhotosUI

@available(iOS, deprecated: 16.0)
@available(tvOS, unavailable)
@available(macOS, deprecated: 13.0)
@available(watchOS, deprecated: 9.0)
public struct PhotosPickerItem {
  public enum EncodingDisambiguationPolicy {
    case automatic
    case current
    case compatible
  }

  public var itemIdentifier: String?

  public init(itemIdentifier: String) {
    self.itemIdentifier = itemIdentifier
  }
}

extension PhotosPickerItem: Equatable {}

extension PhotosPickerItem: Sendable {}

extension PhotosPickerItem: Hashable {}

extension PhotosPickerItem.EncodingDisambiguationPolicy: Equatable {}

extension PhotosPickerItem.EncodingDisambiguationPolicy: Sendable {}

extension PhotosPickerItem.EncodingDisambiguationPolicy: Hashable {}

extension PhotosPickerItem.EncodingDisambiguationPolicy {
  var phPickerConfigurationAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode {
    switch self {
    case .automatic:
      return .automatic
    case .current:
      return .current
    case .compatible:
      return .compatible
    }
  }
}
