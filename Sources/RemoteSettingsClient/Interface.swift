import Dependencies
import DependenciesMacros
import Foundation

extension DependencyValues {
  public var remoteSettings: RemoteSettingsClient {
    get { self[RemoteSettingsClient.self] }
    set { self[RemoteSettingsClient.self] = newValue }
  }
}

@DependencyClient
public struct RemoteSettingsClient: Sendable {
  public struct FetchRequest {
    public var activate: Bool
    public var expirationDuration: TimeInterval
  }

  public var fetch: @Sendable (_ _: FetchRequest) async throws -> Void
  public var registerDefaults: @Sendable (_ _: [String: AnyObject]) -> Void

  @DependencyEndpoint(method: "bool")
  public var boolForKey: @Sendable (_ forKey: String) -> Bool?

  @DependencyEndpoint(method: "data")
  public var dataForKey: @Sendable (_ forKey: String) -> Data?

  @DependencyEndpoint(method: "double")
  public var doubleForKey: @Sendable (_ forKey: String) -> Double?

  @DependencyEndpoint(method: "integer")
  public var integerForKey: @Sendable (_ forKey: String) -> Int?

  @DependencyEndpoint(method: "string")
  public var stringForKey: @Sendable (_ forKey: String) -> String?

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
