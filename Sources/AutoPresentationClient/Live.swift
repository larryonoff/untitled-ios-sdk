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
    let impl = AutoPresentationClientImpl(
      conditions: conditions
    )

    return AutoPresentationClient(
      availableFeatures: {
        impl.availableFeatures
      },
      isEligibleForPresentation: {
        impl.isEligibleForPresentation($0, event: $1, placement: $2, userInfo: $3)
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
  @Dependency(\.userSession) var userSession
  @Dependency(\.userSettings) var userSettings

  let conditions: OrderedDictionary<AutoPresentation.Feature, AutoPresentation.FeatureCondition>

  init(
    conditions: OrderedDictionary<
    AutoPresentation.Feature,
    AutoPresentation.FeatureCondition
    >
  ) {
    self.conditions = conditions
  }

  var availableFeatures: [AutoPresentation.Feature] {
    Array(conditions.keys)
  }

  func isEligibleForPresentation(
    _ feature: AutoPresentation.Feature,
    event: AutoPresentation.Event?,
    placement: Placement?,
    userInfo: [AutoPresentation.UserInfoKey: Any]?
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

    let isEligibleForPresentation = condition.isEligibleForPresentation(
      event,
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

    await conditions[feature]?.increment()

    logger.info("increment", dump: [
      "feature": feature
    ])
  }

  func logEvent(_ event: AutoPresentation.Event) async {
    for condition in conditions.values {
      await condition.logEvent(event)
    }
  }

  func reset() async {
    logger.info("reset")

    await userSettings.setAutoPresentationSession(nil)

    for condition in conditions.values {
      await condition.reset()
    }
  }
}
