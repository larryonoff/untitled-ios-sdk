import Dependencies
import Photos

extension PHAssetResourceManager {
  public func requestData(
    for resource: PHAssetResource,
    options: PHAssetResourceRequestOptions?
  ) async throws -> Data? {
    let requestID = LockIsolated<PHAssetResourceDataRequestID?>(nil)

    return try await withTaskCancellationHandler {
      try await withCheckedThrowingContinuation { continuation in
        var data: Data?

        requestID.setValue(
          self.requestData(for: resource, options: options) {
            data = $0
          } completionHandler: { error in
            if let error {
              continuation.resume(throwing: error)
            } else {
              continuation.resume(returning: data)
            }
          }
        )
      }
    } onCancel: {
      requestID.value.flatMap { self.cancelDataRequest($0) }
    }
  }
}
