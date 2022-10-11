import Foundation

extension VersionGenerator {
  public static let liveValue = VersionGenerator {
    let versionString = [
      Bundle.main.version,
      Bundle.main.buildVersion
    ]
    .compactMap { $0 }
    .joined(separator: "-")

    return Version(versionString) ?? .zero
  }
}
