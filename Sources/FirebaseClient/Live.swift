import Firebase
import FirebaseAnalytics
import FirebaseCrashlytics
import ComposableArchitecture

extension FirebaseClient {
  public static let live = FirebaseClient(
    initialize: {
      await MainActor.run {
        FirebaseApp.configure()

        #if DEBUG
        let crashlytics = Crashlytics.crashlytics()
        crashlytics.setCrashlyticsCollectionEnabled(false)
        #endif
      }
    }
  )
}
