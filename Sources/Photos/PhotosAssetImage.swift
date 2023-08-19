import DuckGraphics
import SwiftUI
import Photos

public struct PhotosAssetImage<Content: View>: View {
  @Environment(\.displayScale) private var displayScale
  @Environment(\.photosImageManager) private var imageManager
  @Environment(\.assetImageContentMode) private var imageContentMode
  @Environment(\.assetImageTargetSize) private var imageTargetSize

  private let asset: PHAsset?

  @ViewBuilder
  private let content: (AsyncImageState) -> Content

  private let transaction: Transaction

  @State
  private var state: AsyncImageState = .init()

  private var _onStateChanged: ((AsyncImageState) -> Void)?

  public init(
    asset: PHAsset?
  ) where Content == Image {
    func _content(_ state: AsyncImageState) -> Content {
      switch state.phase {
      case .empty:
        return .empty
      case let .success(image):
        return image
      case .failure:
        return .empty
      @unknown default:
        assertionFailure("AsyncImagePhase.(@unknown default, rawValue: \(state.phase))")
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
    func _content(_ state: AsyncImageState) -> Content {
      if let image = state.phase.image {
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
    contentMode: ContentMode = .fit,
    targetSize: CGSize = PHImageManagerMaximumSize,
    transaction: Transaction = Transaction(),
    @ViewBuilder content: @escaping (AsyncImageState) -> Content
  ) {
    self.asset = asset
    self.content = content
    self.transaction = transaction
  }

  public var body: some View {
    content(state)
      .task(id: asset) {
        guard !Task.isCancelled else { return }
        guard let asset else {
          state.phase = .empty
          notifyOnChange(state)
          return
        }

        var isSucceededOnce = false

        do {
          state.isLoading = true
          notifyOnChange(state)

          for try await (image, _) in imageManager.requestImage(
            for: asset,
            targetSize: imageTargetSize * displayScale,
            contentMode: imageContentMode.phImageContentMode,
            options: imageRequestOptions
          ) {
            guard !Task.isCancelled else {
              state.isLoading = false
              notifyOnChange(state)
              return
            }

            withTransaction(transaction) {
              state.phase = image
                .flatMap(Image.init(uiImage:))
                .flatMap(AsyncImagePhase.success)
              ?? .empty
              state.isLoading = false
            }

            isSucceededOnce = true

            notifyOnChange(state)
          }
        } catch {
          guard !isSucceededOnce else { return }

          withTransaction(transaction) {
            state.phase = .failure(error)
            state.isLoading = false
          }

          notifyOnChange(state)
        }
      }
      .onDisappear {
        state.phase = .empty
      }
  }

  public func onStateChanged(
    _ action: @escaping (AsyncImageState) -> Void
  ) -> Self {
    var new = self
    new._onStateChanged = action
    return new
  }

  @MainActor
  private func notifyOnChange(
    _ state: AsyncImageState
  ) {
    _onStateChanged?(state)
  }
}

public struct AsyncImageState {
  public var phase: AsyncImagePhase = .empty

  public var isLoading: Bool = false
}

extension ContentMode {
  var phImageContentMode: PHImageContentMode {
    switch self {
    case .fit:
      return .aspectFit
    case .fill:
      return .aspectFill
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
  options.deliveryMode = .opportunistic
  options.isNetworkAccessAllowed = true
  return options
}()
