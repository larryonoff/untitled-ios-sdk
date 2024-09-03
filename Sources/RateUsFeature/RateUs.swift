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

    public var contactURL: URL?
    public var placement: Placement?

    public init(
      contactMail: String?,
      placement: Placement?
    ) {
      self.contactURL = contactMail.flatMap(URL.mail(to:))
      self.placement = placement
    }

    public init(
      contactURL: URL?,
      placement: Placement?
    ) {
      self.contactURL = contactURL
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
        return .run { [contactURL = state.contactURL] send in
          if let contactURL {
            await openURL(contactURL)
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
          await requestReview()
          await dismiss()
        }
      }
    }
  }
}
