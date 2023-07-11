import Photos

extension PHAssetResourceManager {
  public func requestData(
    for resource: PHAssetResource,
    options: PHAssetResourceRequestOptions?
  ) async throws -> Data? {
    var requestID: PHAssetResourceDataRequestID?

    let _onCancel = {
      guard let requestID else { return }
      self.cancelDataRequest(requestID)
    }

    return try await withTaskCancellationHandler {
      try await withCheckedThrowingContinuation { continuation in
        var data: Data?

        requestID = self.requestData(
          for: resource,
          options: options,
          dataReceivedHandler: { _data in
            data = _data
          },
          completionHandler: { error in
            if let error {
              continuation.resume(throwing: error)
            } else {
              continuation.resume(returning: data)
            }
          }
        )
      }
    } onCancel: {
      _onCancel()
    }
  }
}
