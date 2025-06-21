extension AsyncSequence {
  func collected() async rethrows -> [Element] {
    try await reduce(into: []) {
      $0.append($1)
    }
  }
}
