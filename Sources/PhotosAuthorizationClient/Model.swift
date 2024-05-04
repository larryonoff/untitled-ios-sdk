import Photos

public enum PhotosAuthorization {
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
}

extension PhotosAuthorization.AccessLevel: CustomStringConvertible {
  public var description: String {
    switch self {
    case .addOnly:
      "AccessLevel.addOnly"
    case .readWrite:
      "AccessLevel.readWrite"
    }
  }
}

extension PhotosAuthorization.AccessLevel: Equatable {}
extension PhotosAuthorization.AccessLevel: Hashable {}
extension PhotosAuthorization.AccessLevel: Sendable {}

extension PhotosAuthorization.AuthorizationStatus: CustomStringConvertible {
  public var description: String {
    switch self {
    case .authorized:
      "AuthorizationStatus.authorized"
    case .denied:
      "AuthorizationStatus.denied"
    case .notDetermined:
      "AuthorizationStatus.notDetermined"
    case .restricted:
      "AuthorizationStatus.restricted"
    case .limited:
      "AuthorizationStatus.limited"
    }
  }
}

extension PhotosAuthorization.AccessLevel {
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
    case .addOnly: .addOnly
    case .readWrite: .readWrite
    }
  }
}

extension PhotosAuthorization.AuthorizationStatus: Equatable {}
extension PhotosAuthorization.AuthorizationStatus: Hashable {}
extension PhotosAuthorization.AuthorizationStatus: Sendable {}

extension PhotosAuthorization.AuthorizationStatus {
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
