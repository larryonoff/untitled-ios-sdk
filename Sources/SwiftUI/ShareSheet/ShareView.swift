import Foundation
import SwiftUI

@available(tvOS, unavailable)
struct ShareView<Data: RandomAccessCollection>: View {
  private let data: Data
  private let onCompletion: (Result<Data, any Swift.Error>) -> Void
  private let onCancellation: () -> Void

  init(
    data: Data,
    onCompletion: @escaping (Result<Data, any Swift.Error>) -> Void,
    onCancellation: @escaping () -> Void = {}
  ) {
    self.data = data
    self.onCompletion = onCompletion
    self.onCancellation = onCancellation
  }

  init(
    item: String,
    onCompletion: @escaping (Result<Data, any Swift.Error>) -> Void,
    onCancellation: @escaping () -> Void = {}
  ) where Data == CollectionOfOne<String> {
    self.data = CollectionOfOne(item)
    self.onCompletion = onCompletion
    self.onCancellation = onCancellation
  }

  init(
    url: URL,
    onCompletion: @escaping (Result<Data, any Swift.Error>) -> Void,
    onCancellation: @escaping () -> Void = {}
  ) where Data == CollectionOfOne<URL> {
    self.data = CollectionOfOne(url)
    self.onCompletion = onCompletion
    self.onCancellation = onCancellation
  }

  var body: some View {
    _ShareView(
      data: data,
      onCompletion: onCompletion,
      onCancellation: onCancellation
    )
    .edgesIgnoringSafeArea(.all)
    .presentationDetents([.medium, .large])
  }
}

private struct _ShareView<Data: RandomAccessCollection>: UIViewControllerRepresentable {
  typealias UIViewControllerType = UIActivityViewController

  private let data: Data
  private let onCompletion: (Result<Data, any Swift.Error>) -> Void
  private let onCancellation: () -> Void

  init(
    data: Data,
    onCompletion: @escaping (Result<Data, any Swift.Error>) -> Void,
    onCancellation: @escaping () -> Void
  ) {
    self.data = data
    self.onCompletion = onCompletion
    self.onCancellation = onCancellation
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
    uiViewController.completionWithItemsHandler = { activity, success, items, error in
      if let error = error {
        onCompletion(.failure(error))
      } else if success {
        if let data = items as? Data {
          onCompletion(.success(data))
        } else {
          onCompletion(.success(Array<Data.Element>() as! Data))
        }
      } else if !success {
        onCancellation()
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
