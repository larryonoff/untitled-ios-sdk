import Dependencies
import Foundation

extension DependencyValues {
  public var userSettings: UserSettingsClient {
    get { self[UserSettingsClient.self] }
    set { self[UserSettingsClient.self] = newValue }
  }
}

public struct UserSettingsClient: Sendable {
  public var boolForKey: (String) -> Bool
  public var dataForKey: (String) -> Data?
  public var doubleForKey: (String) -> Double
  public var integerForKey: (String) -> Int
  public var remove: (String) async -> Void
  public var setBool: (Bool, String) async -> Void
  public var setData: (Data?, String) async -> Void
  public var setDouble: (Double, String) async -> Void
  public var setInteger: (Int, String) async -> Void
}

extension UserSettingsClient {
  public func setEncodable<Value: Encodable>(
    _ value: Value?,
    forKey key: String,
    using encoder: JSONEncoder
  ) async throws {
    let valueData = try value
      .flatMap { try encoder.encode($0) }
    await setData(valueData, key)
  }

  public func decodableForKey<Value: Decodable>(
    _ key: String,
    using decoder: JSONDecoder
  ) throws -> Value? {
    try dataForKey(key)
      .flatMap { try decoder.decode(Value.self, from: $0) }
  }

  public func setOnboardingCompleted(
    _ newValue: Bool
  ) async {
    await setBool(newValue, .isOnboardingCompleted)
  }

  public var isOnboardingCompleted: Bool {
    boolForKey(.isOnboardingCompleted)
  }
}

extension String {
  static let isOnboardingCompleted = "onboarding-completed"
}
