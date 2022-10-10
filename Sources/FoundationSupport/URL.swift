import Foundation

extension URL {
  public var creationDate: Date? {
    guard let values = try? resourceValues(forKeys: [.creationDateKey]) else {
      return nil
    }
    return values.creationDate
  }

  public var isDirectory: Bool? {
    guard let values = try? resourceValues(forKeys: [.isDirectoryKey]) else {
      return nil
    }
    return values.isDirectory
  }
}
