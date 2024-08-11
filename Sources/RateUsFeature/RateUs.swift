import ComposableArchitecture
import DuckAnalyticsClient
import DuckDependencies
import DuckPurchasesClient
import Foundation

@Reducer
public struct RateUs {
  public enum Action {
    case onAppear

    case contactUsTapped
    case dismissTapped
    case doNotLoveTapped
    case loveTapped
  }

  @ObservableState
  public struct State: Equatable {
    public enum Mode: Equatable {
      case `default`
      case doNotLove
    }

    public var mode: Mode = .default

    public var contactMail: String?
    public var placement: Placement?

    public init(
      contactMail: String?,
      placement: Placement?
    ) {
      self.contactMail = contactMail
      self.placement = placement
    }
  }

  @Dependency(\.analytics) var analytics
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.openURL) var openURL
  @Dependency(\.purchases) var purchases
  @Dependency(\.requestReview) var requestReview

  public init() {}

  public var body: some ReducerOf<Self> {
    analyticsBody

    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      case .contactUsTapped:
        return .run { [contactMail = state.contactMail] send in
          if let contactMail, let url = URL.mail(to: contactMail) {
            await openURL(url)
          }

          await dismiss()
        }
      case .dismissTapped:
        return .run { _ in await dismiss() }
      case .doNotLoveTapped:
        state.mode = .doNotLove

        return .none
      case .loveTapped:
        return .run { [placement = state.placement] _ in
          try? await Task.sleep(for: .seconds(2))
          await requestReview()

          await dismiss()
        }
      }
    }
  }
}
