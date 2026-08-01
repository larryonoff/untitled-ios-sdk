import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// Application lifecycle notifications, spelled the same on UIKit and AppKit.
//
// UIKit is checked first: on Mac Catalyst both frameworks are importable, and
// there the app is a UIKit app posting `UIApplication` notifications.
extension Notification.Name {
  public static var applicationDidBecomeActive: Notification.Name {
#if canImport(UIKit)
    UIApplication.didBecomeActiveNotification
#elseif canImport(AppKit)
    NSApplication.didBecomeActiveNotification
#endif
  }

  public static var applicationWillResignActive: Notification.Name {
#if canImport(UIKit)
    UIApplication.willResignActiveNotification
#elseif canImport(AppKit)
    NSApplication.willResignActiveNotification
#endif
  }

  public static var applicationWillTerminate: Notification.Name {
#if canImport(UIKit)
    UIApplication.willTerminateNotification
#elseif canImport(AppKit)
    NSApplication.willTerminateNotification
#endif
  }
}
