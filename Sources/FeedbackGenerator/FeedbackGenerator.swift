public enum Feedback: Equatable {
  public enum ImpactType: Int {
    case light, medium, heavy

    case soft, rigid
  }

  public enum NotificationType: Int {
    case success, warning, error
  }

  case impact(ImpactType)
  case notification(NotificationType)
  case selection
}

public struct FeedbackGenerator {
  public var generate: (Feedback) -> Void
}
