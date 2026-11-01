public import Testing

/// Polls `condition` until it holds, or fails the test once every attempt has been made.
///
/// Shaped like the `.firstPass` polling confirmation pitched for the testing library
/// (`confirmation(_:until:within:pollingEvery:sourceLocation:_:)`, swiftlang/swift-evolution#2926),
/// so adopting it is a mechanical change once it ships:
///
/// - It makes `duration / interval` attempts rather than watching a wall-clock deadline: under a
///   loaded parallel run a deadline can pass after one or two checks, before the awaited work ran.
///   Each attempt sleeps at least `interval`, so the wait lasts at least `duration`.
/// - It takes no clock. The wait outlasts delays that run on real time (the main run loop's layout
///   pass, a background task), whatever clock the code under test was given; a test clock would
///   never wake it, an immediate one would spin without letting the run loop turn.
/// - `nonisolated(nonsending)` evaluates `condition` on the caller's isolation, so one function
///   serves main-actor tests reading UIKit state and nonisolated ones.
///
/// The default `duration` only catches a hang: it is sized for the full parallel run, not a quiet
/// machine. On failure the issue is recorded at `sourceLocation` and the function throws;
/// cancelling the test ends the wait with `CancellationError`.
nonisolated(nonsending) public func waitUntil(
  _ comment: @autoclosure () -> Comment = "The condition never held while polling",
  within duration: Duration = .seconds(30),
  pollingEvery interval: Duration = .milliseconds(5),
  sourceLocation: SourceLocation = #_sourceLocation,
  _ condition: () -> Bool
) async throws {
  try #require(interval > .zero, "The polling interval must be positive", sourceLocation: sourceLocation)
  try #require(duration >= .zero, "The polling duration must not be negative", sourceLocation: sourceLocation)
  let count = try #require(
    Int(exactly: (duration / interval).rounded(.down)),
    "The requested number of polling attempts is not representable",
    sourceLocation: sourceLocation
  )
  let attempts = max(count, 1)
  for _ in 0..<attempts {
    if condition() { return }
    try await Task.sleep(for: interval)
  }
  try #require(condition(), comment(), sourceLocation: sourceLocation)
}
