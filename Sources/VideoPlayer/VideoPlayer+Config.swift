public enum VideoDisappearBehavior: Equatable, Hashable, Sendable {
  case reset
  case pause

  public static var `default`: Self { .reset }
}

public enum VideoPauseBehavior: Equatable, Hashable, Sendable {
  case reset
  case pause

  public static var `default`: Self { .reset }
}
