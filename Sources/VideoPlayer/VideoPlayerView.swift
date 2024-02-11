import AVKit
import Combine
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
    didSet {
      guard oldValue != videoAlignment else { return }
      setNeedsLayout()
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

  private var bindindsCancellables = Set<AnyCancellable>()
  private var currentItemCancellable: Cancellable?
  private var currentItemPresentationSizeCancellable: Cancellable?

  private func setupBindings() {
    playerLayer
      .publisher(for: \.videoRect, options: [.new, .initial])
      .sink { [weak self] videoRect in
        guard let self else { return }
        self.videoRect = videoRect
        self.setNeedsLayout()
      }
      .store(in: &bindindsCancellables)

    playerLayer
      .publisher(for: \.isReadyForDisplay)
      .sink { [weak self] isReadyForDisplay in
        guard let self else { return }
        guard isReadyForDisplay else { return }
        self.videoRect = self.playerLayer.videoRect
        self.setNeedsLayout()
      }
      .store(in: &bindindsCancellables)

    updateCurrentItemObserver()
  }

  private func updateCurrentItemObserver() {
    guard let player else {
      currentItemCancellable?.cancel()
      currentItemCancellable = nil

      currentItemDidChange(nil)
      return
    }

    currentItemCancellable = player
      .publisher(for: \.currentItem, options: [.new, .initial])
      .sink { [weak self] in
        self?.currentItemDidChange($0)
      }
  }

  private func currentItemDidChange(_ item: AVPlayerItem?) {
    if let item {
      currentItemPresentationSizeCancellable = item
        .publisher(for: \.presentationSize, options: [.new, .initial])
        .sink { [weak self] _ in
           self?.setNeedsLayout()
         }
    } else {
      currentItemPresentationSizeCancellable?.cancel()
      currentItemPresentationSizeCancellable = nil
    }

    setNeedsLayout()
  }

  // MARK: - layout

  private func layoutVideo() {
    CATransaction.begin()
    defer { CATransaction.commit()}

    if let animation = layer.animation(forKey: "position") {
      CATransaction.setAnimationDuration(animation.duration)
      CATransaction.setAnimationTimingFunction(
        animation.timingFunction
      )
    } else {
      CATransaction.setDisableActions(true)
    }

    if
      let playerItem = player?.currentItem,
      !playerItem.presentationSize.isEmpty
    {
      playerLayer.frame = playerItem.presentationSize.aligned(
        in: bounds,
        videoAlignment: videoAlignment,
        videoGravity: videoContentMode.avLayerVideoGravity
      )
    } else {
      playerLayer.frame = bounds
    }

    videoRectDidChange(playerLayer.frame)
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
