import Tagged

public enum PlacementTag: Sendable {}

public typealias Placement = Tagged<PlacementTag, String>
