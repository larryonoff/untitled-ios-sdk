import AVFoundation

extension AVFoundation.AVAssetExportSession {
  public var progressStream: AsyncStream<Float> {
    // SAFETY: the export session is driven by a single export sequence; its
    // status/progress are only read here. AVAssetExportSession is not annotated
    // Sendable by AVFoundation.
    nonisolated(unsafe) let session = self

    return AsyncStream { continuation in
      let task = Task {
        do {
          var progress: Float = 0

          repeat {
            try await Task.sleep(nanoseconds: 1 * 1_000_000_00) // 0.1 seconds
            try Task.checkCancellation()

            switch session.status {
            case .exporting:
              if progress != session.progress {
                progress = session.progress
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
          } while !session.status.isFinished

          continuation.finish()
        } catch {
          continuation.finish()
        }
      }

      continuation.onTermination = { _ in task.cancel() }
    }
  }

  public func export(
    progress progressHandler: (@Sendable (Float) -> Void)?
  ) async throws {
    // SAFETY: the export session is driven by this single export sequence.
    // AVAssetExportSession is not annotated Sendable by AVFoundation.
    nonisolated(unsafe) let session = self

    try await withThrowingTaskGroup(of: Void.self) { group in
      // export task
      group.addTask {
        try Task.checkCancellation()
        await session.export()

        if let error = session.error {
          throw error
        }

        return
      }

      // progress task
      group.addTask {
        for await progress in session.progressStream {
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
