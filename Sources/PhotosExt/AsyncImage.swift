import AsyncCompatibilityKit
import SwiftUI
import Photos

public struct AsyncImage<Content>: View where Content: View {
  private let asset: PHAsset?

  @ViewBuilder
  private let content: (AsyncImageState) -> Content

  @Environment(\.photosImageManager)
  private var imageManager: PHImageManager

  private let targetSize: CGSize = PHImageManagerMaximumSize

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
        do {
          guard !Task.isCancelled else { return }
          guard let asset = asset else { return }

          state.isLoading = true
          notifyOnChange(state)

          let (image, _) = try await imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .default,
            options: imageRequestOptions
          )

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

          notifyOnChange(state)
        } catch {
          withTransaction(transaction) {
            state.phase = .failure(error)
            state.isLoading = false
          }

          notifyOnChange(state)
        }
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
