import Dependencies
import DependenciesMacros
import Foundation

extension DependencyValues {
  public var pasteboard: PasteboardClient {
    get { self[PasteboardClient.self] }
    set { self[PasteboardClient.self] = newValue }
  }
}

@DependencyClient
public struct PasteboardClient: Sendable {
  public var changes: @Sendable () -> AsyncStream<Void> = { .finished }

  public var items: @Sendable () async throws -> [[String: Any]]?
  public var probableWebURL: @Sendable () async throws -> URL?

  public var setItems: @Sendable ([[String: Any]]) -> Void
  public var setString: @Sendable (String?) -> Void
}
