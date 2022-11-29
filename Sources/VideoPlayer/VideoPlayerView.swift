import AVKit
import Foundation
import SwiftUI
import SwiftUIExt
import UIKit

open class VideoPlayerView: UIView {
  public override class var layerClass: AnyClass {
    AVPlayerLayer.self
  }

  private var playerLayer: AVPlayerLayer {
    layer as! AVPlayerLayer
  }

  var player: AVPlayer? {
    get { playerLayer.player }
    set {
      guard newValue != playerLayer.player else { return }
      playerLayer.player = newValue
    }
  }

  public var videoAlignment: Alignment = .center {
    didSet { setNeedsLayout() }
  }

  public var videoGravity: AVLayerVideoGravity {
    get { playerLayer.videoGravity }
    set { playerLayer.videoGravity = newValue }
  }

  @objc dynamic
  private(set) public var videoRect: CGRect = .zero {
    didSet {
      guard videoRect != oldValue else { return }
      videoRectDidChange(videoRect)
    }
  }

  public let videoRectLayoutGuide: UILayoutGuide = {
    let layoutGuide = UILayoutGuide()
    layoutGuide.identifier = "VideoPlayer.VideoRectLayoutGuide"
    return layoutGuide
  }()

  private var videoRectObserver: NSKeyValueObservation!
  private var videoRectLeftConstraint: NSLayoutConstraint!
  private var videoRectRightConstraint: NSLayoutConstraint!
  private var videoRectTopConstraint: NSLayoutConstraint!
  private var videoRectBottomConstraint: NSLayoutConstraint!

  private var _contentOverlayView: UIView?

  open var contentOverlayView: UIView {
    if let contentOverlayView = _contentOverlayView {
      return contentOverlayView
    }

    let contentOverlayView = UIView(frame: bounds)
    contentOverlayView.autoresizingMask = [
      .flexibleWidth,
      .flexibleHeight
    ]
    contentOverlayView.backgroundColor = .clear
    addSubview(contentOverlayView)

    return contentOverlayView
  }

  public init(player: AVPlayer?) {
    super.init(frame: .zero)

    playerLayer.player = player
    playerLayer.masksToBounds = true

    setup()
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    layoutVideo()
    layoutContentLayoutGuide()
  }

  // MARK: - setup

  private func setup() {
    playerLayer.videoGravity = .resizeAspect

    setupConstraints()
    setupBindings()

    layoutVideo()
  }

  private func setupConstraints() {
    addLayoutGuide(videoRectLayoutGuide)

    videoRectLeftConstraint = videoRectLayoutGuide.leftAnchor.constraint(
      equalTo: leftAnchor,
      constant: 0
    )
    videoRectRightConstraint = videoRectLayoutGuide.rightAnchor.constraint(
      equalTo: rightAnchor,
      constant: 0
    )
    videoRectTopConstraint = videoRectLayoutGuide.topAnchor.constraint(
      equalTo: topAnchor,
      constant: 0
    )
    videoRectBottomConstraint = videoRectLayoutGuide.bottomAnchor.constraint(
      equalTo: bottomAnchor,
      constant: 0
    )

    self.videoRect = playerLayer.videoRect

    NSLayoutConstraint.activate([
      videoRectLeftConstraint,
      videoRectRightConstraint,
      videoRectTopConstraint,
      videoRectBottomConstraint
    ])
  }

  private func setupBindings() {
    videoRectObserver = playerLayer.observe(
      \.videoRect,
       options: [.new, .initial],
       changeHandler: { [weak self] object, _ in
         guard let self = self else { return }
         self.videoRect = object.videoRect
       }
    )
  }

  // MARK: - layout

  private func layoutVideo() {
    CATransaction.begin()
    defer {
      CATransaction.commit()
    }

    guard let playerItem = player?.currentItem else {
      playerLayer.frame = bounds
      return
    }

    guard
      let videoTrack = playerItem
        .asset
        .tracks(withMediaType: .video)
        .first
    else {
      playerLayer.frame = bounds
      return
    }

    if let animation = layer.animation(forKey: "position") {
      CATransaction.setAnimationDuration(animation.duration)
      CATransaction.setAnimationTimingFunction(
        animation.timingFunction
      )
    } else {
      CATransaction.disableActions()
    }

    let preferredNaturalSize = videoTrack.naturalSize
      .applying(videoTrack.preferredTransform)
      .standardized

    playerLayer.frame = preferredNaturalSize.aligned(
      in: bounds,
      videoAlignment: videoAlignment,
      videoGravity: videoGravity
    )
  }

  private func layoutContentLayoutGuide() {
    let contentRect = playerLayer.frame

    videoRectLeftConstraint.constant =
      bounds.minX + contentRect.minX
    videoRectRightConstraint.constant =
      -(bounds.width - contentRect.maxX)
    videoRectTopConstraint.constant =
      bounds.minY + contentRect.minY
    videoRectBottomConstraint.constant =
      -(bounds.height - contentRect.maxY)
  }

  // MARK: - state changes

  private func videoRectDidChange(
    _ rect: CGRect
  ) {
    if rect.isEmpty {
      videoRectLeftConstraint.constant = 0
      videoRectRightConstraint.constant = 0
      videoRectTopConstraint.constant = 0
      videoRectBottomConstraint.constant = 0
    } else {
      videoRectLeftConstraint.constant = rect.minX
      videoRectRightConstraint.constant = -(bounds.width - rect.maxX)
      videoRectTopConstraint.constant = rect.minY
      videoRectBottomConstraint.constant = -(bounds.height - rect.maxY)
    }
  }
}
