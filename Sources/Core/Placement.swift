@_exported import Tagged

public enum PlacementTag: Sendable {}
public typealias Placement = Tagged<PlacementTag, String>

extension Placement {
  public static let didBecomeActive: Self = "did_become_active"
  public static let newSession: Self = "start_session"
}
