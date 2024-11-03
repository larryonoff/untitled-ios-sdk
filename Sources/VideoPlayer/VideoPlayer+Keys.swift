import SwiftUI

extension EnvironmentValues {
  public var videoAlignment: Alignment {
    get { self[Video_AlignmentKey.self] }
    set { self[Video_AlignmentKey.self] = newValue }
  }

  public var videoContentMode: ContentMode? {
    get { self[Video_ContentModeKey.self] }
    set { self[Video_ContentModeKey.self] = newValue }
  }

  public var videoDisappearBehavior: VideoDisappearBehavior {
    get { self[Video_DisappearBehaviorKey.self] }
    set { self[Video_DisappearBehaviorKey.self] = newValue }
  }

  public var videoIsMuted: Bool {
    get { self[Video_IsMutedKey.self] }
    set { self[Video_IsMutedKey.self] = newValue }
  }

  public var videoLoopingEnabled: Bool {
    get { self[Video_LoopingEnabledKey.self] }
    set { self[Video_LoopingEnabledKey.self] = newValue }
  }

  public var videoPauseBehavior: VideoPauseBehavior {
    get { self[Video_PauseBehaviorKey.self] }
    set { self[Video_PauseBehaviorKey.self] = newValue }
  }
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

extension EnvironmentValues {
  private struct Video_AlignmentKey: EnvironmentKey {
    static var defaultValue: Alignment { .center }
  }

  private struct Video_ContentModeKey: EnvironmentKey {
    static var defaultValue: ContentMode? { .fit }
  }

  private struct Video_DisappearBehaviorKey: EnvironmentKey {
    static var defaultValue: VideoDisappearBehavior { .default }
  }

  private struct Video_IsMutedKey: EnvironmentKey {
    static var defaultValue: Bool { false }
  }

  private struct Video_LoopingEnabledKey: EnvironmentKey {
    static var defaultValue: Bool { false }
  }

  private struct Video_PauseBehaviorKey: EnvironmentKey {
    static var defaultValue: VideoPauseBehavior { .default }
  }
}
