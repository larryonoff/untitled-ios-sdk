public struct Connectivity {
  /// The availability of a network path, mirroring `NWPath.Status`.
  public enum Status {
    /// The path is available to establish connections.
    case satisfied

    /// The path is not available for use.
    case unsatisfied

    /// The path is not currently available, but establishing a new connection may activate it.
    case requiresConnection

    /// A Boolean value indicating whether the path is available to establish connections.
    public var isSatisfied: Bool {
      self == .satisfied
    }
  }

  public var status: Status

  /// A Boolean value indicating whether the path is available to establish connections.
  public var isSatisfied: Bool {
    status.isSatisfied
  }

  public init(status: Status = .requiresConnection) {
    self.status = status
  }
}

extension Connectivity: Codable {}
extension Connectivity: Equatable {}
extension Connectivity: Hashable {}
extension Connectivity: Sendable {}

extension Connectivity.Status: CustomStringConvertible {
  public var description: String {
    switch self {
    case .satisfied:
      "Satisfied"
    case .unsatisfied:
      "Unsatisfied"
    case .requiresConnection:
      "Requires connection"
    }
  }
}

extension Connectivity.Status: CaseIterable {}
extension Connectivity.Status: Codable {}
extension Connectivity.Status: Equatable {}
extension Connectivity.Status: Hashable {}
extension Connectivity.Status: Sendable {}
