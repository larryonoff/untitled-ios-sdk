import Foundation
import SwiftUI
import SwiftUIBackports

@available(tvOS, unavailable)
public struct ShareView<Data: RandomAccessCollection>: View {
  private let data: Data
  private let onComplete: ((Result<ShareResult<Data>, Swift.Error>) -> Void)?

  public init(
    data: Data,
    onComplete: ((Result<ShareResult<Data>, Swift.Error>) -> Void)?
  ) {
    self.data = data
    self.onComplete = onComplete
  }

  public init(
    item: String,
    onComplete: ((Result<ShareResult<Data>, Swift.Error>) -> Void)?
  ) where Data == CollectionOfOne<String> {
    self.data = CollectionOfOne(item)
    self.onComplete = onComplete
  }

  public init(
    url: URL,
    onComplete: ((Result<ShareResult<Data>, Swift.Error>) -> Void)?
  ) where Data == CollectionOfOne<URL> {
    self.data = CollectionOfOne(url)
    self.onComplete = onComplete
  }

  public var body: some View {
    _ShareView(
      data: data,
      onComplete: onComplete
    )
    .edgesIgnoringSafeArea(.all)
    .backport.presentationDetents([.medium, .large])
  }
}

public enum ShareResult<Success> {
  case success(Success)
  case userCancelled

  @inlinable
  public func map<NewSuccess>(
    _ transform: (Success) -> NewSuccess
  ) -> ShareResult<NewSuccess> {
    switch self {
    case let .success(value):
      return .success(transform(value))
    case .userCancelled:
      return .userCancelled
    }
  }
}

extension ShareResult: Equatable where Success: Equatable {}

extension ShareResult: Hashable where Success: Hashable {}

extension ShareResult: Sendable where Success: Sendable {}

private struct _ShareView<Data: RandomAccessCollection>: UIViewControllerRepresentable {
  typealias UIViewControllerType = UIActivityViewController

  private let data: Data
  private let onComplete: ((Result<ShareResult<Data>, Swift.Error>) -> Void)?

  init(
    data: Data,
    onComplete: ((Result<ShareResult<Data>, Swift.Error>) -> Void)?
  ) {
    self.data = data
    self.onComplete = onComplete
  }

  // MARK: - UIViewControllerRepresentable

  func makeUIViewController(
    context: Context
  ) -> UIViewControllerType {
    let viewController = UIViewControllerType(
      activityItems: Array(data),
      applicationActivities: nil
    )

    return viewController
  }

  func updateUIViewController(
    _ uiViewController: UIViewControllerType,
    context: Context
  ) {
    guard let onComplete = onComplete else {
      return
    }

    uiViewController.completionWithItemsHandler = { activity, success, items, error in
      if let error = error {
        onComplete(.failure(error))
      } else if success {
        if let data = items as? Data {
          onComplete(.success(.success(data)))
        } else {
          onComplete(.success(.success(Array<Data.Element>() as! Data)))
        }
      } else if !success {
          onComplete(.success(.userCancelled))
      } else {
        assertionFailure()
      }
    }
  }

  static func dismantleUIViewController(
    _ uiViewController: UIViewControllerType,
    coordinator: Coordinator
  ) {
    uiViewController.completionWithItemsHandler = nil
  }
}
