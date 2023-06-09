import Foundation

public final class AVCustomURLAsset: AVURLAsset {
  private var resourceLoaderDelegate: AVAssetCustomURLResourceLoader?

  public init(url: URL) {
    super.init(url: url, options: nil)

    self.resourceLoaderDelegate =
      AVAssetCustomURLResourceLoader(url: url)
    resourceLoader.setDelegate(
      resourceLoaderDelegate!,
      queue: .global()
    )
  }
}

private final class AVAssetCustomURLResourceLoader: NSObject {
  private let url: URL

  init(url: URL) {
    self.url = url
  }

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
        assertionFailure()
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
