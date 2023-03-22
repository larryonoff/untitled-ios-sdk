import Dependencies
import XCTestDynamicOverlay

extension AppsFlyerClient: TestDependencyKey {
  public static var previewValue = Self.noop

  public static let testValue = AppsFlyerClient(
    initialize: unimplemented("\(Self.self).initialize"),
    appContinueUserActivity: unimplemented("\(Self.self).applicationContinueUserActivity"),
    appOpenURL: unimplemented("\(Self.self).applicationOpenURL"),
    applicationID: unimplemented("\(Self.self).applicationID", placeholder: nil),
    logEvent: unimplemented("\(Self.self).logEvent")
  )
}

extension AppsFlyerClient {
  public static let noop = AppsFlyerClient(
    initialize: { _ in },
    appContinueUserActivity: { _, _ in },
    appOpenURL: { _, _ in },
    applicationID: { nil },
    logEvent: { _ in }
  )
}
