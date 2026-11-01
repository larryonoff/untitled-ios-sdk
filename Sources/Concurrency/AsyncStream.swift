extension AsyncStream {
  public init(_ element: sending Element) {
    let (stream, continuation) = Self.makeStream(of: Element.self)
    continuation.yield(element)
    continuation.finish()
    self = stream
  }
}
