import Combine

extension Publisher {
  /// The first element of the publisher, or `nil` if it completes without emitting one.
  ///
  /// Cancellation is handled by the underlying `AsyncThrowingPublisher`, which
  /// tears down its subscription when the awaiting task is cancelled.
  public func first() async throws -> Output? {
    for try await output in values {
      return output
    }
    return nil
  }
}
