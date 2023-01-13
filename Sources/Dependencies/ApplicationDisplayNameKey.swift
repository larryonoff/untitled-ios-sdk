import Foundation
import Dependencies

extension DependencyValues {
  public var applicationDisplayName: String {
    get { self[ApplicationDisplayNameKey.self] }
    set { self[ApplicationDisplayNameKey.self] = newValue }
  }

  private enum ApplicationDisplayNameKey: DependencyKey {
    static let liveValue = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
  }
}
