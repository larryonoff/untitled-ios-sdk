import Dependencies
import XCTestDynamicOverlay

extension DependencyValues {
  public var feedback: FeedbackGenerator {
    get { self[FeedbackGeneratorKey.self] }
    set { self[FeedbackGeneratorKey.self] = newValue }
  }

  private enum FeedbackGeneratorKey: DependencyKey {
    static let liveValue = FeedbackGenerator.liveValue

    static let previewValue = FeedbackGenerator { _ in }

    static let testValue = FeedbackGenerator(
      unimplemented("\(Self.self).generate")
    )
  }
}

public struct FeedbackGenerator {
  private var generate: @Sendable (Feedback) async -> Void

  public init(_ generate: @escaping @Sendable (Feedback) async -> Void) {
    self.generate = generate
  }

  public func callAsFunction(_ feedback: Feedback) async {
    await self.generate(feedback)
  }
}

public enum Feedback {
  public enum ImpactType: Int {
    case light
    case medium
    case heavy

    case soft
    case rigid
  }

  public enum NotificationType: Int {
    case success
    case warning
    case error
  }

  case impact(ImpactType)
  case notification(NotificationType)
  case selection
}

extension Feedback: Equatable {}

extension Feedback: Hashable {}

extension Feedback: Sendable {}

extension Feedback.ImpactType: Equatable {}

extension Feedback.ImpactType: Hashable {}

extension Feedback.ImpactType: Sendable {}

extension Feedback.NotificationType: Equatable {}

extension Feedback.NotificationType: Hashable {}

extension Feedback.NotificationType: Sendable {}
