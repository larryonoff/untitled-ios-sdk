import Photos
@_exported import Tagged

extension PHAsset: Identifiable {
  public typealias ID = Tagged<PHAsset, String>

  public var id: ID {
    .init(localIdentifier)
  }
}

extension PHAsset {
  public func requestContentEditingInput(
    with options: PHContentEditingInputRequestOptions?
  ) async -> (PHContentEditingInput?, [AnyHashable: Any]) {
    var requestID: PHContentEditingInputRequestID?

    let _onCancel = {
      guard let requestID else { return }
      self.cancelContentEditingInputRequest(requestID)
    }

    return await withTaskCancellationHandler {
      await withCheckedContinuation { continuation in
        requestID = self.requestContentEditingInput(
          with: options,
          completionHandler: { contentEditingInput, info in
            continuation.resume(returning: (contentEditingInput, info))
          }
        )
      }
    } onCancel: {
      _onCancel()
    }
  }
}
