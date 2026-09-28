#if canImport(UIKit)

import UIKit

/// A kind of destination in the share sheet — AirDrop, Messages, Copy — named so
/// a caller can leave system ones out without importing UIKit.
///
/// An open set: extensions add their own, for example a share extension's type.
public struct ShareActivity: RawRepresentable, Hashable, Sendable {
  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }

  public static let addToReadingList = Self(.addToReadingList)
  public static let airDrop = Self(.airDrop)
  public static let assignToContact = Self(.assignToContact)
  public static let copyToPasteboard = Self(.copyToPasteboard)
  public static let mail = Self(.mail)
  public static let markupAsPDF = Self(.markupAsPDF)
  public static let message = Self(.message)
  public static let openInIBooks = Self(.openInIBooks)
  public static let print = Self(.print)
  public static let saveToCameraRoll = Self(.saveToCameraRoll)
  public static let sharePlay = Self(.sharePlay)

  private init(_ activityType: UIActivity.ActivityType) {
    self.init(rawValue: activityType.rawValue)
  }
}

#endif
