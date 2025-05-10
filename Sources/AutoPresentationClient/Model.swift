@_exported import Tagged

public enum AutoPresentation {
  public enum EventTag: Sendable {}
  public typealias Event = Tagged<EventTag, String>

  public enum FeatureTag: Sendable {}
  public typealias Feature = Tagged<FeatureTag, String>

  public enum UserInfoKeyTag: Sendable {}
  public typealias UserInfoKey = Tagged<FeatureTag, String>

  public typealias UserInfo = [UserInfoKey: Any]
}

extension AutoPresentation.Event {
  public static var newSession: Self { "start_session" }
  public static var sceneDidBecomeActive: Self { "scene_become_active" }
}
