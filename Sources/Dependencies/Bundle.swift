import Dependencies
import Foundation
import Sharing

extension DependencyValues {
  public var bundle: BundleInfo {
    get { self[BundleKey.self] }
    set { self[BundleKey.self] = newValue }
  }

  private enum BundleKey: DependencyKey {
    static let liveValue = BundleInfo.main
  }
}

extension SharedReaderKey where Self == InMemoryKey<BundleInfo>.Default {
  public static var bundle: Self {
    Self[.inMemory("bundleInfo"), default: .main]
  }
}

extension BundleInfo {
  public static var main: Self {
    BundleInfo(Bundle.main)
  }
}

public struct BundleInfo {
  public var bundleDisplayName: String?
  public var bundleName: String?
  public var bundleShortVersion: String?
  public var bundleVersion: String?

  public var version: Version?

  init(_ bundle: Bundle) {
    self.bundleDisplayName = bundle.infoDictionary?["CFBundleDisplayName"] as? String
    self.bundleName = bundle.infoDictionary?["CFBundleName"] as? String
    self.bundleShortVersion = bundle.infoDictionary?["CFBundleShortVersionString"] as? String
    self.bundleVersion = bundle.infoDictionary?["CFBundleVersion"] as? String
    self.version = .init(
      [bundleShortVersion, bundleVersion]
        .compactMap { $0 }
        .joined(separator: "-")
    )
  }
}

extension BundleInfo: Equatable {}
extension BundleInfo: Hashable {}
extension BundleInfo: Sendable {}
