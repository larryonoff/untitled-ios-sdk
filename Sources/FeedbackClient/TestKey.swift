import Dependencies
import IssueReporting

extension FeedbackGenerator: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
    unimplemented("\(Self.self).generate")
  )
}

extension FeedbackGenerator {
  public static let noop = Self { _ in }
}
