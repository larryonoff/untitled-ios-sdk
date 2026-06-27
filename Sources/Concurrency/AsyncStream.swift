extension AsyncStream where Element: Sendable {
  public init(_ element: Element) {
    self.init { continuation in
      continuation.yield(element)
      continuation.finish()
    }
  }
}
