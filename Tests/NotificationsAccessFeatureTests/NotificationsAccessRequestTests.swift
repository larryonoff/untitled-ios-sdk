import ComposableArchitecture
import DuckAnalyticsClient
import DuckDependencies
@testable import DuckNotificationsAccessFeature
import DuckNotificationsAuthorizationClient
import Tagged
import Testing
import UserNotifications

@MainActor
struct NotificationsAccessRequestTests {
  @Test(arguments: [
    NotificationsAuthorization.Status.notDetermined,
    .provisional,
  ])
  func notifyAsksWithTheHostsRequestWhileThePromptCanShow(
    status: NotificationsAuthorization.Status
  ) async {
    let request = NotificationsAuthorization.Request(
      options: NotificationsAuthorization.Request.defaultOptions
        .union(.providesAppNotificationSettings),
      placement: "settings"
    )
    let requests = LockIsolated<[NotificationsAuthorization.Request]>([])
    let isDismissed = LockIsolated(false)

    let store = TestStore(initialState: NotificationsAccessRequest.State(request: request)) {
      NotificationsAccessRequest()
    } withDependencies: {
      $0.analytics = .noop
      $0.dismiss = DismissEffect { isDismissed.setValue(true) }
      $0.notificationsAuthorization.status = { status }
      $0.notificationsAuthorization.requestAuthorization = { request in
        requests.withValue { $0.append(request) }
        return .authorized
      }
    }

    await store.send(.notifyButtonTapped)
    await store.finish()

    #expect(requests.value == [request])
    #expect(isDismissed.value)
  }

  @Test func notifyOpensSettingsOnceDenied() async {
    let didOpenSettings = LockIsolated(false)
    let isDismissed = LockIsolated(false)

    let store = TestStore(initialState: NotificationsAccessRequest.State()) {
      NotificationsAccessRequest()
    } withDependencies: {
      $0.analytics = .noop
      $0.dismiss = DismissEffect { isDismissed.setValue(true) }
      $0.notificationsAuthorization.status = { .denied }
      $0.openNotificationSettings = OpenNotificationSettingsEffect {
        didOpenSettings.setValue(true)
      }
    }

    await store.send(.notifyButtonTapped)
    await store.finish()

    #expect(didOpenSettings.value)
    #expect(isDismissed.value)
  }
}
