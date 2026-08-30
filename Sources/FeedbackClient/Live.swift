import Dependencies

#if canImport(UIKit)
import UIKit
#endif

extension FeedbackGenerator: DependencyKey {
#if canImport(UIKit)
  public static let liveValue = Self { feedback in
    switch feedback {
    case let .impact(style):
      let generator = await UIImpactFeedbackGenerator(style: style.toUIKit())
      await generator.prepare()
      await generator.impactOccurred()
    case let .notification(type):
      let generator = await UINotificationFeedbackGenerator()
      await generator.prepare()
      await generator.notificationOccurred(type.toUIKit())
    case .selection:
      let generator = await UISelectionFeedbackGenerator()
      await generator.prepare()
      await generator.selectionChanged()
    }
  }
#else
  // No haptics outside UIKit.
  public static let liveValue = Self.noop
#endif
}

#if canImport(UIKit)

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
