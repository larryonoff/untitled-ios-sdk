import Compression
import Foundation

extension Data {
  public func brotliDecompressed() throws -> Data {
    // iOS <16.0 doesn't have symbol `Algorithm.brotli`
    // so we use legacy till iOS 16 minimum

    return _legacyBrotliDecompressed()

//    var decompressedData = Data()
//    var index = 0
//    let bufferSize = count
//    let pageSize = 128
//
//    let inputFilter = try InputFilter(.decompress, using: .brotli) { length -> Data? in
//      let rangeLength = Swift.min(length, bufferSize - index)
//      let subdata = subdata(in: index ..< index + rangeLength)
//      index += rangeLength
//      return subdata
//    }
//
//    while let page = try inputFilter.readData(ofLength: pageSize) {
//      decompressedData.append(page)
//    }
//
//    return decompressedData
  }

  @available(iOS, deprecated: 16.0, message: "Use the commented code, instead.")
  private func _legacyBrotliDecompressed() -> Data {
    let decodedBufferLength = 8_000_000 // 8Mb
    let decodedBuffer = UnsafeMutablePointer<UInt8>.allocate(
      capacity: decodedBufferLength
    )

    let result = withUnsafeBytes { frameBuffer -> Data in
      guard
        let frameBytes = frameBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self)
      else {
        return .init()
      }

      let decodedCharCount = compression_decode_buffer(
        decodedBuffer,
        decodedBufferLength,
        frameBytes,
        count,
        nil,
        COMPRESSION_BROTLI
      )

      return Data(bytes: decodedBuffer, count: decodedCharCount)
    }

    decodedBuffer.deallocate()

    return result
  }
}
