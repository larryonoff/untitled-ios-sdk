import Combine
import Foundation

public enum TaskResult<Success> {
  case success(Success)
  case failure(Error)

  public init(catching body: () async throws -> Success) async {
    do {
      self = .success(try await body())
    } catch {
      self = .failure(error)
    }
  }
}

extension TaskResult: Sendable where Success: Sendable {}

public typealias TaskFailure = TaskResult<Never>

extension TaskResult: Equatable where Success: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case let (.success(lhs), .success(rhs)):
      return lhs == rhs
    case let (.failure(lhs), .failure(rhs)):
      return _isEqual(lhs, rhs) ?? ((lhs as NSError) == (rhs as NSError))
    default:
      return false
    }
  }
}

extension TaskResult: Hashable where Success: Hashable {
  public func hash(into hasher: inout Hasher) {
    switch self {
    case let .success(success):
      hasher.combine(success)
    case let .failure(failure):
      if !_hash(failure, into: &hasher) {
        hasher.combine(failure as NSError)
      }
    }
  }
}

private enum _Witness<A> {}

private protocol _AnyEquatable {
  static func _isEqual(_ lhs: Any, _ rhs: Any) -> Bool
}
private protocol _AnyHashable: _AnyEquatable {
  static func _hash(_ value: Any, into hasher: inout Hasher) -> Bool
}

extension _Witness: _AnyEquatable where A: Equatable {
  static func _isEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    guard
      let lhs = lhs as? A,
      let rhs = rhs as? A
    else { return false }
    return lhs == rhs
  }
}

extension _Witness: _AnyHashable where A: Hashable {
  static func _hash(_ value: Any, into hasher: inout Hasher) -> Bool {
    guard let value = value as? A
    else { return false }
    hasher.combine(value)
    return true
  }
}

private func _isEqual(_ a: Any, _ b: Any) -> Bool? {
  func `do`<A>(_: A.Type) -> Bool? {
    (_Witness<A>.self as? _AnyEquatable.Type)?._isEqual(a, b)
  }
  return _openExistential(type(of: a), do: `do`)
}

private func _hash(_ value: Any, into hasher: inout Hasher) -> Bool {
  func `do`<A>(_: A.Type) -> Bool {
    guard let hashable = (_Witness<A>.self as? _AnyHashable.Type)
    else { return false }
    return hashable._hash(value, into: &hasher)
  }
  return _openExistential(type(of: value), do: `do`)
}

extension Publisher {
  /// Transform a publisher with concrete Output and Failure types
  /// to a new publisher that wraps Output and Failure in Result,
  /// and has Never for Failure type
  /// - Returns: A type-erased publiser of type <Result<Output, Failure>, Never>
  public func mapToTaskResult() -> AnyPublisher<TaskResult<Output>, Never> {
    map(TaskResult.success)
      .catch { Just(.failure($0)) }
      .eraseToAnyPublisher()
  }
}
