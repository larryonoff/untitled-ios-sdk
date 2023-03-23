import Foundation

extension NSRecursiveLock {
  @inlinable @discardableResult
  public func sync<R>(work: () throws -> R) rethrows -> R {
    self.lock()
    defer { self.unlock() }
    return try work()
  }
}
