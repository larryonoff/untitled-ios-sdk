import AsyncCompatibilityKit
import SwiftUI
import Photos

public struct AsyncImage<Content>: View where Content: View {
  private let asset: PHAsset?

  @ViewBuilder
  private let content: (AsyncImagePhase) -> Content

  @Environment(\.photosImageManager)
  private var imageManager: PHImageManager

  private let targetSize: CGSize = PHImageManagerMaximumSize

  private let transaction: Transaction

  @State
  private var phase: AsyncImagePhase = .empty

  public init(
    asset: PHAsset?
  ) where Content == Image {
    func _content(_ phase: AsyncImagePhase) -> Content {
      switch phase {
      case .empty:
        return .empty
      case let .success(image):
        return image
      case .failure:
        return .empty
      @unknown default:
        assertionFailure("AsyncImagePhase.(@unknown default, rawValue: \(phase))")
        return .empty
      }
    }

    self.asset = asset
    self.content = _content
    self.transaction = Transaction()
  }

  public init<I, P>(
    asset: PHAsset?,
    @ViewBuilder content: @escaping (Image) -> I,
    @ViewBuilder placeholder: @escaping () -> P
  ) where Content == _ConditionalContent<I, P>, I: View, P: View {
    @ViewBuilder
    func _content(_ phase: AsyncImagePhase) -> Content {
      if let image = phase.image {
        content(image)
      } else {
        placeholder()
      }
    }

    self.asset = asset
    self.content = _content
    self.transaction = Transaction()
  }

  public init(
    asset: PHAsset?,
    transaction: Transaction = Transaction(),
    @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
  ) {
    self.asset = asset
    self.content = content
    self.transaction = transaction
  }

  public var body: some View {
    content(phase)
      .task(id: asset) {
        do {
          guard !Task.isCancelled else { return }
          guard let asset = asset else { return }

          let (image, _) = try await imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .default,
            options: imageRequestOptions
          )

          guard !Task.isCancelled else { return }

          withTransaction(transaction) {
            phase = image
              .flatMap(Image.init(uiImage:))
              .flatMap(AsyncImagePhase.success)
            ?? .empty
          }
        } catch {
          withTransaction(transaction) {
            phase = .failure(error)
          }
        }
      }
  }
}

extension Image {
  static var empty: Self {
    Image(uiImage: UIImage(data: Data())!)
  }
}

private let imageRequestOptions: PHImageRequestOptions = {
  let options = PHImageRequestOptions()
  options.isNetworkAccessAllowed = true
  return options
}()
