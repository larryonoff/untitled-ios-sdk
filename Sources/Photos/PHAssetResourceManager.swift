import ConcurrencyExtras
import Dependencies
import Photos

extension PHAssetResourceManager {
  public func requestData(
    for resource: PHAssetResource,
    options: PHAssetResourceRequestOptions?
  ) async throws -> Data? {
    let requestID = LockIsolated<PHAssetResourceDataRequestID?>(nil)
    // SAFETY: PhotoKit confines the request to its own queue; these values are
    // not annotated `Sendable` by Photos.
    nonisolated(unsafe) let resource = resource
    nonisolated(unsafe) let options = options

    return try await withTaskCancellationHandler {
      try await withCheckedThrowingContinuation { continuation in
        let data = LockIsolated<Data?>(nil)

        requestID.setValue(
          self.requestData(for: resource, options: options) { chunk in
            data.setValue(chunk)
          } completionHandler: { error in
            if let error {
              continuation.resume(throwing: error)
            } else {
              continuation.resume(returning: data.value)
            }
          }
        )
      }
    } onCancel: {
      requestID.value.flatMap { self.cancelDataRequest($0) }
    }
  }
}
