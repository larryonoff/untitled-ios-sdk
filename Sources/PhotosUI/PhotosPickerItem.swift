import PhotosUI
import SwiftUI

public struct _PhotosPickerItem {
  public typealias EncodingDisambiguationPolicy = PhotosPickerItem.EncodingDisambiguationPolicy

  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs.value, rhs.value) {
    case let (.pickerItem(lhs), .pickerItem(rhs)):
      lhs.itemIdentifier == rhs.itemIdentifier
    case let (.pickerResult(lhs), .pickerResult(rhs)):
      lhs.assetIdentifier == rhs.assetIdentifier
    default:
      false
    }
  }

  private enum Value: Equatable, Hashable, Sendable {
    case pickerItem(PhotosPickerItem)
    case pickerResult(PHPickerResult)
  }

  private let value: Value

  public var itemIdentifier: String? {
    switch value {
    case let .pickerItem(item): item.itemIdentifier
    case let .pickerResult(item): item.assetIdentifier
    }
  }

  public var supportedContentTypes: [UTType] {
    switch value {
    case let .pickerItem(item):
      return item.supportedContentTypes
    case let .pickerResult(item):
      return item.itemProvider.registeredContentTypes
    }
  }

  package var pickerItem: PhotosPickerItem? {
    if case let .pickerItem(item) = value {
      return item
    }
    return nil
  }

  package init(_ item: PhotosPickerItem) {
    self.value = .pickerItem(item)
  }

  package init(_ item: PHPickerResult) {
    self.value = .pickerResult(item)
  }

  @discardableResult
  @preconcurrency
  public func loadTransferable<T>(
    type: T.Type,
    completionHandler: @escaping @Sendable (Result<T?, any Error>) -> Void
  ) -> Progress where T: Transferable {
    switch value {
    case let .pickerItem(item):
      return item.loadTransferable(type: type, completionHandler: completionHandler)
    case let .pickerResult(item):
      return item.itemProvider.loadTransferable(type: type) { result in
        completionHandler(result.map(Optional.some))
      }
    }
  }

  public func loadTransferable<T>(
    type: T.Type
  ) async throws -> sending T? where T: Transferable {
    switch value {
    case let .pickerItem(item):
      return try await item.loadTransferable(type: type)
    case let .pickerResult(item):
      return try await withCheckedThrowingContinuation { continuation in
        item.itemProvider.loadTransferable(type: type) { result in
          continuation.resume(with: result.map(Optional.some))
        }
      }
    }
  }
}

extension _PhotosPickerItem: Equatable {}
extension _PhotosPickerItem: Hashable {}
extension _PhotosPickerItem: @unchecked Sendable {}

extension _PhotosPickerItem.EncodingDisambiguationPolicy {
  var phPickerConfigurationAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode {
    switch self {
    case .automatic:
      return .automatic
    case .current:
      return .current
    case .compatible:
      return .compatible
    default:
      assertionFailure()
      return .automatic
    }
  }
}
