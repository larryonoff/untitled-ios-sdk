import Combine

extension Publisher {
  public func first() async throws -> Output? {
    var resumed: Bool = false
    var cancellable: AnyCancellable?
    let _onCancel = {
      cancellable?.cancel()
      cancellable = nil
    }

    return try await withTaskCancellationHandler {
        _onCancel()
      }
      operation: {
        try await withCheckedThrowingContinuation { continuation in
          cancellable = sink(
            receiveCompletion: { completion in
              guard !resumed else { return }
              guard cancellable != nil else { return }

              switch completion {
              case .finished:
                continuation.resume(returning: nil)
              case let .failure(error):
                continuation.resume(throwing: error)
              }

              resumed = true
            },
            receiveValue: { value in
              guard !resumed else { return }
              continuation.resume(with: .success(value))
              resumed = true
            }
          )
        }
    }
  }
}
