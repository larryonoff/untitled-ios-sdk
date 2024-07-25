import AVFoundation

extension AVFoundation.AVAssetExportSession {
  public var progressStream: AsyncStream<Float> {
    AsyncStream { continuation in
      let task = Task {
        do {
          var progress: Float = 0

          repeat {
            try await Task.sleep(nanoseconds: 1 * 1_000_000_00) // 0.1 seconds
            try Task.checkCancellation()

            switch self.status {
            case .exporting:
              if progress != self.progress {
                progress = self.progress
                continuation.yield(progress)
              }
            case .completed:
              continuation.yield(1)
            case .cancelled, .failed:
              return continuation.finish()
            default:
              continue
            }

            await Task.yield()
          } while !self.status.isFinished

          continuation.finish()
        } catch {
          continuation.finish()
        }
      }

      continuation.onTermination = { _ in task.cancel() }
    }
  }

  public func export(
    progress progressHandler: ((Float) -> Void)?
  ) async throws {
    try await withThrowingTaskGroup(of: Void.self) { group in
      // export task
      group.addTask {
        try Task.checkCancellation()
        await self.export()

        if let error = self.error {
          throw error
        }

        return
      }

      // progress task
      group.addTask {
        for await progress in self.progressStream {
          progressHandler?(progress)
        }
      }

      try await group.next()
    }
  }
}

extension AVAssetExportSession.Status {
  public var isFinished: Bool {
    switch self {
    case .exporting, .waiting, .unknown: false
    default: true
    }
  }
}
