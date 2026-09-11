import ComposableArchitecture
import DuckAnalyticsClient
import DuckDependencies
import DuckFoundation
import Foundation

/// The two-step App Store ask: "do you love it?" hands a happy user to the
/// system review prompt, "no" hands an unhappy one to support instead of to a
/// one-star rating.
///
/// Mirrors BEAT's `OnelightRateUsFeature` without its mascot art, UIKit sheet
/// controller and auto-presentation coupling — the host owns *when* the sheet
/// appears and presents it with ``SwiftUI/View/rateUs(_:)``.
@Reducer
public struct RateUs {
  public enum Action {
    case onAppear

    case cancelTapped
    case contactSupportTapped
    case doNotLoveTapped
    case loveTapped
  }

  @ObservableState
  public struct State: Equatable, Sendable {
    /// Which of the two steps is on screen.
    public enum Intent: Equatable, Sendable {
      case review
      case support
    }

    public var intent: Intent = .review

    /// Where the support step hands the user off. Without it that step keeps a
    /// single "Cancel" action rather than showing a button that does nothing.
    public var contactURL: URL?

    /// Tags the analytics only; the reducer never branches on it.
    public var placement: Placement?

    public init(
      contactMail: String?,
      placement: Placement?
    ) {
      self.init(
        contactURL: contactMail.flatMap(URL.mail(to:)),
        placement: placement
      )
    }

    public init(
      contactURL: URL?,
      placement: Placement?
    ) {
      self.contactURL = contactURL
      self.placement = placement
    }
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.openURL) var openURL
  @Dependency(\.requestReview) var requestReview

  public init() {}

  public var body: some ReducerOf<Self> {
    CombineReducers {
      core

      RateUsAnalytics()
    }
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      case .cancelTapped:
        return .run { [dismiss] _ in await dismiss() }

      case .contactSupportTapped:
        return .run { [dismiss, openURL, contactURL = state.contactURL] _ in
          if let contactURL {
            await openURL(contactURL)
          }

          await dismiss()
        }

      case .doNotLoveTapped:
        state.intent = .support

        return .none

      case .loveTapped:
        // Asked before the dismissal: the prompt belongs to the scene, and
        // dismissing first would cancel this effect — the reducer is torn down
        // the moment the host clears the presentation.
        return .run { [dismiss, requestReview] _ in
          _ = await requestReview()

          await dismiss()
        }
      }
    }
  }
}
