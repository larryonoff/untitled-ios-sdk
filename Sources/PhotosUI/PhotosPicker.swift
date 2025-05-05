import Foundation
import PhotosUI
import SwiftUI

@available(iOS, deprecated: 16.0)
@available(tvOS, unavailable)
@available(macOS, deprecated: 13.0)
@available(watchOS, deprecated: 9.0)
public struct PhotosPicker<Label>: View where Label: View {
  private let maxSelectionCount: Int?
  private let selection: Binding<[_PhotosPickerItem]>
  private let selectionBehavior: PhotosPickerSelectionBehavior
  private let filter: PHPickerFilter?
  private let preferredItemEncoding: PhotosPickerItem.EncodingDisambiguationPolicy
  private let photoLibrary: PHPhotoLibrary
  private let label: Label

  public init(
    selection: Binding<_PhotosPickerItem?>,
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
    selection: Binding<[_PhotosPickerItem]>,
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
    selection: Binding<_PhotosPickerItem?>,
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
    selection: Binding<[_PhotosPickerItem]>,
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

  public var body: some View {
    PhotosPickerRepresentable(
      selection: selection,
      maxSelectionCount: maxSelectionCount,
      selectionBehavior: selectionBehavior,
      matching: filter,
      preferredItemEncoding: preferredItemEncoding,
      photoLibrary: photoLibrary,
      label: label
    )
    .edgesIgnoringSafeArea(.all)
  }
}

private struct PhotosPickerRepresentable<Label>: UIViewControllerRepresentable where Label: View {
  let maxSelectionCount: Int?
  let selection: Binding<[_PhotosPickerItem]>
  let selectionBehavior: PhotosPickerSelectionBehavior
  let filter: PHPickerFilter?
  let preferredItemEncoding: PhotosPickerItem.EncodingDisambiguationPolicy
  let photoLibrary: PHPhotoLibrary
  let label: Label

  init(
    selection: Binding<[_PhotosPickerItem]>,
    maxSelectionCount: Int? = nil,
    selectionBehavior: PhotosPickerSelectionBehavior = .default,
    matching filter: PHPickerFilter? = nil,
    preferredItemEncoding: PhotosPickerItem.EncodingDisambiguationPolicy = .automatic,
    photoLibrary: PHPhotoLibrary,
    label: Label
  ) {
    self.maxSelectionCount = maxSelectionCount
    self.selection = selection
    self.selectionBehavior = selectionBehavior
    self.filter = filter
    self.preferredItemEncoding = preferredItemEncoding
    self.photoLibrary = photoLibrary
    self.label = label
  }

  // MARK: - UIViewControllerRepresentable

  func makeCoordinator() -> Coordinator {
    Coordinator(selection: selection)
  }

  func makeUIViewController(
    context: Context
  ) -> PHPickerViewController {
    var configuration = PHPickerConfiguration(photoLibrary: photoLibrary)

    configuration.filter = filter

    configuration.preferredAssetRepresentationMode =
      preferredItemEncoding.phPickerConfigurationAssetRepresentationMode

    if let maxSelectionCount, maxSelectionCount > 1 {
      configuration.preselectedAssetIdentifiers =
        selection.wrappedValue.compactMap(\.itemIdentifier)
    }

    configuration.selection = selectionBehavior.phPickerConfigurationSelection
    configuration.selectionLimit = maxSelectionCount ?? 0

    let controller = PHPickerViewController(configuration: configuration)
    controller.delegate = context.coordinator

    context.coordinator.maxSelectionCount = maxSelectionCount
    context.coordinator.photosPickerStyle = context.environment._photosPickerStyle

    return controller
  }

  func updateUIViewController(
    _ uiViewController: PHPickerViewController,
    context: Context
  ) {}

  // MARK: - Coordinator

  final class Coordinator: PHPickerViewControllerDelegate {
    var selection: Binding<[_PhotosPickerItem]>
    var maxSelectionCount: Int? = 0
    var photosPickerStyle: _PhotosPickerStyle = .presentation

    init(selection: Binding<[_PhotosPickerItem]>) {
      self.selection = selection
    }

    func picker(
      _ picker: PHPickerViewController,
      didFinishPicking results: [PHPickerResult]
    ) {
      selection.wrappedValue = results
        .map(_PhotosPickerItem.init)

      if photosPickerStyle == .inline, maxSelectionCount == 1 {
        picker.dismiss(animated: true)
      }
    }
  }
}

package enum _PhotosPickerStyle: Equatable, Hashable, Sendable {
  case presentation
  case inline
}

package extension EnvironmentValues {
  @Entry var _photosPickerStyle: _PhotosPickerStyle = .presentation
}

extension View {
  nonisolated package func _photosPickerStyle(_ style: _PhotosPickerStyle) -> some View {
    environment(\._photosPickerStyle, style)
  }
}

private extension PhotosPickerSelectionBehavior {
  var phPickerConfigurationSelection: PHPickerConfiguration.Selection {
    switch self {
    case .default:
      return .default
    case .ordered:
      return .ordered
    default:
      assertionFailure()
      return .default
    }
  }
}
