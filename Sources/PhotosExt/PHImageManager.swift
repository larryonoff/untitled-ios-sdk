import Photos
import UIKit

extension PHImageManager {
  public func requestImage(
    for asset: PHAsset,
    targetSize: CGSize,
    contentMode: PHImageContentMode,
    options: PHImageRequestOptions?
  ) async throws -> (UIImage?, info: [AnyHashable: Any]?) {
    var imageRequestID: PHImageRequestID?
    let onCancel = { [weak self] in
      imageRequestID.flatMap { self?.cancelImageRequest($0) }
    }

    return try await withTaskCancellationHandler(
      handler: {
        onCancel()
      },
      operation: {
        try await withCheckedThrowingContinuation { continuation in
          imageRequestID = self.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: contentMode,
            options: options,
            resultHandler: { image, info in
              if let error = info?[PHImageErrorKey] as? Swift.Error {
                return continuation.resume(throwing: error)
              }
              continuation.resume(returning: (image, info))
            }
          )
        }
      }
    )
  }

  public func requestAVAsset(
    forVideo asset: PHAsset,
    options: PHVideoRequestOptions?
  ) async throws -> (AVAsset?, AVAudioMix?, [AnyHashable : Any]?) {
    var imageRequestID: PHImageRequestID?
    let onCancel = { [weak self] in
      imageRequestID.flatMap { self?.cancelImageRequest($0) }
    }

    return try await withTaskCancellationHandler(
      handler: {
        onCancel()
      },
      operation: {
        try await withCheckedThrowingContinuation { continuation in
          imageRequestID = self.requestAVAsset(
            forVideo: asset,
            options: options,
            resultHandler: { avAsset, audioMix, info in
              if let error = info?[PHImageErrorKey] as? Swift.Error {
                return continuation.resume(throwing: error)
              }
              continuation.resume(returning: (avAsset, audioMix, info))
            }
          )
        }
      }
    )
  }
}
