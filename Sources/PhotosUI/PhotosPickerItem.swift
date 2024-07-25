import CoreServices
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

  public var supportedContentTypes: [UTType] {
    itemProvider.registeredTypeIdentifiers
      .compactMap { UTType($0) }
  }

  private let itemProvider: NSItemProvider

  init(_ result: PHPickerResult) {
    self.itemIdentifier = result.assetIdentifier
    self.itemProvider = result.itemProvider
  }

  public func loadTransferable(
    type: NSItemProviderReading.Type
  ) async throws -> NSItemProviderReading? {
    try await itemProvider.loadObject(ofClass: type)
  }

  public func loadTransferable(
    type: Data.Type
  ) async throws -> Data? {
    if itemProvider._hasItem(conformingTo: .quickTimeMovie) {
      let fileURL = try await itemProvider._loadFileRepresentation(for: .quickTimeMovie)
      return try fileURL.flatMap {
        try Data(contentsOf: $0)
      }
    }

    return nil
  }

  public func loadTransferable<T>(
    type: T.Type
  ) async throws -> T? where T: _ObjectiveCBridgeable, T._ObjectiveCType : NSItemProviderReading {
    try await itemProvider.loadObject(ofClass: type)
  }
}

extension PhotosPickerItem: Equatable {}
extension PhotosPickerItem: Hashable {}
extension PhotosPickerItem: @unchecked Sendable {}

extension PhotosPickerItem.EncodingDisambiguationPolicy: Equatable {}
extension PhotosPickerItem.EncodingDisambiguationPolicy: Hashable {}
extension PhotosPickerItem.EncodingDisambiguationPolicy: Sendable {}

extension PhotosPickerItem.EncodingDisambiguationPolicy {
  var phPickerConfigurationAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode {
    switch self {
    case .automatic: .automatic
    case .current: .current
    case .compatible: .compatible
    }
  }
}

extension NSItemProvider {
  func _hasItem(conformingTo contentType: UTType) -> Bool {
    hasItemConformingToTypeIdentifier(contentType.identifier)
  }

  func _loadFileRepresentation(for contentType: UTType) async throws -> URL? {
    try await withCheckedThrowingContinuation { continuation in
      self.loadFileRepresentation(forTypeIdentifier: contentType.identifier) { url, error in
        if let error {
          return continuation.resume(throwing: error)
        }
        continuation.resume(returning: url)
      }
    }
  }

  func loadObject(
    ofClass aClass: NSItemProviderReading.Type
  ) async throws -> NSItemProviderReading? {
    try await withCheckedThrowingContinuation { continuation in
      _ = self.loadObject(ofClass: aClass) { object, error in
        if let error {
          return continuation.resume(throwing: error)
        }
        continuation.resume(returning: object)
      }
    }
  }

  func loadObject<T>(
    ofClass aClass: T.Type
  ) async throws -> T? where T: _ObjectiveCBridgeable, T._ObjectiveCType : NSItemProviderReading {
    try await withCheckedThrowingContinuation { continuation in
      _ = self.loadObject(ofClass: aClass) { object, error in
        if let error {
          return continuation.resume(throwing: error)
        }
        continuation.resume(returning: object)
      }
    }
  }
}
