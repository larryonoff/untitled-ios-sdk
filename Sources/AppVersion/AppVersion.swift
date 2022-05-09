import Foundation

public struct AppVersion: Equatable, Hashable {
  public static let live: Self = {
    let bundle = Bundle.main

    return AppVersion(
      version: bundle.version ?? "",
      buildVersion: bundle.buildVersion
    )
  }()

  public let version: String
  public let buildVersion: String?
}

// MARK: - CustomStringConvertible

extension AppVersion: CustomStringConvertible {
  public var description: String {
    return [
      version,
      buildVersion
        .flatMap { "(\($0))" }
    ].compactMap { $0 }
     .joined(separator: " ")
  }
}

// MARK: - Bundle

extension Bundle {
  var buildVersion: String? {
    object(forInfoDictionaryKey: "CFBundleVersion") as? String
  }

  var version: String? {
    object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
  }
}
