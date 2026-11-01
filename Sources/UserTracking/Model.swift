public enum AuthorizationStatus: UInt {
  case notDetermined = 0
  case restricted = 1
  case denied = 2
  case authorized = 3

  public var isAuthorized: Bool {
    self == .authorized
  }
}

extension AuthorizationStatus: Codable {}

extension AuthorizationStatus: CustomStringConvertible {
  public var description: String {
    switch self {
    case .notDetermined:
      return "notDetermined"
    case .restricted:
      return "restricted"
    case .denied:
      return "denied"
    case .authorized:
      return "authorized"
    }
  }
}

extension AuthorizationStatus: Equatable {}
extension AuthorizationStatus: Hashable {}
extension AuthorizationStatus: Sendable {}
