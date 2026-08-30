import ComposableArchitecture
import DuckCore
import DuckLogging
import DuckUserSessionClient
import DuckUserSettings
import OrderedCollections
import OSLog

extension AutoPresentationClient {
  public static func live(
    conditions: OrderedDictionary<AutoPresentation.Feature, AutoPresentation.FeatureCondition>
  ) -> Self {
    @Dependency(\.userSession) var userSession
    @Dependency(\.userSettings) var userSettings

    let impl = AutoPresentationClientImpl(
      conditions: conditions,
      userSession: userSession,
      userSettings: userSettings
    )

    return AutoPresentationClient(
      availableFeatures: {
        impl.availableFeatures
      },
      isEligibleForPresentation: {
        impl.isEligibleForPresentation($0, placement: $1, userInfo: $2)
      },
      increment: {
        await impl.increment($0)
      },
      logEvent: {
        await impl.logEvent($0)
      },
      reset: {
        await impl.reset()
      }
    )
  }
}

private final class AutoPresentationClientImpl: Sendable {
  let conditions: OrderedDictionary<AutoPresentation.Feature, AutoPresentation.FeatureCondition>

  private let userSession: UserSessionClient
  private let userSettings: UserSettingsClient

  init(
    conditions: OrderedDictionary<
    AutoPresentation.Feature,
    AutoPresentation.FeatureCondition
    >,
    userSession: UserSessionClient,
    userSettings: UserSettingsClient
  ) {
    self.conditions = conditions
    self.userSession = userSession
    self.userSettings = userSettings
  }

  var availableFeatures: [AutoPresentation.Feature] {
    Array(conditions.keys)
  }

  func isEligibleForPresentation(
    _ feature: AutoPresentation.Feature,
    placement: Placement?,
    userInfo: AutoPresentation.UserInfo?
  ) -> Bool {
    logger.info(
      """
      auto-presentation.evaluate | \
      feature: \(feature.rawValue, privacy: .public) \
      placement: \(placement?.rawValue ?? "nil", privacy: .public)
      """
    )

    guard userSettings.isOnboardingCompleted else {
      logger.error(
        """
        auto-presentation.evaluate failed | \
        feature: \(feature.rawValue, privacy: .public) \
        placement: \(placement?.rawValue ?? "nil", privacy: .public) \
        reason: onboarding_not_completed
        """
      )

      return false
    }

    let totalSessionCount = Int(userSession.metrics().totalSessionCount)

    guard userSettings.autoPresentationSessionID != totalSessionCount else {
      logger.error(
        """
        auto-presentation.evaluate failed | \
        feature: \(feature.rawValue, privacy: .public) \
        placement: \(placement?.rawValue ?? "nil", privacy: .public) \
        reason: same_session
        """
      )

      return false
    }

    guard let condition = conditions[feature] else {
      logger.error(
        """
        auto-presentation.evaluate failed | \
        feature: \(feature.rawValue, privacy: .public) \
        placement: \(placement?.rawValue ?? "nil", privacy: .public) \
        reason: condition_missing
        """
      )

      return false
    }

    let isEligibleForPresentation = condition.isEligibleForPresentation(
      placement,
      userInfo
    )

    logger.info(
      """
      auto-presentation.evaluate success | \
      feature: \(feature.rawValue, privacy: .public) \
      placement: \(placement?.rawValue ?? "nil", privacy: .public) \
      is_eligible: \(isEligibleForPresentation, privacy: .public)
      """
    )

    return isEligibleForPresentation
  }

  func increment(_ feature: AutoPresentation.Feature) async {
    let totalSessionCount = Int(userSession.metrics().totalSessionCount)
    await userSettings.setAutoPresentationSession(totalSessionCount)

    await conditions[feature]?.increment()

    logger.info(
      """
      auto-presentation.increment success | \
      feature: \(feature.rawValue, privacy: .public)
      """
    )
  }

  func logEvent(_ event: AutoPresentation.Event) async {
    for condition in conditions.values {
      await condition.logEvent(event)
    }
  }

  func reset() async {
    logger.info("auto-presentation.reset")

    await userSettings.setAutoPresentationSession(nil)

    for condition in conditions.values {
      await condition.reset()
    }
  }
}
