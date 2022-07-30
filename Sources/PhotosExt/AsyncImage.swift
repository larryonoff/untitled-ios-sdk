import AsyncCompatibilityKit
import SwiftUI
import Photos

public struct AsyncImage<Content>: View where Content: View {
  private let asset: PHAsset?

  @ViewBuilder
  private let content: (AsyncImagePhase) -> Content

  private let imageManager: PHImageManager

  private let targetSize: CGSize = PHImageManagerMaximumSize

  private let transaction: Transaction

  private let imageRequestOptions: PHImageRequestOptions = {
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true
    return options
  }()

  @State
  private var phase: AsyncImagePhase = .empty

  public init(
    asset: PHAsset?,
    imageManager: PHImageManager
  ) where Content == Image {
    func _content(_ phase: AsyncImagePhase) -> Content {
      switch phase {
      case .empty:
        return .empty
      case let .success(image):
        return image
      case .failure:
        return .empty
      }
    }

    self.asset = asset
    self.content = _content
    self.imageManager = imageManager
    self.transaction = Transaction()
  }

  public init<I, P>(
    asset: PHAsset?,
    imageManager: PHImageManager,
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
    self.imageManager = imageManager
    self.transaction = Transaction()
  }

  public init(
    asset: PHAsset?,
    transaction: Transaction = Transaction(),
    imageManager: PHImageManager,
    @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
  ) {
    self.asset = asset
    self.content = content
    self.imageManager = imageManager
    self.transaction = transaction
  }

  public var body: some View {
    content(phase)
      .task {
        do {
          guard let asset = asset else {
            return
          }

          let (image, _) = try await imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .default,
            options: imageRequestOptions
          )

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

@available(iOS, deprecated: 15.0)
@available(tvOS, deprecated: 15.0)
@available(macOS, deprecated: 12.0)
@available(watchOS, deprecated: 8.0)
public enum AsyncImagePhase {

    /// No image is loaded.
    case empty

    /// An image succesfully loaded.
    case success(Image)

    /// An image failed to load with an error.
    case failure(Error)

    /// The loaded image, if any.
    ///
    /// If this value isn't `nil`, the image load operation has finished,
    /// and you can use the image to update the view. You can use the image
    /// directly, or you can modify it in some way. For example, you can add
    /// a ``Image/resizable(capInsets:resizingMode:)`` modifier to make the
    /// image resizable.
    public var image: Image? {
      guard case let .success(image) = self else {
        return nil
      }
      return image
    }

    /// The error that occurred when attempting to load an image, if any.
    public var error: Error? {
      guard case let .failure(error) = self else {
        return nil
      }
      return error
    }
}

extension Image {
  static var empty: Self {
    Image(uiImage: UIImage(data: Data())!)
  }
}
