import Foundation
import PhotosUI
import SwiftUI

@available(iOS, deprecated: 16.0)
@available(tvOS, unavailable)
@available(macOS, deprecated: 13.0)
@available(watchOS, deprecated: 9.0)
public struct PhotosPicker<Label>: UIViewControllerRepresentable where Label: View {
  private let maxSelectionCount: Int?
  private let selection: Binding<[PhotosPickerItem]>
  private let selectionBehavior: PhotosPickerSelectionBehavior
  private let filter: PHPickerFilter?
  private let preferredItemEncoding: PhotosPickerItem.EncodingDisambiguationPolicy
  private let photoLibrary: PHPhotoLibrary
  private let label: Label

  public init(
      selection: Binding<PhotosPickerItem?>,
      matching filter: PHPickerFilter? = nil,
      preferredItemEncoding: PhotosPickerItem.EncodingDisambiguationPolicy = .automatic,
      @ViewBuilder label: () -> Label
  ) {
    self.maxSelectionCount = 1
    self.selection = Binding(
      get: { selection.wrappedValue.flatMap { [$0] } ?? [] },
      set: { value, transaction in
        selection
          .transaction(transaction)
          .wrappedValue = value.first
      }
    )
    self.selectionBehavior = .default
    self.filter = filter
    self.preferredItemEncoding = preferredItemEncoding
    self.photoLibrary = .shared()
    self.label = label()
  }

  public init(
      selection: Binding<[PhotosPickerItem]>,
      maxSelectionCount: Int? = nil,
      selectionBehavior: PhotosPickerSelectionBehavior = .default,
      matching filter: PHPickerFilter? = nil,
      preferredItemEncoding: PhotosPickerItem.EncodingDisambiguationPolicy = .automatic,
      @ViewBuilder label: () -> Label
  ) {
    self.maxSelectionCount = maxSelectionCount
    self.selection = selection
    self.selectionBehavior = selectionBehavior
    self.filter = filter
    self.preferredItemEncoding = preferredItemEncoding
    self.photoLibrary = .shared()
    self.label = label()
  }

  public init(
      selection: Binding<PhotosPickerItem?>,
      matching filter: PHPickerFilter? = nil,
      preferredItemEncoding: PhotosPickerItem.EncodingDisambiguationPolicy = .automatic,
      photoLibrary: PHPhotoLibrary,
      @ViewBuilder label: () -> Label
  ) {
    self.maxSelectionCount = 1
    self.selection = Binding(
      get: { selection.wrappedValue.flatMap { [$0] } ?? [] },
      set: { value, transaction in
        selection.transaction(transaction).wrappedValue = value.first
      }
    )
    self.selectionBehavior = .default
    self.filter = filter
    self.preferredItemEncoding = preferredItemEncoding
    self.photoLibrary = photoLibrary
    self.label = label()
  }

  public init(
      selection: Binding<[PhotosPickerItem]>,
      maxSelectionCount: Int? = nil,
      selectionBehavior: PhotosPickerSelectionBehavior = .default,
      matching filter: PHPickerFilter? = nil,
      preferredItemEncoding: PhotosPickerItem.EncodingDisambiguationPolicy = .automatic,
      photoLibrary: PHPhotoLibrary,
      @ViewBuilder label: () -> Label
  ) {
    self.maxSelectionCount = maxSelectionCount
    self.selection = selection
    self.selectionBehavior = selectionBehavior
    self.filter = filter
    self.preferredItemEncoding = preferredItemEncoding
    self.photoLibrary = photoLibrary
    self.label = label()
  }

  // MARK: - UIViewControllerRepresentable

  public func makeCoordinator() -> Coordinator {
    Coordinator(selection: selection)
  }

  public func makeUIViewController(
    context: Context
  ) -> PHPickerViewController {

    var configuration = PHPickerConfiguration(photoLibrary: .shared())
    configuration.filter = filter

    if #available(iOS 15, *) {
      configuration.selection = selectionBehavior.phPickerConfigurationSelection
    }

    configuration.preferredAssetRepresentationMode = preferredItemEncoding.phPickerConfigurationAssetRepresentationMode
    configuration.selectionLimit = maxSelectionCount ?? 0

    let controller = PHPickerViewController(configuration: configuration)
    controller.delegate = context.coordinator
    return controller
  }

  public func updateUIViewController(
    _ uiViewController: PHPickerViewController,
    context: Context
  ) {}

  // MARK: - Coordinator

  public final class Coordinator: PHPickerViewControllerDelegate {
    private var selection: Binding<[PhotosPickerItem]>

    init(selection: Binding<[PhotosPickerItem]>) {
      self.selection = selection
    }

    public func picker(
      _ picker: PHPickerViewController,
      didFinishPicking results: [PHPickerResult]
    ) {
      selection.wrappedValue = results
        .compactMap(\.assetIdentifier)
        .map(PhotosPickerItem.init(itemIdentifier:))
    }
  }
}

@available(iOS, deprecated: 16.0)
@available(tvOS, unavailable)
@available(macOS, deprecated: 13.0)
@available(watchOS, deprecated: 9.0)
public enum PhotosPickerSelectionBehavior {
  case `default`
  case ordered

  @available(iOS 15, *)
  var phPickerConfigurationSelection: PHPickerConfiguration.Selection {
    switch self {
    case .default:
      return .default
    case .ordered:
      return .ordered
    }
  }
}

extension PhotosPickerSelectionBehavior: Equatable {}

extension PhotosPickerSelectionBehavior: Hashable {}
