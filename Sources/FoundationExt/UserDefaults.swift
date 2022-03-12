import Foundation

extension UserDefaults {
  public func set<Value: Encodable>(
    _ value: Value?,
    forKey key: String,
    using encoder: JSONEncoder
  ) {
    do {
      let valueString = try value
        .flatMap { try encoder.encode($0) }
        .flatMap { String(data: $0, encoding: .utf8) }
      set(valueString, forKey: key)
    } catch {
      assertionFailure("\(#function) \(error)")
    }
  }

  public func object<Value: Decodable>(
    forKey key: String,
    using decoder: JSONDecoder
  ) -> Value? {
    do {
      return try string(forKey: key)
        .flatMap { $0.data(using: .utf8) }
        .flatMap { try decoder.decode(Value.self, from: $0) }
    } catch {
      assertionFailure("\(#function) \(error)")
      return nil
    }
  }
}
