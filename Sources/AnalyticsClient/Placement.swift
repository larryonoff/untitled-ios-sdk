import Tagged

public enum PlacementTag: Sendable {}

public typealias Placement = Tagged<PlacementTag, String>

extension Placement {
  public static let newSession: Self = "start_session"
}
