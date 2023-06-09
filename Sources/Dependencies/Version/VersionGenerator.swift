import Dependencies
import Foundation
import XCTestDynamicOverlay

extension DependencyValues {
  public var version: VersionGenerator {
    get { self[VersionGeneratorKey.self] }
    set { self[VersionGeneratorKey.self] = newValue }
  }

  private enum VersionGeneratorKey: DependencyKey {
    static let liveValue = VersionGenerator {
      let versionString = [
        Bundle.main.version,
        Bundle.main.buildVersion
      ]
      .compactMap { $0 }
      .joined(separator: "-")

      return Version(versionString) ?? .zero
    }

    static let testValue = VersionGenerator {
      XCTFail(#"Unimplemented: @Dependency(\.version)"#)
      return .zero
    }
  }
}

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

extension Bundle {
  var buildVersion: String? {
    object(forInfoDictionaryKey: "CFBundleVersion") as? String
  }

  var version: String? {
    object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
  }
}
