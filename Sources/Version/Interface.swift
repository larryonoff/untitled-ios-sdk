import Foundation

public struct VersionGenerator {
  private let generate: @Sendable () -> Version

  public init(
    _ generate: @escaping @Sendable () -> Version
  ) {
    self.generate = generate
  }

  public func callAsFunction() -> Version {
    self.generate()
  }
}

extension VersionGenerator {
  public static let live = VersionGenerator {
    let versionString = [
      Bundle.main.version,
      Bundle.main.buildVersion
    ]
    .compactMap { $0 }
    .joined(separator: "-")

    return Version(versionString) ?? Version(0, 0, 0)
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
