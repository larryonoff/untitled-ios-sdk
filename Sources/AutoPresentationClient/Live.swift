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

private final class AutoPresentationClientImpl {
  let conditions: OrderedDictionary<AutoPresentation.Feature, AutoPresentation.FeatureCondition>

  let userSession: UserSessionClient
  let userSettings: UserSettingsClient

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
    userInfo: Any?
  ) -> Bool {
    logger.info("canPresentFeature", dump: [
      "feature": feature,
      "placement": placement?.rawValue as Any
    ])

    guard userSettings.isOnboardingCompleted else {
      logger.error("canPresentFeature failure", dump: [
        "feature": feature,
        "placement": placement?.rawValue as Any,
        "error": "onboarding not completed"
      ])

      return false
    }

    let totalSessionCount = Int(userSession.metrics().totalSessionCount)

    guard userSettings.autoPresentationSessionID != totalSessionCount else {
      logger.error("canPresentFeature failure", dump: [
        "feature": feature,
        "placement": placement?.rawValue as Any,
        "error": "same session"
      ])

      return false
    }

    guard let condition = conditions[feature] else {
      logger.error("canPresentFeature failure", dump: [
        "feature": feature,
        "placement": placement?.rawValue as Any,
        "error": "condition not presented"
      ])

      return false
    }

    let isEligibleForPresentation = condition.canPresent(
      placement,
      userInfo
    )

    logger.info("canPresentFeature response", dump: [
      "feature": feature,
      "placement": placement?.rawValue as Any,
      "isEligibleForPresentation": isEligibleForPresentation
    ])

    return isEligibleForPresentation
  }

  func increment(_ feature: AutoPresentation.Feature) async {
    let totalSessionCount = Int(userSession.metrics().totalSessionCount)
    await userSettings.setAutoPresentationSession(totalSessionCount)

    conditions[feature]?.increment()

    logger.info("increment", dump: [
      "feature": feature
    ])
  }

  func logEvent(_ event: AutoPresentation.Event) async {
    for condition in conditions.values {
      condition.logEvent(event)
    }
  }

  func reset() async {
    logger.info("reset")

    await userSettings.setAutoPresentationSession(nil)

    for condition in conditions.values {
      condition.reset()
    }
  }
}
