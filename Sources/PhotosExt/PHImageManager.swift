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
              let resultInfo = info.flatMap(PHImageRequestResultInfo.init)

              if let error = resultInfo?.error {
                return continuation.resume(throwing: error)
              }

              if
                let isCancelled = resultInfo?.isCancelled,
                isCancelled
              {
                return continuation.resume(throwing: CancellationError())
              }

              // when degraded image is provided,
              // the completion handler will be called again.
              if
                let isDegraded = resultInfo?.isDegraded,
                isDegraded
              {
                return
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
              let resultInfo = info.flatMap(PHImageRequestResultInfo.init)

              if let error = resultInfo?.error {
                return continuation.resume(throwing: error)
              }

              if
                let isCancelled = resultInfo?.isCancelled,
                isCancelled
              {
                return continuation.resume(throwing: CancellationError())
              }

              // when degraded image is provided,
              // the completion handler will be called again.
              if
                let isDegraded = resultInfo?.isDegraded,
                isDegraded
              {
                return
              }

              continuation.resume(returning: (avAsset, audioMix, info))
            }
          )
        }
      }
    )
  }
}

public struct PHImageRequestResultInfo {
  /// An error that occurred when Photos attempted to load the image.
  public let error: Error?

  /// Whether the image request was canceled.
  public let isCancelled: Bool?

  /// Whether the result image is a low-quality substitute for the requested image.
  public let isDegraded: Bool?

  /// Whether photo asset data is stored on the local device or must be downloaded from iCloud.
  public let isInCloud: Bool?

  /// A unique identifier for the image request.
  public let requestID: PHImageRequestID?

  public init(_ info: [AnyHashable: Any]) {
    self.error = info[PHImageErrorKey] as? Swift.Error
    self.isCancelled = info[PHImageCancelledKey] as? Bool
    self.isDegraded = info[PHImageResultIsDegradedKey] as? Bool
    self.isInCloud = info[PHImageResultIsInCloudKey] as? Bool
    self.requestID = info[PHImageResultRequestIDKey] as? PHImageRequestID
  }
}

extension PHImageRequestResultInfo: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    (lhs.error as? NSError) == (rhs.error as? NSError) &&
    lhs.isCancelled == rhs.isCancelled &&
    lhs.isDegraded == rhs.isDegraded &&
    lhs.isInCloud == rhs.isInCloud &&
    lhs.requestID == rhs.requestID
  }
}

extension PHImageRequestResultInfo: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.error as? NSError)
    hasher.combine(self.isCancelled)
    hasher.combine(self.isDegraded)
    hasher.combine(self.isInCloud)
    hasher.combine(self.requestID)
  }
}


extension PHImageRequestResultInfo: Sendable {}
