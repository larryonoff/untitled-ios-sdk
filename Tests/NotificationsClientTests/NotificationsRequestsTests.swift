import Testing
import UserNotifications
@testable import DuckNotificationsClient

struct NotificationsRequestsTests {
  @Test func `a pending request keeps its identifier, content and trigger`() {
    let content = UNMutableNotificationContent()
    content.title = "New recipe"
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)

    let request = Notifications.Request(
      UNNotificationRequest(identifier: "recipe", content: content, trigger: trigger)
    )

    #expect(request.identifier == "recipe")
    #expect(request.content.title == "New recipe")
    #expect((request.trigger as? UNTimeIntervalNotificationTrigger)?.timeInterval == 60)
  }
}
