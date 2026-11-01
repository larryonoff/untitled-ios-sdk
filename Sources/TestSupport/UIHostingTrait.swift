import DuckConcurrency
public import Testing

/// A trait that runs each test hosting views in a window alone among the process's other such
/// tests.
///
/// `.serialized` orders only one suite's own tests, so hosting suites still ran against each other:
/// they competed for the key window and the main actor, and their run-loop waits timed out under
/// the full parallel run while passing alone. Every test case under this trait queues on one
/// process-wide lock instead, whatever suite it is in; the rest of the target stays parallel.
///
/// ```swift
/// @MainActor
/// @Suite(.uiHosting)
/// struct PickerLayoutTests { … }
/// ```
///
/// The time a test spends queued counts toward its `.timeLimit`.
public struct UIHostingTrait: SuiteTrait, TestTrait, TestScoping {
  private static let queue = AsyncQueue()

  public var isRecursive: Bool { true }

  public func scopeProvider(for test: Test, testCase: Test.Case?) -> Self? {
    // Only test cases take the lock: a suite or a whole function holding it would block the
    // cases it runs.
    testCase == nil ? nil : self
  }

  public func provideScope(
    for test: Test,
    testCase: Test.Case?,
    performing function: @Sendable () async throws -> Void
  ) async throws {
    try await Self.queue.enqueue { try await function() }
  }
}

extension Trait where Self == UIHostingTrait {
  /// Runs each test alone among the process's tests that host views in a window.
  public static var uiHosting: Self { Self() }
}
