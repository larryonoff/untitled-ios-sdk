import Foundation

public struct OpenURL {
  public let open: (URL) async -> Bool

  public init(open: @escaping (URL) async -> Bool) {
    self.open = open
  }
}
