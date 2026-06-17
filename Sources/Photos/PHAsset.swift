import ConcurrencyExtras
import Photos
@_exported import Tagged

extension PHAsset: Identifiable {
  public typealias ID = Tagged<PHAsset, String>

  public var id: ID {
    .init(localIdentifier)
  }
}

extension PHAsset {
  public static func fetchAsset(withLocalIdentifier identifier: String) -> PHAsset? {
    let options = PHFetchOptions()
    options.fetchLimit = 1
    options.wantsIncrementalChangeDetails = false

    return PHAsset
      .fetchAssets(withLocalIdentifiers: [identifier], options: options)
      .firstObject
  }

  public func requestContentEditingInput(
    with options: PHContentEditingInputRequestOptions?
  ) async -> (PHContentEditingInput?, [AnyHashable: Any]) {
    // SAFETY: `requestID` is written once by the request call and only read by
    // the cancellation handler; PhotoKit serializes these on its own queue.
    nonisolated(unsafe) var requestID: PHContentEditingInputRequestID?

    let result = await withTaskCancellationHandler {
      await withCheckedContinuation { continuation in
        requestID = self.requestContentEditingInput(
          with: options,
          completionHandler: { contentEditingInput, info in
            // SAFETY: the result is consumed by a single awaiting caller; the
            // PhotoKit value types are not annotated `Sendable`.
            continuation.resume(returning: UncheckedSendable((contentEditingInput, info)))
          }
        )
      }
    } onCancel: {
      guard let requestID else { return }
      self.cancelContentEditingInputRequest(requestID)
    }

    return result.value
  }
}
