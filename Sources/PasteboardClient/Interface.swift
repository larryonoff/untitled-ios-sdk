import Dependencies
import Foundation

extension DependencyValues {
  public var pasteboard: PasteboardClient {
    get { self[PasteboardClient.self] }
    set { self[PasteboardClient.self] = newValue }
  }
}

public struct PasteboardClient {
  public var changes: @Sendable () -> AsyncStream<Void>
  public var probableWebURL: @Sendable () async throws -> URL?
  public var setString: @Sendable (String?) -> Void
}
