import Photos

public enum AccessLevel: UInt {
  case addOnly
  case readWrite
}

public enum AuthorizationStatus: UInt {
  case notDetermined = 0
  case restricted
  case denied
  case authorized
  case limited
}

extension AccessLevel: CustomStringConvertible {
  public var description: String {
    switch self {
    case .addOnly:
      return "AccessLevel.addOnly"
    case .readWrite:
      return "AccessLevel.readWrite"
    }
  }
}

extension AccessLevel: Equatable {}

extension AccessLevel: Hashable {}

extension AccessLevel: Sendable {}

extension AuthorizationStatus: CustomStringConvertible {
  public var description: String {
    switch self {
    case .authorized:
      return "AuthorizationStatus.authorized"
    case .denied:
      return "AuthorizationStatus.denied"
    case .notDetermined:
      return "AuthorizationStatus.notDetermined"
    case .restricted:
      return "AuthorizationStatus.restricted"
    case .limited:
      return "AuthorizationStatus.limited"
    }
  }
}

extension AccessLevel {
  init(_ acl: PHAccessLevel) {
    switch acl {
    case .addOnly:
      self = .addOnly
    case .readWrite:
      self = .readWrite
    @unknown default:
      assertionFailure("PHAccessLevel.(@unknown default, rawValue: \(acl.rawValue))")
      self = .readWrite
    }
  }

  var phAccessLevel: PHAccessLevel {
    switch self {
    case .addOnly:
      return .addOnly
    case .readWrite:
      return .readWrite
    }
  }
}

extension AuthorizationStatus: Equatable {}

extension AuthorizationStatus: Hashable {}

extension AuthorizationStatus: Sendable {}

extension AuthorizationStatus {
  init(_ status: PHAuthorizationStatus) {
    switch status {
    case .notDetermined:
      self = .notDetermined
    case .restricted:
      self = .restricted
    case .denied:
      self = .denied
    case .authorized:
      self = .authorized
    case .limited:
      self = .limited
    @unknown default:
      assertionFailure("PHAuthorizationStatus.(@unknown default, rawValue: \(status.rawValue))")
      self = .notDetermined
    }
  }

  public var isAuthorizedOrLimited: Bool {
    self == .authorized || self == .limited
  }

  public var isLimited: Bool {
    self == .limited
  }
}
