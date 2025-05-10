import Dependencies
import DuckAutoPresentationClient
import DuckLogging
import DuckRemoteSettingsClient
import DuckUserSessionClient
import DuckUserSettings

extension AutoPresentation.FeatureCondition {
  public static func rateUs(
    impressionCount: Int? = 1
  ) -> Self {
    let impl = RateUsConditionImpl(
      impressionCount: impressionCount
    )

    return AutoPresentation.FeatureCondition(
      isEligibleForPresentation: {
        impl.isEligibleForPresentation(event: $0, placement: $1, userInfo: $2)
      },
      increment: {
        await impl.increment()
      },
      logEvent: {
        await impl.log($0)
      },
      reset: {
        await impl.reset()
      }
    )
  }
}

private final class RateUsConditionImpl {
  @Dependency(\.remoteSettings) var remoteSettings
  @Dependency(\.userSession) var userSession
  @Dependency(\.userSettings) var userSettings

  let impressionCount: Int?

  init(impressionCount: Int?) {
    self.impressionCount = impressionCount
  }

  // MARK: - Conformance

  func isEligibleForPresentation(
    event: AutoPresentation.Event?,
    placement: Placement?,
    userInfo: AutoPresentation.UserInfo?
  ) -> Bool {
    guard remoteSettings.isRateUsEnabled else {
      return false
    }

    if event == .newSession {
      return
        isEligibleNewSessionWhenNeverPresented ||
        isPresentationDelayExpired
    }

    if impressionCount != nil {
      return isEligibleAfterImpression
    }

    return false
  }

  func increment() async {
    let totalSessionCount = Int(userSession.metrics().totalSessionCount)

    await userSettings.setRateUsPresentationSession(totalSessionCount)
    await userSettings.setRateUsImpressionCount(nil)
  }

  func log(_ event: AutoPresentation.Event) async {
    switch event {
    case .RateUs.impression:
      if isNeverPresented || isPresentationDelayExpired {
        let saveOrShareCount = userSettings.rateUsImpressionCount ?? 0

        await userSettings.setRateUsImpressionCount(
          saveOrShareCount + 1
        )

        logger.info("logEvent", dump: [
          "event": event,
          "saveOrShareCount": saveOrShareCount
        ])
      } else {
        await userSettings.setRateUsImpressionCount(nil)

        logger.info("logEvent", dump: [
          "event": event,
          "saveOrShareCount": "nil"
        ])
      }
    default:
      break
    }
  }

  func reset() async {
    await userSettings.setRateUsPresentationSession(nil)
    await userSettings.setRateUsImpressionCount(nil)
  }

  // MARK: - Conditions

  private var isEligibleAfterImpression: Bool {
    logger.info("validate after save or share")

    guard let impressionCount, impressionCount > 0 else {
      logger.info("validate after save or share", dump: [
        "eligible": false,
        "reason": "save or share delay less than or equal to 0"
      ])

      return false
    }

    guard
      let loggedImpressionCount = userSettings.rateUsImpressionCount
    else {
      logger.info("validate after save or share", dump: [
        "eligible": false,
        "reason": "user did not share"
      ])

      return false
    }

    let isCountEligible = loggedImpressionCount >= impressionCount

    let isEligible: Bool = if isNeverPresented {
      isCountEligible
    } else {
      isCountEligible && self.isPresentationDelayExpired
    }

    logger.info("validate after save or share", dump: [
      "eligible": isEligible
    ])

    return isEligible
  }

  private var isEligibleNewSessionWhenNeverPresented: Bool {
    logger.info("validate when never presented")

    let rateUsStartSession = remoteSettings.rateUsStartSession
    guard rateUsStartSession > 0 else {
      logger.info("validate when never presented", dump: [
        "eligible": false,
        "reason": "start session is nil or less than 0"
      ])

      return false
    }

    let presentationSession = userSettings.rateUsPresentationSession

    guard presentationSession == nil else {
      logger.info("validate when never presented", dump: [
        "eligible": false,
        "presentationSession": presentationSession!,
        "reason": "already presented"
      ])

      return false
    }

    let session = userSession.metrics().totalSessionCount

    let isEligible = session >= rateUsStartSession

    logger.info("validate when never presented", dump: [
      "eligible": isEligible,
      "session": session,
      "startSession": rateUsStartSession
    ])

    return isEligible
  }

  private var isNeverPresented: Bool {
    userSettings.rateUsPresentationSession == nil
  }

  private var isPresentationDelayExpired: Bool {
    let sessionsDelay = remoteSettings.rateUsSessionsDelay
    let session = Int(userSession.metrics().totalSessionCount)

    // never presented
    guard let presentationSession = userSettings.rateUsPresentationSession else {
      return false
    }

    return session - presentationSession >= sessionsDelay
  }
}
