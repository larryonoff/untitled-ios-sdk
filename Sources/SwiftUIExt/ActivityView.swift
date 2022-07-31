import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)

public struct AppActivityView: UIViewControllerRepresentable {
  public typealias UIViewControllerType = UIActivityViewController

  private let activityItems: [Any]
  private let applicationActivities: [UIActivity]?

  private var excludedActivityTypes: [UIActivity.ActivityType] = []

  private var onCancel: () -> Void = { }
  private var onComplete: (Result<(activity: UIActivity.ActivityType, items: [Any]?), Error>) -> () = { _ in }

  public init(
    activityItems: [Any],
    applicationActivities: [UIActivity]? = nil
  ) {
    self.activityItems = activityItems
    self.applicationActivities = applicationActivities
  }

  public func makeUIViewController(context: Context) -> UIViewControllerType {
    let viewController = UIViewControllerType(
      activityItems: activityItems,
      applicationActivities: applicationActivities
    )

    viewController.excludedActivityTypes = excludedActivityTypes

    return viewController
  }

  public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    uiViewController.excludedActivityTypes = excludedActivityTypes

    uiViewController.completionWithItemsHandler = { activity, success, items, error in
      if let error = error {
        self.onComplete(.failure(error))
      } else if let activity = activity, success {
        self.onComplete(.success((activity, items)))
      } else if !success {
        self.onCancel()
      } else {
        assertionFailure()
      }
    }
  }

  public static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: Coordinator) {
    uiViewController.completionWithItemsHandler = nil
  }
}

extension AppActivityView {
  public func excludeActivityTypes(_ activityTypes: [UIActivity.ActivityType]) -> Self {
    var newView = self
    newView.excludedActivityTypes = activityTypes
    return newView
  }

  public func onCancel(
    perform action: @escaping () -> Void
  ) -> Self {
    var newView = self
    newView.onCancel = action
    return newView
  }

  public func onComplete(
    perform action: @escaping (Result<(activity: UIActivity.ActivityType, items: [Any]?), Error>) -> Void
  ) -> Self {
    var newView = self
    newView.onComplete = action
    return newView
  }
}

#endif
