import Combine
import ComposableArchitecture
import SwiftUI

extension Effect where Failure == Never {
  /// Wraps an asynchronous unit of work that can emit any number of times in an effect.
  ///
  /// This effect is similar to ``Effect/task(priority:operation:)-4llhw`` except it is capable
  /// of emitting any number of times times, not just once.
  ///
  /// For example, if you had an async stream in your environment:
  ///
  /// ```swift
  /// struct FeatureEnvironment {
  ///   var events: @Sendable () -> AsyncStream<Event>
  /// }
  /// ```
  ///
  /// Then you could attach to it in a `run` effect by using `for await` and sending each output
  /// of the stream back into the system:
  ///
  /// ```swift
  /// case .startButtonTapped:
  ///   return .run { send in
  ///     for await event in environment.events() {
  ///       send(.event(event))
  ///     }
  ///   }
  /// ```
  ///
  /// See ``Send`` for more information on how to use the `send` argument passed to `run`'s
  /// closure.
  ///
  /// - Parameters:
  ///   - priority: Priority of the underlying task. If `nil`, the priority will come from
  ///     `Task.currentPriority`.
  ///   - operation: The operation to execute.
  /// - Returns: An effect wrapping the given asynchronous work.
  public static func run(
    priority: TaskPriority? = nil,
    _ operation: @escaping @Sendable (_ send: Send<Output>) async -> Void
  ) -> Self {
    .run { subscriber in
      let task = Task(priority: priority) { @MainActor in
        await operation(Send(send: { subscriber.send($0) }))
        subscriber.send(completion: .finished)
      }
      return AnyCancellable {
        task.cancel()
      }
    }
  }
}

/// A type that can send actions back into the system when used from ``Effect/run(priority:_:)``.
///
/// This type implements [`callAsFunction`][callAsFunction] so that you invoke it as a function
/// rather than calling methods on it:
///
/// ```swift
/// return .run { send in
///   send(.started)
///   defer { send(.finished) }
///   for await event in environment.events {
///     send(.event(event))
///   }
/// }
/// ```
///
/// You can also send actions with animation:
///
/// ```swift
/// send(.started, animation: .spring())
/// defer { send(.finished, animation: .default) }
/// ```
///
/// And if your action conforms to ``BindableAction`` you can send ``BindableAction/set(_:_:)``
/// actions with a concise syntax:
///
/// ```swift
/// send(set: \.$isLoading, to: true)
/// defer { send(set: \.$isLoading, to: false) }
/// ```
///
/// See ``Effect/run(priority:_:)`` for more information on how to use this value to construct
/// effects that can emit any number of times in an asynchronous context.
///
/// [callAsFunction]: https://docs.swift.org/swift-book/ReferenceManual/Declarations.html#ID622
@MainActor
public struct Send<Action> {
  fileprivate let send: @Sendable (Action) -> Void

  public func callAsFunction(_ action: Action) {
    self.send(action)
  }

  public func callAsFunction(_ action: Action, animation: Animation? = nil) {
    withAnimation(animation) {
      self.send(action)
    }
  }
}

extension Send: Sendable where Action: Sendable {}

extension Send where Action: BindableAction {
  public func callAsFunction<Value>(
    set keyPath: WritableKeyPath<Action.State, BindableState<Value>>,
    to value: Value
  ) where Value: Equatable {
    self.send(.set(keyPath, value))
  }

  public func callAsFunction<Value>(
    set keyPath: WritableKeyPath<Action.State, BindableState<Value>>,
    to value: Value,
    animation: Animation? = nil
  ) where Value: Equatable {
    self(.set(keyPath, value), animation: animation)
  }
}
