extension AsyncStream {
  public init(_ element: Element) {
    self.init { continuation in
      continuation.yield(element)
      continuation.finish()
    }
  }
}
