@testable import DuckNotificationsAuthorizationClient
import Tagged
import Testing
import UserNotifications

struct StatusTests {
  @Test func provisionalStaysProvisional() {
    // Collapsing it into `authorized` would send a provisional user to
    // Settings instead of the prompt that upgrades them.
    let status = NotificationsAuthorization.Status(.provisional)
    #expect(status == .provisional)
    #expect(status.allowsDelivery)
    #expect(status.allowsPrompt)
  }

  #if os(iOS)
  @Test func ephemeralDeliversWithoutAPrompt() {
    let status = NotificationsAuthorization.Status(.ephemeral)
    #expect(status == .authorized)
    #expect(status.allowsDelivery)
    #expect(!status.allowsPrompt)
  }
  #endif

  @Test func deniedNeitherDeliversNorPrompts() {
    let status = NotificationsAuthorization.Status(.denied)
    #expect(!status.allowsDelivery)
    #expect(!status.allowsPrompt)
  }

  @Test func notDeterminedPromptsButDoesNotDeliver() {
    let status = NotificationsAuthorization.Status(.notDetermined)
    #expect(!status.allowsDelivery)
    #expect(status.allowsPrompt)
  }
}

struct RequestTests {
  @Test func provisionalAddsOnlyTheProvisionalOption() {
    let prompt = NotificationsAuthorization.Request.prompt(placement: "onboarding")
    let provisional = NotificationsAuthorization.Request.provisional(placement: "onboarding")

    #expect(!prompt.options.contains(.provisional))
    #expect(provisional.options == prompt.options.union(.provisional))
    #expect(provisional.placement == prompt.placement)
  }

  @Test func presetsLeaveInAppSettingsToTheHost() {
    // The link only works when the host handles `openSettingsFor:`.
    #expect(!NotificationsAuthorization.Request.prompt().options.contains(.providesAppNotificationSettings))
    #expect(!NotificationsAuthorization.Request.provisional().options.contains(.providesAppNotificationSettings))
  }
}
