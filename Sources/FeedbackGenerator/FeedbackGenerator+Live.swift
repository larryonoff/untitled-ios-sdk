#if canImport(UIKit)
import UIKit

extension FeedbackGenerator {
  public static var live: Self {
    Self(
      generate: { feedback in
        switch feedback {
        case let .impact(style):
          let generator = UIImpactFeedbackGenerator(style: style.toUIKit())
          generator.prepare()
          generator.impactOccurred()
        case let .notification(type):
          let generator = UINotificationFeedbackGenerator()
          generator.prepare()
          generator.notificationOccurred(type.toUIKit())
        case .selection:
          let generator = UISelectionFeedbackGenerator()
          generator.prepare()
          generator.selectionChanged()
        }
      }
    )
  }
}

// MARK: - UIKit values

extension Feedback.ImpactType {
  func toUIKit() -> UIImpactFeedbackGenerator.FeedbackStyle {
    UIImpactFeedbackGenerator.FeedbackStyle(rawValue: rawValue)!
  }
}

extension Feedback.NotificationType {
  func toUIKit() -> UINotificationFeedbackGenerator.FeedbackType {
    UINotificationFeedbackGenerator.FeedbackType(rawValue: rawValue)!
  }
}

#endif