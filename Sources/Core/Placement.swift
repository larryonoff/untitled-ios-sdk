@_exported import Tagged

public enum PlacementTag: Sendable {}
public typealias Placement = Tagged<PlacementTag, String>

extension Placement {
  public static let newSession: Self = "start_session"
  public static let sceneDidBecomeActive: Self = "scene_become_active"
}
