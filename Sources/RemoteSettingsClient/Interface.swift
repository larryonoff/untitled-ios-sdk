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
  public var boolForKey: @Sendable (String) -> Bool?
  public var dataForKey: @Sendable (String) -> Data?
  public var doubleForKey: @Sendable (String) -> Double?
  public var integerForKey: @Sendable (String) -> Int?
  public var stringForKey: @Sendable (String) -> String?
  public var dictionaryRepresentation: @Sendable () -> [String: String]?
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
