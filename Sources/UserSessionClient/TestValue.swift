import Foundation
import Dependencies

extension UserSessionClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension UserSessionClient {
  public static let noop = Self(
    activate: {},
    metrics: { .never },
    metricsChanges: { .finished },
    reset: {}
  )
}

extension UserSessionMetrics {
  static var never: Self {
    .init(
      date: Date(timeIntervalSince1970: 0),
      version: .zero
    )
  }
}
