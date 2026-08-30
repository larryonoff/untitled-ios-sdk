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
          // PhotoKit streams the resource: the handler is called once per chunk
          // and the caller is the one that joins them. Assigning would keep only
          // the last chunk, which still completes without an error — a silently
          // truncated resource rather than a failed request.
          self.requestData(for: resource, options: options) { chunk in
            data.withValue { $0 = ($0 ?? Data()) + chunk }
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
