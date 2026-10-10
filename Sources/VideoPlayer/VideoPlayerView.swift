#if canImport(UIKit)

import AVKit
import DuckSwiftUI
import Foundation
import SwiftUI
import UIKit

open class VideoPlayerView: UIView {
  private let playerLayer = AVPlayerLayer()

  var player: AVPlayer? {
    get { playerLayer.player }
    set {
      guard newValue !== playerLayer.player else { return }
      playerLayer.player = newValue
      observeCurrentItem()
      updateInterruptionRecovery()
    }
  }

  public var videoAlignment: Alignment = .center {
    didSet {
      guard oldValue != videoAlignment else { return }
      setNeedsLayout()
    }
  }

  /// What the player does after the audio session pauses it.
  public var interruptionBehavior: VideoInterruptionBehavior = .pauses {
    didSet {
      guard oldValue != interruptionBehavior else { return }
      updateInterruptionRecovery()
    }
  }

  public var videoContentMode: SwiftUI.ContentMode? {
    get { .init(playerLayer.videoGravity) }
    set {
      guard newValue != videoContentMode else { return }
      playerLayer.videoGravity = newValue.avLayerVideoGravity
      setNeedsLayout()
    }
  }

  /// The video's frame in this view's coordinates, empty until the current
  /// item reports its size.
  @objc dynamic
  private(set) public var videoRect: CGRect = .zero

  public let videoRectLayoutGuide: UILayoutGuide = {
    let layoutGuide = UILayoutGuide()
    layoutGuide.identifier = "VideoPlayer.VideoRectLayoutGuide"
    return layoutGuide
  }()

  private var videoRectLeftConstraint: NSLayoutConstraint!
  private var videoRectRightConstraint: NSLayoutConstraint!
  private var videoRectTopConstraint: NSLayoutConstraint!
  private var videoRectBottomConstraint: NSLayoutConstraint!

  private var _contentOverlayView: UIView?

  private var interruptionRecovery: InterruptionRecovery?

  // Plain KVO rather than Combine: AVFoundation may post from its own queues,
  // and the handlers hop to the main actor before touching the view.
  private var currentItemObservation: NSKeyValueObservation?
  private var presentationSizeObservation: NSKeyValueObservation?

  open var contentOverlayView: UIView {
    if let _contentOverlayView {
      return _contentOverlayView
    }

    let contentOverlayView = UIView(frame: bounds)
    contentOverlayView.autoresizingMask = [
      .flexibleWidth,
      .flexibleHeight
    ]
    contentOverlayView.backgroundColor = .clear
    addSubview(contentOverlayView)

    _contentOverlayView = contentOverlayView

    return contentOverlayView
  }

  public init(player: AVPlayer?) {
    super.init(frame: .zero)

    playerLayer.player = player
    playerLayer.videoGravity = .resizeAspect
    playerLayer.masksToBounds = true
    layer.masksToBounds = true
    layer.addSublayer(playerLayer)

    setupConstraints()
    observeCurrentItem()
    layoutVideo()
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    nil
  }

  open override func didMoveToWindow() {
    super.didMoveToWindow()
    updateInterruptionRecovery()
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    layoutVideo()
  }

  // MARK: - setup

  private func setupConstraints() {
    addLayoutGuide(videoRectLayoutGuide)

    videoRectLeftConstraint = videoRectLayoutGuide.leftAnchor
      .constraint(equalTo: leftAnchor, constant: 0)
    videoRectRightConstraint = videoRectLayoutGuide.rightAnchor
      .constraint(equalTo: rightAnchor, constant: 0)
    videoRectTopConstraint = videoRectLayoutGuide.topAnchor
      .constraint(equalTo: topAnchor, constant: 0)
    videoRectBottomConstraint = videoRectLayoutGuide.bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: 0)

    NSLayoutConstraint.activate([
      videoRectLeftConstraint,
      videoRectRightConstraint,
      videoRectTopConstraint,
      videoRectBottomConstraint
    ])
  }

  // MARK: - observation

  private func observeCurrentItem() {
    currentItemObservation = player?.observe(\.currentItem, options: [.new]) { [weak self] _, _ in
      onMainActor {
        guard let self else { return }
        self.observePresentationSize(of: self.player?.currentItem)
      }
    }

    observePresentationSize(of: player?.currentItem)
  }

  /// `layoutVideo` reads the size itself, so a change only asks for a layout
  /// pass: a size carried over could belong to an item since replaced.
  private func observePresentationSize(of item: AVPlayerItem?) {
    presentationSizeObservation = item?.observe(\.presentationSize, options: [.new]) { [weak self] _, _ in
      onMainActor { self?.setNeedsLayout() }
    }

    setNeedsLayout()
  }

  // MARK: - layout

  /// The one writer of the layer's frame, ``videoRect`` and the layout guide,
  /// so the three always agree.
  private func layoutVideo() {
    let presentationSize = player?.currentItem?.presentationSize ?? .zero
    let frame = presentationSize.isEmpty
      ? bounds
      : presentationSize.aligned(
        in: bounds,
        videoAlignment: videoAlignment,
        videoGravity: videoContentMode.avLayerVideoGravity
      )

    if playerLayer.frame != frame {
      CATransaction.begin()
      defer { CATransaction.commit() }

      // Follow the view's own resize animation, so the video doesn't lag it.
      if let animation = layer.animation(forKey: "bounds") ?? layer.animation(forKey: "position") {
        CATransaction.setAnimationDuration(animation.duration)
        CATransaction.setAnimationTimingFunction(animation.timingFunction)
      } else {
        CATransaction.setDisableActions(true)
      }

      playerLayer.frame = frame
    }

    let videoRect = presentationSize.isEmpty ? .zero : frame
    if self.videoRect != videoRect { self.videoRect = videoRect }

    // Every pass, not only when the rect changes: the trailing and bottom
    // insets depend on the bounds too.
    updateVideoRectConstraints()
  }

  private func updateVideoRectConstraints() {
    if videoRect.isEmpty {
      videoRectLeftConstraint.constant = 0
      videoRectRightConstraint.constant = 0
      videoRectTopConstraint.constant = 0
      videoRectBottomConstraint.constant = 0
    } else {
      videoRectLeftConstraint.constant = videoRect.minX
      videoRectRightConstraint.constant = -(bounds.width - videoRect.maxX)
      videoRectTopConstraint.constant = videoRect.minY
      videoRectBottomConstraint.constant = -(bounds.height - videoRect.maxY)
    }
  }

  // MARK: - interruption

  /// Resumes the player after the audio session pauses it, while the view is
  /// in a window: only then does it have a say over the player.
  private func updateInterruptionRecovery() {
    guard window != nil, interruptionBehavior.resumes, let player else {
      interruptionRecovery = nil
      return
    }
    guard interruptionRecovery?.player !== player else { return }
    interruptionRecovery = InterruptionRecovery(player: player)
  }
}

/// Runs `body` on the main actor, synchronously when already there.
///
/// KVO and notifications deliver on whichever thread posted them: layout keys
/// arrive on the main thread, rate changes may come from AVFoundation's own
/// queues. Asserting isolation would trap on the latter; hopping always would
/// delay the former by a turn.
func onMainActor(_ body: @escaping @MainActor () -> Void) {
  if Thread.isMainThread {
    MainActor.assumeIsolated(body)
  } else {
    Task { @MainActor in body() }
  }
}

private extension Optional<SwiftUI.ContentMode> {
  var avLayerVideoGravity: AVLayerVideoGravity {
    switch self {
    case .fit?: .resizeAspect
    case .fill?: .resizeAspectFill
    case nil: .resize
    }
  }
}

private extension SwiftUI.ContentMode {
  init?(_ value: AVLayerVideoGravity) {
    switch value {
    case .resize:
      return nil
    case .resizeAspect:
      self = .fit
    case .resizeAspectFill:
      self = .fill
    default:
      return nil
    }
  }
}

#endif
