import Foundation
import Dependencies

extension DependencyValues {
  public var bundle: BundleInfo {
    get { self[BundleKey.self] }
    set { self[BundleKey.self] = newValue }
  }

  private enum BundleKey: DependencyKey {
    static let liveValue = BundleInfo(Bundle.main)
  }
}

public struct BundleInfo {
  public var bundleName: String?
  public var bundleShortVersion: String?
  public var bundleVersion: String?

  init(_ bundle: Bundle) {
    self.bundleName = bundle.infoDictionary?["CFBundleName"] as? String
    self.bundleShortVersion = bundle.infoDictionary?["CFBundleShortVersionString"] as? String
    self.bundleVersion = bundle.infoDictionary?["CFBundleVersion"] as? String
  }
}

extension BundleInfo: Equatable {}

extension BundleInfo: Hashable {}

extension BundleInfo: Sendable {}
