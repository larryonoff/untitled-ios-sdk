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

extension TaskResult: Equatable where Success: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case let (.success(lhs), .success(rhs)):
      return lhs == rhs
    case let (.failure(lhs as NSError), .failure(rhs as NSError)):
      return lhs == rhs
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
      hasher.combine(failure as NSError)
    }
  }
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
