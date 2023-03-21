import Foundation
import Dependencies

extension DependencyValues {
  public var bundle: Bundle {
    get { self[BundleKey.self] }
    set { self[BundleKey.self] = newValue }
  }

  private enum BundleKey: DependencyKey {
    static let liveValue = Bundle.main
  }
}
