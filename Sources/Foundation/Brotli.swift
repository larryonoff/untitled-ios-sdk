import Compression
import Foundation

extension Data {
  public func brotliDecompressed() throws -> Data {
    var decompressedData = Data()
    var index = 0
    let bufferSize = count
    let pageSize = 128

    let inputFilter = try InputFilter(.decompress, using: .brotli) { length -> Data? in
      let rangeLength = Swift.min(length, bufferSize - index)
      let subdata = subdata(in: index ..< index + rangeLength)
      index += rangeLength
      return subdata
    }

    while let page = try inputFilter.readData(ofLength: pageSize) {
      decompressedData.append(page)
    }

    return decompressedData
  }
}
