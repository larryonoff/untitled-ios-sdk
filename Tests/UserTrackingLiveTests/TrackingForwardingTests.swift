import DuckAnalyticsClient
import DuckPurchasesClient
import DuckUserTracking
import Synchronization
import Testing

@testable import DuckUserTrackingLive

struct TrackingForwardingTests {
  @Test func `tracking reaches the application owned purchases client`() async {
    let calls = Mutex<[PurchasesClient.IntegrationIDs]>([])
    let statusCalls = Mutex(0)
    var purchases = PurchasesClient()
    purchases.setIntegrationIDs = { identifiers in calls.withLock { $0.append(identifiers) } }
    purchases.setTrackingAuthorizationStatus = { _ in statusCalls.withLock { $0 += 1 } }
    let impl = UserTrackingImpl(analytics: .noop, purchases: purchases)
    await impl.sendTrackingData(.init(appMetricaDeviceID: "device-fixture", appMetricaProfileID: "profile-fixture", firebaseAppInstanceID: "firebase-fixture"))
    let forwarded = calls.withLock { $0 }
    #expect(forwarded.count == 1)
    #expect(forwarded.first?.appMetricaDeviceID == "device-fixture")
    #expect(forwarded.first?.appMetricaProfileID == "profile-fixture")
    #expect(forwarded.first?.firebaseAppInstanceID == "firebase-fixture")
    #expect(statusCalls.withLock { $0 } == 1)
  }
}
