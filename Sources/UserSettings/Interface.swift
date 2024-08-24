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
  public var boolForKey: @Sendable (_ forKey: String) -> Bool = { _ in false }
  public var dataForKey: @Sendable (_ forKey: String) -> Data?
  public var doubleForKey: @Sendable (_ forKey: String) -> Double = { _ in 0 }
  public var integerForKey: @Sendable (_ forKey: String) -> Int = { _ in 0 }

  public var removeValueForKey: @Sendable (_ forKey: String) async -> Void
  public var setBool: @Sendable (_ _: Bool, _ forKey: String) async -> Void
  public var setData: @Sendable (_ _: Data?, _ forKey: String) async -> Void
  public var setDouble: @Sendable (_ _: Double, _ forKey: String) async -> Void
  public var setInteger: @Sendable (_ _: Int, _ forKey: String) async -> Void
}
