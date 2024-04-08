import Dependencies
import Foundation

extension DependencyValues {
  public var remoteSettings: RemoteSettingsClient {
    get { self[RemoteSettingsClient.self] }
    set { self[RemoteSettingsClient.self] = newValue }
  }
}

public struct RemoteSettingsClient: Sendable {
  public struct FetchRequest {
    public var activate: Bool
    public var expirationDuration: TimeInterval
  }

  public var fetch: @Sendable (FetchRequest) async throws -> Void
  public var registerDefaults: @Sendable ([String: AnyObject]) -> Void
  public var boolForKey: (String) -> Bool?
  public var dataForKey: (String) -> Data?
  public var doubleForKey: (String) -> Double?
  public var integerForKey: (String) -> Int?
  public var stringForKey: (String) -> String?
  public var dictionaryRepresentation: () -> [String: String]?
}

extension RemoteSettingsClient.FetchRequest {
  public static func request(
    activate: Bool = true,
    expirationDuration: TimeInterval = 0
  ) -> Self {
    .init(
      activate: activate,
      expirationDuration: expirationDuration
    )
  }
}

extension RemoteSettingsClient.FetchRequest: Equatable {}

extension RemoteSettingsClient.FetchRequest: Hashable {}

extension RemoteSettingsClient.FetchRequest: Sendable {}
