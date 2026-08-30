import Foundation
import IssueReporting

extension AVURLAsset {
  public static func custom(url: URL) -> AVURLAsset {
    let asset = AVCustomURLAsset(url: url, options: nil)

    asset.resourceLoaderDelegate =
      AVAssetCustomURLResourceLoader(url: url)
    // Serial, not `.global()`: the delegate answers each request by seeking the
    // shared file handle and then reading from it, which is only correct if one
    // request is served at a time. AVFoundation issues loading requests
    // concurrently — that is the point of `isByteRangeAccessSupported` — so on a
    // concurrent queue two seeks can interleave and a request gets bytes from
    // another's offset.
    asset.resourceLoader.setDelegate(
      asset.resourceLoaderDelegate!,
      queue: DispatchQueue(label: "AVAssetCustomURLResourceLoader")
    )

    return asset
  }
}

// SAFETY: `resourceLoaderDelegate` is assigned once in `custom(url:)` before the
// asset escapes, then only read; AVURLAsset itself is `@unchecked Sendable`.
private final class AVCustomURLAsset: AVURLAsset, @unchecked Sendable {
  nonisolated(unsafe) var resourceLoaderDelegate: AVAssetCustomURLResourceLoader?
}

private final class AVAssetCustomURLResourceLoader: NSObject, @unchecked Sendable {
  private let url: URL

  init(url: URL) {
    self.url = url
  }

  // SAFETY: only touched from the serial queue the delegate is registered on,
  // which serializes every callback that opens, seeks or reads it.
  private var fileHandle: FileHandle?

  deinit {
    try? fileHandle?.close()
  }
}

// MARK: - AVAssetResourceLoaderDelegate

extension AVAssetCustomURLResourceLoader: AVAssetResourceLoaderDelegate {
  func resourceLoader(
    _ resourceLoader: AVAssetResourceLoader,
    shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
  ) -> Bool {
    do {
      guard let url = loadingRequest.request.url else {
        loadingRequest.finishLoading()
        return false
      }

      if fileHandle == nil {
        self.fileHandle = try FileHandle(forReadingFrom: url)
      }

      guard let fileHandle = fileHandle else {
        reportIssue("No file handle available for \(url)")
        loadingRequest.finishLoading()
        return false
      }

      if let contentInformationRequest = loadingRequest.contentInformationRequest {
        contentInformationRequest.contentLength = Int64(try fileHandle.fileSize())
        contentInformationRequest.isByteRangeAccessSupported = true
      }

      if let dataRequest = loadingRequest.dataRequest {
        try fileHandle.seek(toOffset: UInt64(dataRequest.requestedOffset))

        if dataRequest.requestsAllDataToEndOfResource {
          let data = try fileHandle.readToEnd()
          dataRequest.respond(with: data ?? Data())
        } else {
          let data = try fileHandle.read(upToCount: dataRequest.requestedLength)
          dataRequest.respond(with: data ?? Data())
        }
      }

      loadingRequest.finishLoading()

      return true
    } catch {
      loadingRequest.finishLoading(with: error)
      return false
    }
  }

  func resourceLoader(
    _ resourceLoader: AVAssetResourceLoader,
    didCancel loadingRequest: AVAssetResourceLoadingRequest
  ) {
    try? fileHandle?.close()
  }
}

extension FileHandle {
  internal func fileSize(
    retryOnInterrupt: Bool = true
  ) throws -> UInt64 {
    let current = try offset()
    let size = try seekToEnd()
    try seek(toOffset: current)
    return size
  }
}
