import Foundation

extension BidirectionalCollection {
  @inlinable
  public func next(
    after predicate: (Element) throws -> Bool,
    loop: Bool = false
  ) rethrows -> Element? {
    guard let idx = try firstIndex(where: predicate) else {
      return nil
    }

    let nextIdx = index(after: idx)

    if nextIdx < endIndex {
      return self[nextIdx]
    }

    return loop ? first : nil
  }

  @inlinable
  public func next(
    before predicate: ((Element) throws -> Bool),
    loop: Bool = false
  ) rethrows -> Element? {
    guard let idx = try firstIndex(where: predicate) else {
      return nil
    }

    guard idx > startIndex else {
      return loop ? last : nil
    }

    let nextIdx = index(before: idx)

    if nextIdx >= startIndex {
      return self[nextIdx]
    }

    return loop ? last : nil
  }
}

extension BidirectionalCollection where Element: Equatable {
  public func next(
    after element: (Element),
    loop: Bool = false
  ) -> Element? {
    next(after: { $0 == element })
  }

  public func next(
    before element: (Element),
    loop: Bool = false
  ) -> Element? {
    next(before: { $0 == element })
  }
}
