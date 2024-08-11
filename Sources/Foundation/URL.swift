import Foundation

#if canImport(UIKit)
import UIKit
#endif

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

  public static func mail(to email: String) -> URL? {
    URL(string: "mailto:\(email)")
  }

  #if canImport(UIKit)
  public static var settings: URL {
    URL(string: UIApplication.openSettingsURLString)!
  }
  #endif
}
