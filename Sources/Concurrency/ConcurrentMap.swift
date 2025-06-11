import Foundation

extension Sequence where Element: Sendable {
  @inlinable
  public func concurrentMap<T: Sendable>(
    maximumParallelism: Int = ProcessInfo.processInfo.activeProcessorCount,
    _ body: @Sendable @escaping (Element) async throws -> T
  ) async rethrows -> [T] {
    let actualParallelism = Swift.max(1, maximumParallelism)

    nonisolated(unsafe) var results: [T?] = []
    nonisolated(unsafe) var started = 0
    nonisolated(unsafe) var completed = 0

    try await withThrowingTaskGroup(of: (Int, T).self) { group in
      nonisolated(unsafe) var index = 0

      for element in self {
        // Expand the results array with initial value nil
        // which will be later be replaced with the final value
        results.append(nil)

        defer {
          index += 1
        }

        group.addTask { [index] in
          let transformedElement = try await body(element)
          return (index, transformedElement)
        }

        started += 1

        if started - completed >= actualParallelism {
          if let (resultIndex, transformedElement) = try await group.next() {
            assert(results[resultIndex] == nil)
            results[resultIndex] = transformedElement
            completed += 1
          }
        }
      }

      while let (resultIndex, transformedElement) = try await group.next() {
        assert(results[resultIndex] == nil)
        results[resultIndex] = transformedElement
      }
    }

    assert(results.allSatisfy { $0 != nil })
    return results.compactMap { $0 }
  }
}
