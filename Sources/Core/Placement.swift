@_exported import Tagged

public enum PlacementTag: Sendable {}
public typealias Placement = Tagged<PlacementTag, String>

extension Placement {
  public static var newSession: Self { "start_session" }
  public static var sceneDidBecomeActive: Self { "scene_become_active" }
}
