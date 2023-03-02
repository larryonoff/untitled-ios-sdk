import Dependencies

extension DependencyValues {
  public var pasteboard: PasteboardClient {
    get { self[PasteboardClient.self] }
    set { self[PasteboardClient.self] = newValue }
  }
}

public struct PasteboardClient {
  public var setString: @Sendable (String?) -> Void
}
