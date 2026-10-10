import SwiftUI

extension EnvironmentValues {
  @Entry public var videoAlignment: Alignment = .center
  @Entry public var videoContentMode: ContentMode? = .fit
  @Entry public var videoDisappearBehavior: VideoDisappearBehavior = .default

  /// What a video does after the audio session pauses it.
  @Entry public var videoInterruptionBehavior: VideoInterruptionBehavior = .pauses

  @Entry public var videoIsMuted: Bool = false
  @Entry public var videoLoopingEnabled: Bool = false
  @Entry public var videoPauseBehavior: VideoPauseBehavior = .default
}

extension View {
  @inlinable nonisolated
  public func videoAlignment(_ value: Alignment) -> some View {
    self.environment(\.videoAlignment, value)
  }

  @inlinable nonisolated
  public func videoContentMode(_ value: ContentMode?) -> some View {
    self.environment(\.videoContentMode, value)
  }

  @inlinable nonisolated
  public func videoDisappearBehavior(
    _ value: VideoDisappearBehavior?
  ) -> some View {
    environment(\.videoDisappearBehavior, value ?? .default)
  }

  /// Sets what a video does after the audio session pauses it.
  ///
  /// Set it once near the root for decorative, muted videos: previews and
  /// loops in paywalls and onboarding. Like any environment value it doesn't
  /// cross into a `UIHostingController` or `UIHostingConfiguration`; set it
  /// again there.
  ///
  /// ```swift
  /// RootView()
  ///   .videoInterruptionBehavior(.resumesMutedPlayback)
  /// ```
  @inlinable nonisolated
  public func videoInterruptionBehavior(
    _ behavior: VideoInterruptionBehavior
  ) -> some View {
    environment(\.videoInterruptionBehavior, behavior)
  }

  @inlinable nonisolated
  public func videoLoopingDisabled(_ value: Bool) -> some View {
    environment(\.videoLoopingEnabled, !value)
  }

  @inlinable nonisolated
  public func videoMuted(_ value: Bool) -> some View {
    self.environment(\.videoIsMuted, value)
  }

  @inlinable nonisolated
  public func videoPauseBehavior(
    _ value: VideoPauseBehavior?
  ) -> some View {
    environment(\.videoPauseBehavior, value ?? .default)
  }
}
