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
    @Dependency(\.remoteSettings) var remoteSettings
    @Dependency(\.userSession) var userSession
    @Dependency(\.userSettings) var userSettings

    let impl = RateUsConditionImpl(
      impressionCount: impressionCount,
      remoteSettings: remoteSettings,
      userSession: userSession,
      userSettings: userSettings
    )

    return AutoPresentation.FeatureCondition(
      isEligibleForPresentation: {
        impl.isEligibleForPresentation(for: $0, userInfo: $1)
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

private final class RateUsConditionImpl: Sendable {
  let impressionCount: Int?

  private let remoteSettings: RemoteSettingsClient
  private let userSession: UserSessionClient
  private let userSettings: UserSettingsClient

  init(
    impressionCount: Int?,
    remoteSettings: RemoteSettingsClient,
    userSession: UserSessionClient,
    userSettings: UserSettingsClient
  ) {
    self.impressionCount = impressionCount
    self.remoteSettings = remoteSettings
    self.userSession = userSession
    self.userSettings = userSettings
  }

  // MARK: - Conformance

  func isEligibleForPresentation(
    for placement: Placement?,
    userInfo: AutoPresentation.UserInfo?
  ) -> Bool {
    guard remoteSettings.isRateUsEnabled else {
      return false
    }

    if placement == .newSession {
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

        logger.info(
          """
          auto-presentation.rate-us.log-event | \
          event: \(String(describing: event), privacy: .public) \
          count: \(saveOrShareCount, privacy: .public)
          """
        )
      } else {
        await userSettings.setRateUsImpressionCount(nil)

        logger.info(
          """
          auto-presentation.rate-us.log-event | \
          event: \(String(describing: event), privacy: .public) \
          count: nil
          """
        )
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
    logger.info("auto-presentation.rate-us.validate-impression")

    guard let impressionCount, impressionCount > 0 else {
      logger.info(
        """
        auto-presentation.rate-us.validate-impression skipped | \
        reason: impression_count_not_positive
        """
      )

      return false
    }

    guard
      let loggedImpressionCount = userSettings.rateUsImpressionCount
    else {
      logger.info(
        """
        auto-presentation.rate-us.validate-impression skipped | \
        reason: no_logged_impression
        """
      )

      return false
    }

    let isCountEligible = loggedImpressionCount >= impressionCount

    let isEligible: Bool = if isNeverPresented {
      isCountEligible
    } else {
      isCountEligible && self.isPresentationDelayExpired
    }

    logger.info(
      """
      auto-presentation.rate-us.validate-impression success | \
      is_eligible: \(isEligible, privacy: .public)
      """
    )

    return isEligible
  }

  private var isEligibleNewSessionWhenNeverPresented: Bool {
    logger.info("auto-presentation.rate-us.validate-new-session")

    let rateUsStartSession = remoteSettings.rateUsStartSession
    guard rateUsStartSession > 0 else {
      logger.info(
        """
        auto-presentation.rate-us.validate-new-session skipped | \
        reason: start_session_not_positive
        """
      )

      return false
    }

    let presentationSession = userSettings.rateUsPresentationSession

    guard presentationSession == nil else {
      logger.info(
        """
        auto-presentation.rate-us.validate-new-session skipped | \
        presentation_session: \(presentationSession ?? 0, privacy: .public) \
        reason: already_presented
        """
      )

      return false
    }

    let session = userSession.metrics().totalSessionCount

    let isEligible = session >= rateUsStartSession

    logger.info(
      """
      auto-presentation.rate-us.validate-new-session success | \
      is_eligible: \(isEligible, privacy: .public) \
      session: \(session, privacy: .public) \
      start_session: \(rateUsStartSession, privacy: .public)
      """
    )

    return isEligible
  }

  private var isNeverPresented: Bool {
    return userSettings.rateUsPresentationSession == nil
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
