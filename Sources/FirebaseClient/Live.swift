import Dependencies
import DuckLogging
import DuckUserIdentifierClient
import Firebase
import FirebaseAnalytics
import FirebaseCrashlytics
import OSLog

extension FirebaseClient: DependencyKey {
  public static let liveValue: Self = {
    @Dependency(\.userIdentifier) var userIdentifier

    let impl = FirebaseClientImpl(
      userIdentifier: userIdentifier
    )
    impl.initialize()

    return Self(
      appInstanceID: {
        FirebaseAnalytics.Analytics.appInstanceID()
      },
      logEvent: { eventName, parameters in
        FirebaseAnalytics.Analytics.log(
          eventName,
          parameters: parameters
        )
      },
      logMessage: {
        Crashlytics.crashlytics().log($0)
      },
      recordError: { error, userInfo in
        impl.record(error, userInfo: userInfo)
      },
      reset: {
        impl.reset()
      }
    )
  }()
}

final class FirebaseClientImpl {
  private let userIdentifier: UserIdentifierGenerator

  init(
    userIdentifier: UserIdentifierGenerator
  ) {
    self.userIdentifier = userIdentifier
  }

  func initialize(
  ) {
    logger.info("initialize")

    FirebaseApp.configure()

    #if DEBUG
    let crashlytics = Crashlytics.crashlytics()
    crashlytics.setCrashlyticsCollectionEnabled(false)
    #endif

    updateUserID()

    logger.info("initialize success")
  }

  func record(_ error: any Error, userInfo: [String: Any]?) {
    Crashlytics.crashlytics().record(error: error, userInfo: userInfo)
  }

  func updateUserID() {
    let userID = userIdentifier()
    FirebaseAnalytics.Analytics.setUserID(userID.uuidString)
    Crashlytics.crashlytics().setUserID(userID.uuidString)
  }

  func reset() {
    updateUserID()
  }
}

private let logger = Logger(
  subsystem: ".SDK.firebase",
  category: "Firebase"
)
