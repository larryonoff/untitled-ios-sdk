import Foundation

extension FileManager {
  public func createDirectoryIfNotExist(
    at url: URL,
    withIntermediateDirectories createIntermediates: Bool,
    attributes: [FileAttributeKey : Any]? = nil
  ) throws {
    guard !fileExists(atPath: url.path) else { return }

    try createDirectory(
      at: url,
      withIntermediateDirectories: true
    )
  }

  public func removeItemIfExist(at url: URL) throws {
    guard fileExists(atPath: url.path) else { return }
    try removeItem(at: url)
  }
}
