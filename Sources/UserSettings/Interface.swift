import Dependencies
import DependenciesMacros
import Foundation

extension DependencyValues {
  public var userSettings: UserSettingsClient {
    get { self[UserSettingsClient.self] }
    set { self[UserSettingsClient.self] = newValue }
  }
}

@DependencyClient
public struct UserSettingsClient: Sendable {
  @DependencyEndpoint(method: "bool")
  public var boolForKey: @Sendable (_ forKey: String) -> Bool = { _ in false }

  @DependencyEndpoint(method: "data")
  public var dataForKey: @Sendable (_ forKey: String) -> Data?

  @DependencyEndpoint(method: "double")
  public var doubleForKey: @Sendable (_ forKey: String) -> Double = { _ in 0 }

  @DependencyEndpoint(method: "integer")
  public var integerForKey: @Sendable (_ forKey: String) -> Int = { _ in 0 }

  @DependencyEndpoint(method: "object")
  public var objectForKey: @Sendable (_ forKey: String) -> Any?

  @DependencyEndpoint(method: "removeValue")
  public var removeValueForKey: @Sendable (_ forKey: String) async -> Void

  public var setBool: @Sendable (_ _: Bool, _ forKey: String) async -> Void
  public var setData: @Sendable (_ _: Data?, _ forKey: String) async -> Void
  public var setDouble: @Sendable (_ _: Double, _ forKey: String) async -> Void
  public var setInteger: @Sendable (_ _: Int, _ forKey: String) async -> Void
  public var setObject: @Sendable (_ _: Any?, _ forKey: String) async -> Void
}
