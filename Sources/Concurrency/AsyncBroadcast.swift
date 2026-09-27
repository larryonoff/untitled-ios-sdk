import DuckFoundation

/// Broadcasts values to every live `AsyncStream` it has handed out.
///
/// Replaces `PassthroughSubject` + `sink` + `AnyCancellable` for a fire-and-forget
/// event bus: ``yield(_:)`` reaches every stream from ``stream(bufferingPolicy:)``,
/// and a stream unsubscribes itself when its consumer stops iterating.
///
/// ``init(_:)`` makes it a `CurrentValueSubject` instead: it keeps the latest value
/// and opens every new stream with it. Without that, a subscriber arriving after the
/// value settled learns nothing until the next change — which, for state like
/// connectivity, may never come.
///
/// Values are dropped when there is no live stream — unless the broadcast was
/// created with `holdsUntilSubscribed`, which keeps them for the next stream, as a
/// delegate callback arriving before anyone listens needs. Each stream buffers
/// independently — a slow consumer cannot stall the producer or its peers. Pick a
/// `bufferingPolicy` per stream to bound that buffer.
///
/// Nothing available covers this. Checked before writing it:
/// - `AsyncChannel.send` and the proposed `AsyncRelay` (swift-async-algorithms
///   PR `pr/relay`) are *rendezvous* primitives: the producer suspends until a
///   consumer takes the value, and one consumer takes it. Our producers are
///   synchronous delegate callbacks, and our consumers each need every value.
/// - `AsyncSequence.share()` broadcasts, but needs iOS 18; this package targets
///   iOS 17. It also shares one buffer across consumers, trimmed to the slowest;
///   per-stream buffers suit our unrelated consumers better.
/// - `ConcurrencyExtras`/`swift-sharing` have no multicast type.
public final class AsyncBroadcast<Element: Sendable>: Sendable {
  private struct State {
    /// Monotonic subscription id, following `AsyncShareSequence`'s `generation`
    /// counter — cheaper than a `UUID` and keeps this file free of `Foundation`.
    var generation = 0
    var continuations: [Int: AsyncStream<Element>.Continuation] = [:]
    var isFinished = false
    /// The most recent value, kept only when ``replaysLatest`` — an event bus has
    /// no current value to hand anyone, and holding the last event would both leak
    /// it and deliver it to a subscriber that did not live through it.
    var latest: Element?
    /// Values broadcast while no stream was live, kept only when
    /// ``holdsUntilSubscribed`` and handed to the next stream that opens.
    var held: [Element] = []
  }

  private let state = Mutex(State())

  /// Whether a new stream opens with the most recently broadcast value.
  private let replaysLatest: Bool

  /// Whether values broadcast while no stream is live wait for the next one.
  private let holdsUntilSubscribed: Bool

  /// An event bus: a stream receives only what is broadcast after it opens.
  ///
  /// - Parameter holdsUntilSubscribed: Keeps what is broadcast while no stream
  ///   is live and opens the next stream with all of it, in order — for events
  ///   that must not be lost to a subscriber that arrives late, such as the
  ///   notification tap that launched the app.
  public init(holdsUntilSubscribed: Bool = false) {
    replaysLatest = false
    self.holdsUntilSubscribed = holdsUntilSubscribed
  }

  /// A current-value broadcast: every stream opens with the latest value, so a
  /// subscriber that arrives after the value settled still learns it instead of
  /// waiting for a change that may never come.
  ///
  /// Use this for state (connectivity, an authorization status); use ``init()``
  /// for events, where replaying the last one to a latecomer would be wrong.
  public init(_ initialValue: Element) {
    replaysLatest = true
    holdsUntilSubscribed = false
    state.withLock { $0.latest = initialValue }
  }

  deinit { finish() }

  /// The most recently broadcast value, or `nil` on a broadcast created with
  /// ``init()`` — an event bus keeps no current value.
  public var value: Element? {
    state.withLock(\.latest)
  }

  /// A stream receiving every value broadcast from now on, opening with the
  /// current value when this broadcast was created with ``init(_:)``.
  ///
  /// The replayed value is yielded under the same lock that registers the stream,
  /// so a concurrent ``yield(_:)`` can neither be lost between the two nor arrive
  /// out of order.
  ///
  /// The stream finishes when ``finish()`` is called or this broadcast is
  /// deallocated. Iterating is optional: an abandoned stream unsubscribes itself.
  public func stream(
    bufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy = .unbounded
  ) -> AsyncStream<Element> {
    let (stream, continuation) = AsyncStream.makeStream(
      of: Element.self,
      bufferingPolicy: bufferingPolicy
    )

    let id = state.withLock { state -> Int? in
      guard !state.isFinished else { return nil }
      defer { state.generation += 1 }
      state.continuations[state.generation] = continuation
      if let latest = state.latest {
        continuation.yield(latest)
      }
      for value in state.held {
        continuation.yield(value)
      }
      state.held.removeAll()
      return state.generation
    }

    guard let id else {
      // Already finished: hand back an empty stream rather than one that hangs.
      continuation.finish()
      return stream
    }

    // `weak`: a stream nobody iterates must not keep this broadcast alive.
    continuation.onTermination = { [weak self] _ in
      self?.state.withLock { $0.continuations[id] = nil }
    }

    return stream
  }

  /// Broadcasts `value` to every live stream, and to later ones when this
  /// broadcast replays its latest value.
  public func yield(_ value: Element) {
    send(value) { _ in true }
  }

  /// Broadcasts `value` to every live stream, and to later ones when this
  /// broadcast replays its latest value, unless the current value already equals
  /// it. The comparison and the broadcast happen under one lock, so a concurrent
  /// ``yield(_:)`` cannot slip between them.
  ///
  /// Only a broadcast created with ``init(_:)`` has a value to compare against; an
  /// event bus broadcasts every value.
  public func yield(ifChanged value: Element) where Element: Equatable {
    send(value) { $0 != value }
  }

  /// The shared body of the `yield` family: `shouldSend` is evaluated against the
  /// current value under the lock that the broadcast itself takes.
  private func send(_ value: Element, if shouldSend: (Element) -> Bool) {
    // Copied out under the lock, then yielded outside it: `yield` can resume a
    // consumer inline, and re-entering `yield`/`stream` would deadlock on the
    // non-recursive `Mutex`.
    let continuations = state.withLock { state -> [AsyncStream<Element>.Continuation] in
      if let latest = state.latest, !shouldSend(latest) {
        return []
      }
      if replaysLatest { state.latest = value }
      if holdsUntilSubscribed, state.continuations.isEmpty {
        state.held.append(value)
      }
      return Array(state.continuations.values)
    }
    for continuation in continuations {
      continuation.yield(value)
    }
  }

  /// Finishes every live stream. Streams handed out afterwards finish immediately.
  public func finish() {
    let continuations = state.withLock { state -> [AsyncStream<Element>.Continuation] in
      state.isFinished = true
      defer { state.continuations.removeAll() }
      return Array(state.continuations.values)
    }
    for continuation in continuations {
      continuation.finish()
    }
  }
}

extension AsyncBroadcast where Element == Void {
  /// Broadcasts a signal to every live stream.
  public func yield() {
    yield(())
  }
}
