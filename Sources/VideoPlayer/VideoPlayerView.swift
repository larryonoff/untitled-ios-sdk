import AVKit
import DuckSwiftUI
import Foundation
import SwiftUI
import UIKit

open class VideoPlayerView: UIView {
  private lazy var playerLayer = AVPlayerLayer()

  var player: AVPlayer? {
    get { playerLayer.player }
    set {
      guard newValue != playerLayer.player else { return }
      playerLayer.player = newValue

      playerDidChange()
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
    layer.masksToBounds = true

    playerLayer.videoGravity = .resizeAspect
    playerLayer.masksToBounds = true

    layer.addSublayer(playerLayer)

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

  private var currentItemObserver: NSKeyValueObservation?
  private var currentItemPresentationSizeObserver: NSKeyValueObservation?
  private var videoRectObserver: NSKeyValueObservation?

  private func setupBindings() {
    videoRectObserver = playerLayer.observe(
      \.videoRect,
       options: [.new, .initial],
       changeHandler: { [weak self] object, _ in
         guard let self else { return }
         self.videoRect = object.videoRect
         self.setNeedsLayout()
       }
    )

    updateCurrentItemObserver()
  }

  private func updateCurrentItemObserver() {
    guard let player else {
      currentItemObserver?.invalidate()
      currentItemObserver = nil

      currentItemDidChange(nil)
      return
    }

    currentItemObserver = player.observe(
      \.currentItem,
       options: [.new, .initial],
       changeHandler: { [weak self] player, _ in
         self?.currentItemDidChange(player.currentItem)
       }
    )
  }

  private func currentItemDidChange(_ item: AVPlayerItem?) {
    if let item {
      currentItemPresentationSizeObserver = item.observe(
        \.presentationSize,
         options: [.new, .initial],
         changeHandler: { [weak self] _, _ in
           self?.setNeedsLayout()
         }
      )
    } else {
      currentItemPresentationSizeObserver?.invalidate()
      currentItemPresentationSizeObserver = nil
    }

    setNeedsLayout()
  }

  // MARK: - layout

  private func layoutVideo() {
    CATransaction.begin()

    defer {
      CATransaction.commit()
    }

    if let animation = layer.animation(forKey: "position") {
      CATransaction.setAnimationDuration(animation.duration)
      CATransaction.setAnimationTimingFunction(
        animation.timingFunction
      )
    } else {
      CATransaction.setDisableActions(true)
    }

    guard
      let playerItem = player?.currentItem,
      !playerItem.presentationSize.isEmpty
    else {
      playerLayer.frame = bounds
      return
    }

    playerLayer.frame = playerItem.presentationSize.aligned(
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

  private func playerDidChange() {
    updateCurrentItemObserver()
  }

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
