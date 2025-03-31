import Dependencies

extension PasteboardClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self()
}

extension PasteboardClient {
  public static let noop = Self(
    changes: { .finished },
    items: { [[:]] },
    probableWebURL: { nil },
    setItems: { _ in },
    setString: { _ in }
  )
}
