import Foundation

#if canImport(UIKit)
import UIKit
#endif

extension URL {
  @discardableResult
  public func ensureDirectoryExists() throws -> Bool {
    guard isFileURL else { return false }

    let directoryURL: URL = hasDirectoryPath ? self : self.deletingLastPathComponent()

    var isDir: ObjCBool = false
    if
      FileManager.default.fileExists(
        atPath: directoryURL.path,
        isDirectory: &isDir
      ),
      isDir.boolValue
    {
      return true
    }

    try FileManager.default.createDirectory(
      at: directoryURL,
      withIntermediateDirectories: true
    )

    return true
  }

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

  public static func mail(to email: String) -> URL? {
    URL(string: "mailto:\(email)")
  }

  #if canImport(UIKit)
  public static var settings: URL {
    URL(string: UIApplication.openSettingsURLString)!
  }
  #endif
}
