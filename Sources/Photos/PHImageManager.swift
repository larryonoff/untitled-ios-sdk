import ConcurrencyExtras
import Dependencies
import Photos
import UIKit

extension DependencyValues {
  public var phImageManager: PHImageManager {
    get { self[PHImageManagerKey.self] }
    set { self[PHImageManagerKey.self] = newValue }
  }
}

private enum PHImageManagerKey: DependencyKey {
  static let liveValue = PHImageManager.default()
  static let testValue = PHImageManager.default()
}

extension PHImageManager {
  public func requestImage(
    for asset: PHAsset,
    targetSize: CGSize,
    contentMode: PHImageContentMode,
    options: PHImageRequestOptions?
  ) -> AsyncThrowingStream<(UIImage?, info: [AnyHashable: Any]?), any Error> {
    // SAFETY: PhotoKit confines the request to its own queue; the options value
    // is not annotated `Sendable` by Photos.
    nonisolated(unsafe) let options = options

    return AsyncThrowingStream { continuation in
      let requestID = requestImage(
        for: asset,
        targetSize: targetSize,
        contentMode: contentMode,
        options: options,
        resultHandler: { image, info in
          let resultInfo = info.flatMap(PHImageRequestResultInfo.init)

          if let error = resultInfo?.error {
            return continuation.finish(throwing: error)
          }

          if resultInfo?.isCancelled == true {
            return continuation.finish(throwing: CancellationError())
          }

          // SAFETY: PhotoKit delivers the result on its own queue and the value
          // is handed to a single stream consumer; the value types are not
          // annotated `Sendable` by Photos.
          nonisolated(unsafe) let value = (image, info)
          continuation.yield(value)

          // when degraded image is provided,
          // the completion handler will be called again.
          if resultInfo?.isDegraded == nil || resultInfo?.isDegraded == false {
            continuation.finish()
          }
        }
      )

      continuation.onTermination = { [weak self] _ in
        self?.cancelImageRequest(requestID)
      }
    }
  }

  public func requestImage(
    for asset: PHAsset,
    targetSize: CGSize,
    contentMode: PHImageContentMode,
    options: PHImageRequestOptions?
  ) async throws -> (UIImage?, info: [AnyHashable: Any]?) {
    let requestID = LockIsolated<PHImageRequestID?>(nil)
    // SAFETY: PhotoKit confines the request to its own queue; the options value
    // is not annotated `Sendable` by Photos.
    nonisolated(unsafe) let options = options

    let result = try await withTaskCancellationHandler {
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<UncheckedSendable<(UIImage?, [AnyHashable: Any]?)>, any Error>) in
        requestID.setValue(
          requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: contentMode,
            options: options,
            resultHandler: { image, info in
              let resultInfo = info.flatMap(PHImageRequestResultInfo.init)

              if let error = resultInfo?.error {
                return continuation.resume(throwing: error)
              }

              if resultInfo?.isCancelled == true {
                return continuation.resume(throwing: CancellationError())
              }

              // when degraded image is provided,
              // the completion handler will be called again.
              if resultInfo?.isDegraded == true {
                return
              }

              // SAFETY: the result is consumed by a single awaiting caller; the
              // PhotoKit value types are not annotated `Sendable`.
              continuation.resume(returning: UncheckedSendable((image, info)))
            }
          )
        )
      }
    } onCancel: {
      requestID.value.flatMap { self.cancelImageRequest($0) }
    }

    return result.value
  }

  public func requestAVAsset(
    forVideo asset: PHAsset,
    options: PHVideoRequestOptions?
  ) async throws -> (AVAsset?, AVAudioMix?, [AnyHashable : Any]?) {
    let requestID = LockIsolated<PHImageRequestID?>(nil)
    // SAFETY: PhotoKit confines the request to its own queue; the options value
    // is not annotated `Sendable` by Photos.
    nonisolated(unsafe) let options = options

    let result = try await withTaskCancellationHandler {
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<UncheckedSendable<(AVAsset?, AVAudioMix?, [AnyHashable: Any]?)>, any Error>) in
        requestID.setValue(
          requestAVAsset(
            forVideo: asset,
            options: options,
            resultHandler: { avAsset, audioMix, info in
              let resultInfo = info.flatMap(PHImageRequestResultInfo.init)

              if let error = resultInfo?.error {
                return continuation.resume(throwing: error)
              }

              if resultInfo?.isCancelled == true {
                return continuation.resume(throwing: CancellationError())
              }

              // when degraded image is provided,
              // the completion handler will be called again.
              if resultInfo?.isDegraded == true {
                return
              }

              // SAFETY: the result is consumed by a single awaiting caller; the
              // PhotoKit value types are not annotated `Sendable`.
              continuation.resume(returning: UncheckedSendable((avAsset, audioMix, info)))
            }
          )
        )
      }
    } onCancel: {
      requestID.value.flatMap { self.cancelImageRequest($0) }
    }

    return result.value
  }
}

public struct PHImageRequestResultInfo {
  /// An error that occurred when Photos attempted to load the image.
  public let error: (any Error)?

  /// Whether the image request was canceled.
  public let isCancelled: Bool?

  /// Whether the result image is a low-quality substitute for the requested image.
  public let isDegraded: Bool?

  /// Whether photo asset data is stored on the local device or must be downloaded from iCloud.
  public let isInCloud: Bool?

  /// A unique identifier for the image request.
  public let requestID: PHImageRequestID?

  public init(_ info: [AnyHashable: Any]) {
    self.error = info[PHImageErrorKey] as? any Swift.Error
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
