import DuckCore
import Foundation

extension UserSettingsClient {
  public func set<Value: Encodable>(
    _ value: Value?,
    forKey key: String,
    encoder: JSONEncoder
  ) async throws {
    let data = try value.flatMap {
      try encoder.encode($0)
    }
    await setData(data, key)
  }

  public func valueForKey<Value: Decodable>(
    _ key: String,
    decoder: JSONDecoder
  ) throws -> Value? {
    try dataForKey(key).flatMap {
      try decoder.decode(Value.self, from: $0)
    }
  }

  public func setOnboardingCompleted(
    _ newValue: Bool
  ) async {
    await setBool(newValue, .isOnboardingCompletedKey)
  }

  public var isOnboardingCompleted: Bool {
    boolForKey(.isOnboardingCompletedKey)
  }
}

