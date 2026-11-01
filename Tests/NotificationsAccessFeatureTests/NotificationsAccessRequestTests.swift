import ComposableArchitecture
import DuckAnalyticsClient
import DuckDependencies
import DuckNotificationsAuthorizationClient
import Tagged
import Testing
import UserNotifications
@testable import DuckNotificationsAccessFeature

@MainActor
struct NotificationsAccessRequestTests {
  @Test(arguments: [NotificationsAuthorization.Status.notDetermined, .provisional])
  func `notify forwards the host request and dismisses after completion`(
    status: NotificationsAuthorization.Status
  ) async {
    let request = NotificationsAuthorization.Request(
      options: NotificationsAuthorization.Request.defaultOptions.union(.providesAppNotificationSettings),
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
        #expect(!isDismissed.value)
        return .authorized
      }
    }

    await store.send(.notifyButtonTapped) { $0.isRequesting = true }
    await store.finish()

    #expect(requests.value == [request])
    #expect(isDismissed.value)
  }

  @Test func `direct request emits no soft screen or tap analytics`() async {
    let events = LockIsolated<[AnalyticsClient.EventName]>([])
    let isDismissed = LockIsolated(false)
    let store = TestStore(initialState: NotificationsAccessRequest.State()) {
      NotificationsAccessRequest()
    } withDependencies: {
      $0.analytics.logEvent = { event, _ in events.withValue { $0.append(event) } }
      $0.dismiss = DismissEffect { isDismissed.setValue(true) }
      $0.notificationsAuthorization.status = { .notDetermined }
      $0.notificationsAuthorization.requestAuthorization = { _ in .denied }
    }

    await store.send(.systemPromptRequested) { $0.isRequesting = true }
    await store.finish()

    #expect(events.value.isEmpty)
    #expect(isDismissed.value)
  }

  @Test func `busy notify direct and later actions cannot duplicate or dismiss a request`() async {
    let started = AsyncStream<Void>.makeStream()
    let completion = LockIsolated<CheckedContinuation<NotificationsAuthorization.Status, Never>?>(nil)
    let requests = LockIsolated(0)
    let dismissals = LockIsolated(0)
    let events = LockIsolated<[AnalyticsClient.EventName]>([])
    let store = TestStore(initialState: NotificationsAccessRequest.State()) {
      NotificationsAccessRequest()
    } withDependencies: {
      $0.analytics.logEvent = { event, _ in events.withValue { $0.append(event) } }
      $0.dismiss = DismissEffect { dismissals.withValue { $0 += 1 } }
      $0.notificationsAuthorization.status = { .notDetermined }
      $0.notificationsAuthorization.requestAuthorization = { _ in
        requests.withValue { $0 += 1 }
        return await withCheckedContinuation { continuation in
          completion.setValue(continuation)
          started.continuation.yield(())
        }
      }
    }

    await store.send(.notifyButtonTapped) { $0.isRequesting = true }
    var iterator = started.stream.makeAsyncIterator()
    await iterator.next()
    await store.send(.notifyButtonTapped)
    await store.send(.systemPromptRequested)
    await store.send(.laterButtonTapped)
    #expect(dismissals.value == 0)
    #expect(requests.value == 1)

    completion.value?.resume(returning: .denied)
    await store.finish()

    #expect(dismissals.value == 1)
    #expect(events.value == ["screen_notifications_action"])
  }

  @Test func `authorization failure finishes the ask without assuming permission`() async {
    let isDismissed = LockIsolated(false)
    let store = TestStore(initialState: NotificationsAccessRequest.State()) {
      NotificationsAccessRequest()
    } withDependencies: {
      $0.analytics = .noop
      $0.dismiss = DismissEffect { isDismissed.setValue(true) }
      $0.notificationsAuthorization.status = { .notDetermined }
      $0.notificationsAuthorization.requestAuthorization = { _ in
        #expect(!isDismissed.value)
        throw Failure.authorization
      }
    }

    await store.send(.notifyButtonTapped) { $0.isRequesting = true }
    await store.finish()

    #expect(isDismissed.value)
  }

  @Test func `later dismisses an idle ask without requesting permission`() async {
    let isDismissed = LockIsolated(false)
    let store = TestStore(initialState: NotificationsAccessRequest.State()) {
      NotificationsAccessRequest()
    } withDependencies: {
      $0.analytics = .noop
      $0.dismiss = DismissEffect { isDismissed.setValue(true) }
    }

    await store.send(.laterButtonTapped) { $0.isRequesting = true }
    await store.finish()

    #expect(isDismissed.value)
  }

  @Test func `later owns closing until presentation teardown and blocks new actions`() async {
    let dismissals = LockIsolated(0)
    let permissionReads = LockIsolated(0)
    let actions = LockIsolated<[String]>([])
    let store = Store(initialState: NotificationsAccessRequest.State()) {
      NotificationsAccessRequest()
    } withDependencies: {
      $0.analytics.logEvent = { event, parameters in
        if event == "screen_notifications_action",
           let action = parameters?[.action] as? String {
          actions.withValue { $0.append(action) }
        }
      }
      $0.dismiss = DismissEffect { dismissals.withValue { $0 += 1 } }
      $0.notificationsAuthorization.status = {
        permissionReads.withValue { $0 += 1 }
        return .notDetermined
      }
    }

    await store.send(.laterButtonTapped).finish()
    #expect(store.isRequesting)

    // This root store retains state after the injected dismissal. The closing
    // state must reject inputs until its presentation host tears it down.
    await store.send(.laterButtonTapped).finish()
    await store.send(.notifyButtonTapped).finish()
    await store.send(.systemPromptRequested).finish()

    #expect(store.isRequesting)
    #expect(dismissals.value == 1)
    #expect(permissionReads.value == 0)
    #expect(actions.value == ["later"])
  }

  @Test(arguments: [NotificationsAuthorization.Status.denied, .authorized])
  func `decided permission dismisses before opening settings`(
    status: NotificationsAuthorization.Status
  ) async {
    let operations = LockIsolated<[String]>([])
    let store = TestStore(initialState: NotificationsAccessRequest.State()) {
      NotificationsAccessRequest()
    } withDependencies: {
      $0.analytics = .noop
      $0.dismiss = DismissEffect { operations.withValue { $0.append("dismiss") } }
      $0.notificationsAuthorization.status = { status }
      $0.openNotificationSettings = OpenNotificationSettingsEffect {
        operations.withValue { $0.append("settings") }
      }
    }

    await store.send(.notifyButtonTapped) { $0.isRequesting = true }
    await store.finish()

    #expect(operations.value == ["dismiss", "settings"])
  }

  @Test func `closing the presentation ignores a system response that arrives later`() async {
    let started = AsyncStream<Void>.makeStream()
    let completion = LockIsolated<CheckedContinuation<NotificationsAuthorization.Status, Never>?>(nil)
    let store = TestStore(initialState: PresentationHost.State()) {
      PresentationHost()
    } withDependencies: {
      $0.analytics = .noop
      $0.notificationsAuthorization.status = { .notDetermined }
      $0.notificationsAuthorization.requestAuthorization = { _ in
        await withCheckedContinuation { continuation in
          completion.setValue(continuation)
          started.continuation.yield(())
        }
      }
    }

    await store.send(.request(.presented(.systemPromptRequested))) {
      $0.request?.isRequesting = true
    }
    var iterator = started.stream.makeAsyncIterator()
    await iterator.next()
    await store.send(.request(.dismiss)) { $0.request = nil }
    completion.value?.resume(returning: .authorized)
    await store.finish()
  }

  @Test func `closing the presentation during the status read prevents prompt and settings`() async {
    let started = AsyncStream<Void>.makeStream()
    let completion = LockIsolated<CheckedContinuation<NotificationsAuthorization.Status, Never>?>(nil)
    let operations = LockIsolated<[String]>([])
    let store = TestStore(initialState: PresentationHost.State()) {
      PresentationHost()
    } withDependencies: {
      $0.analytics = .noop
      $0.notificationsAuthorization.status = {
        await withCheckedContinuation { continuation in
          completion.setValue(continuation)
          started.continuation.yield(())
        }
      }
      $0.notificationsAuthorization.requestAuthorization = { _ in
        operations.withValue { $0.append("prompt") }
        return .authorized
      }
      $0.openNotificationSettings = OpenNotificationSettingsEffect {
        operations.withValue { $0.append("settings") }
      }
    }

    await store.send(.request(.presented(.systemPromptRequested))) {
      $0.request?.isRequesting = true
    }
    var iterator = started.stream.makeAsyncIterator()
    await iterator.next()
    await store.send(.request(.dismiss)) { $0.request = nil }
    completion.value?.resume(returning: .denied)
    await store.finish()

    #expect(operations.value.isEmpty)
  }

  @Test(arguments: [String?.none, "library"])
  func `repeated appearance logs one soft screen view with the host placement`(
    placement: String?
  ) async {
    let events = LockIsolated<[AnalyticsClient.EventName]>([])
    let placements = LockIsolated<[String?]>([])
    let request = NotificationsAuthorization.Request.prompt(
      placement: placement.map { .init(rawValue: $0) }
    )
    let store = TestStore(initialState: NotificationsAccessRequest.State(request: request)) {
      NotificationsAccessRequest()
    } withDependencies: {
      $0.analytics.logEvent = { event, parameters in
        events.withValue { $0.append(event) }
        placements.withValue { $0.append(parameters?[.placement] as? String) }
      }
    }

    await store.send(.onAppear) { $0.hasAppeared = true }
    await store.send(.onAppear)
    await store.finish()

    #expect(events.value == ["screen_notifications_view"])
    #expect(placements.value == [placement])
  }

  @Test func `parent replacement survives completion of the obsolete presentation`() async {
    let started = AsyncStream<Void>.makeStream()
    let completion = LockIsolated<CheckedContinuation<NotificationsAuthorization.Status, Never>?>(nil)
    let store = TestStore(initialState: PresentationHost.State()) {
      PresentationHost()
    } withDependencies: {
      $0.analytics = .noop
      $0.notificationsAuthorization.status = { .notDetermined }
      $0.notificationsAuthorization.requestAuthorization = { _ in
        await withCheckedContinuation { continuation in
          completion.setValue(continuation)
          started.continuation.yield(())
        }
      }
    }

    await store.send(.request(.presented(.systemPromptRequested))) {
      $0.request?.isRequesting = true
    }
    var iterator = started.stream.makeAsyncIterator()
    await iterator.next()
    await store.send(.replace) {
      $0.request = .init(request: .prompt(placement: "replacement"))
    }
    completion.value?.resume(returning: .authorized)
    await store.finish()

    #expect(store.state.request?.request.placement == "replacement")
    #expect(store.state.request?.isRequesting == false)
  }

  private enum Failure: Swift.Error {
    case authorization
  }
}

@Reducer
private struct PresentationHost {
  @ObservableState
  struct State: Equatable {
    @Presents var request: NotificationsAccessRequest.State? = .init()
  }

  enum Action {
    case replace
    case request(PresentationAction<NotificationsAccessRequest.Action>)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .replace:
        state.request = .init(request: .prompt(placement: "replacement"))
        return .none
      case .request:
        return .none
      }
    }
    .ifLet(\.$request, action: \.request) {
      NotificationsAccessRequest()
    }
  }
}
