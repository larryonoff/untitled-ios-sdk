import Combine
import ConcurrencyExtras
import UIKit

extension PasteboardClient {
  public static let live: Self = {
    .init(
      changes: {
        UIPasteboard.general.changes
      },
      items: {
        let pasteboard = UIPasteboard.general
        return pasteboard.items
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
      setItems: { items in
        let pasteboard = UIPasteboard.general
        pasteboard.items = items
      },
      setString: { string in
        let pasteboard = UIPasteboard.general
        pasteboard.string = string
      }
    )
  }()
}

extension UIPasteboard {
  var changes: AsyncStream<Void> {
    Publishers.Merge(
      NotificationCenter.default
        .publisher(for: UIPasteboard.changedNotification)
        .compactMap { [weak self] _ in self?.changeCount },
      NotificationCenter.default
        .publisher(for: UIApplication.didBecomeActiveNotification)
        .compactMap { [weak self] _ in self?.changeCount }
    )
    .removeDuplicates()
    .map { _ in }
    .values
    .eraseToStream()
  }
}
