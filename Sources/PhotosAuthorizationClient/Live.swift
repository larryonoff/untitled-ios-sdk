import Combine
import Dependencies
import DuckFoundation
import DuckLogging
import Photos

extension PhotosAuthorizationClient: DependencyKey {
  public static let liveValue: Self = {
    let impl = PhotosAuthorizationClientImpl()

    return Self(
      authorizationStatus: {
        impl.authorizationStatus(for: $0)
      },
      authorizationStatusUpdates: {
        impl.authorizationStatusUpdates(for: $0)
      },
      requestAuthorization: {
        await impl.requestAuthorization(for: $0)
      }
    )
  }()
}

private final class PhotosAuthorizationClientImpl: Sendable {
  private struct State {
    /// Status captured before a request began, held for its duration.
    /// `PHPhotoLibrary.authorizationStatus` starts reporting the new value while
    /// the system prompt is still on screen, which makes observers react before
    /// the user has actually answered.
    var statusBeforeRequest: [
      PhotosAuthorization.AccessLevel: PhotosAuthorization.AuthorizationStatus
    ] = [:]
  }

  private let state = Mutex(State())

  init() {}

  // SAFETY: `PassthroughSubject` is internally thread-safe; Combine just doesn't annotate it `Sendable`.
  private nonisolated(unsafe) let authorizationSubject =
    PassthroughSubject<
      (PhotosAuthorization.AccessLevel, PhotosAuthorization.AuthorizationStatus),
      Never
    >()

  /// In-flight requests, so concurrent callers share one system prompt instead
  /// of stacking a second one.
  @MainActor
  private var requestTasks: [
    PhotosAuthorization.AccessLevel: Task<PhotosAuthorization.AuthorizationStatus, Never>
  ] = [:]

  func authorizationStatus(
    for accessLevel: PhotosAuthorization.AccessLevel
  ) -> PhotosAuthorization.AuthorizationStatus {
    if let status = state.withLock({ $0.statusBeforeRequest[accessLevel] }) {
      return status
    }

    let status = PHPhotoLibrary.authorizationStatus(
      for: accessLevel.phAccessLevel
    )
    return PhotosAuthorization.AuthorizationStatus(status)
  }

  func authorizationStatusUpdates(
    for accessLevel: PhotosAuthorization.AccessLevel
  ) -> AsyncStream<PhotosAuthorization.AuthorizationStatus> {
    // `.values` bridges via an unfolding `AsyncStream` that holds no buffer
    // between `next()` calls, so demand is zero while a consumer works.
    // `PassthroughSubject` is synchronous and ignores backpressure, so a status
    // sent in that window traps Combine with "Received an output without
    // requesting demand". `buffer` absorbs it, as in the client's other
    // subject-to-stream bridges.
    AsyncStream(
      UncheckedSendable(
        authorizationSubject
          .buffer(size: 5, prefetch: .byRequest, whenFull: .dropOldest)
          .filter { $0.0 == accessLevel }
          .map { $0.1 }
          .values
      )
    )
  }

  @MainActor
  func requestAuthorization(
    for accessLevel: PhotosAuthorization.AccessLevel
  ) async -> PhotosAuthorization.AuthorizationStatus {
    if let existing = requestTasks[accessLevel] {
      return await existing.value
    }

    let task = Task { @MainActor in
      await performRequestAuthorization(for: accessLevel)
    }

    requestTasks[accessLevel] = task
    defer { requestTasks[accessLevel] = nil }

    return await task.value
  }

  @MainActor
  private func performRequestAuthorization(
    for accessLevel: PhotosAuthorization.AccessLevel
  ) async -> PhotosAuthorization.AuthorizationStatus {
    logger.info("request authorization", dump: [
      "accessLevel": accessLevel
    ])

    let previousStatus = authorizationStatus(for: accessLevel)

    state.withLock { $0.statusBeforeRequest[accessLevel] = previousStatus }
    defer { state.withLock { $0.statusBeforeRequest[accessLevel] = nil } }

    let newStatus = PhotosAuthorization.AuthorizationStatus(
      await PHPhotoLibrary.requestAuthorization(
        for: accessLevel.phAccessLevel
      )
    )

    if previousStatus != newStatus {
      authorizationSubject.send((accessLevel, newStatus))
    }

    logger.info("request authorization success", dump: [
      "accessLevel": accessLevel,
      "status": newStatus,
      "updated": previousStatus != newStatus
    ])

    return newStatus
  }
}

let logger = Logger(
  subsystem: ".SDK.PhotosAuthorizationClient",
  category: "Photos"
)
