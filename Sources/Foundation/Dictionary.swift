import Foundation

extension Dictionary {
  @inlinable
  public func mapKeys<T>(
    _ transform: (Key) throws -> T
  ) rethrows -> [T: Value] where T: Hashable {
    var result: [T: Value] = [:]
    for (key, value) in self {
      let newKey = try transform(key)
      result[newKey] = value
    }
    return result
  }
}
