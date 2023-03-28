import UIKit

extension PasteboardClient {
  public static let live: Self = {
    .init(
      changes: {
        AsyncStream { continuation in
          Task {
            await withTaskGroup(of: Int.self) { group in
              group.addTask {
                let changed = NotificationCenter.default
                  .notifications(named: UIPasteboard.changedNotification)

                for await _ in changed {
                  return UIPasteboard.general.changeCount
                }

                return -1
              }

              group.addTask {
                let didBecomeActive = NotificationCenter.default
                  .notifications(
                    named: await UIApplication.didBecomeActiveNotification
                  )

                for await _ in didBecomeActive {
                  return UIPasteboard.general.changeCount
                }

                return -1
              }

              var changeCount: Int?

              for await newChangeCount in group {
                if changeCount != newChangeCount {
                  changeCount = newChangeCount

                  if let changeCount, changeCount > 0 {
                    continuation.yield(())
                  }
                }
              }
            }
          }
        }
      },
      probableWebURL: { () -> URL? in
        do {
          let pasteboard = UIPasteboard.general

          guard pasteboard.hasURLs else {
            return nil
          }

          let detectedPatterns = try await pasteboard
            .detectedPatterns(for: [\.probableWebURL])

          guard detectedPatterns.contains(\.probableWebURL) else {
            return nil
          }

          return pasteboard.url
        } catch {
          throw error
        }
      },
      setString: { string in
        let pasteboard = UIPasteboard.general
        pasteboard.string = string
      }
    )
  }()
}
