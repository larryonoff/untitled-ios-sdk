import UIKit

extension UIColor {
  /// The shorthand three-digit hexadecimal representation of color.
  /// #RGB defines to the color #RRGGBB.
  ///
  /// - Parameter hex3: Three-digit hexadecimal value.
  /// - Parameter alpha: 0.0 - 1.0. The default is 1.0.
  public convenience init(hex3: UInt16, alpha: CGFloat = 1) {
    let divisor = CGFloat(15)
    let red     = CGFloat((hex3 & 0xF00) >> 8) / divisor
    let green   = CGFloat((hex3 & 0x0F0) >> 4) / divisor
    let blue    = CGFloat(hex3 & 0x00F) / divisor
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }

  /// The shorthand four-digit hexadecimal representation of color with alpha.
  /// #RGBA defines to the color #RRGGBBAA.
  ///
  /// - Parameter hex4: Four-digit hexadecimal value.
  public convenience init(hex4: UInt16) {
    let divisor = CGFloat(15)
    let red     = CGFloat((hex4 & 0xF000) >> 12) / divisor
    let green   = CGFloat((hex4 & 0x0F00) >>  8) / divisor
    let blue    = CGFloat((hex4 & 0x00F0) >>  4) / divisor
    let alpha   = CGFloat(hex4 & 0x000F) / divisor
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }

  /// The six-digit hexadecimal representation of color of the form #RRGGBB.
  ///
  /// - Parameter hex6: Six-digit hexadecimal value.
  /// - Parameter alpha: 0.0 - 1.0. The default is 1.0.
  public convenience init(hex6: UInt32, alpha: CGFloat = 1.0) {
    let divisor = CGFloat(255)
    let red     = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
    let green   = CGFloat((hex6 & 0x00FF00) >>  8) / divisor
    let blue    = CGFloat(hex6 & 0x0000FF) / divisor

    self.init(
      red: red,
      green: green,
      blue: blue,
      alpha: alpha
    )
  }

  /// The six-digit hexadecimal representation of color with alpha of the form #RRGGBBAA.
  ///
  /// - Parameter hex8: Eight-digit hexadecimal value.
  public convenience init(hex8: UInt32) {
    let divisor = CGFloat(255)
    let red     = CGFloat((hex8 & 0xFF000000) >> 24) / divisor
    let green   = CGFloat((hex8 & 0x00FF0000) >> 16) / divisor
    let blue    = CGFloat((hex8 & 0x0000FF00) >>  8) / divisor
    let alpha   = CGFloat(hex8 & 0x000000FF) / divisor
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }

  /// The six-digit hexadecimal representation of color of the form #RRGGBB.
  ///
  /// - Parameter rgb: Six-digit hexadecimal value.
  /// - Parameter alpha: 0.0 - 1.0. The default is 1.0.
  public convenience init(rgb: UInt32, alpha: CGFloat = 1.0) {
    self.init(hex6: rgb, alpha: alpha)
  }

  /// The six-digit hexadecimal representation of color with alpha of the form #RRGGBBAA.
  ///
  /// - Parameter rgba: Eight-digit hexadecimal value.
  public convenience init(rgba: UInt32) {
    self.init(hex8: rgba)
  }

  /// The rgba string representation of color with alpha of the form #RRGGBBAA/#RRGGBB.
  ///
  /// - Parameter rgba: String value.
  public convenience init?(_ rgba: String) {
    guard rgba.hasPrefix("#") else {
      return nil
    }

    let hexString = String(rgba[String.Index(utf16Offset: 1, in: rgba)...])
    var hexValue: UInt32 = 0

    guard Scanner(string: hexString).scanHexInt32(&hexValue) else {
      return nil
    }

    switch hexString.count {
    case 3:
      self.init(hex3: UInt16(hexValue))
    case 4:
      self.init(hex4: UInt16(hexValue))
    case 6:
      self.init(hex6: hexValue)
    case 8:
      self.init(hex8: hexValue)
    default:
      return nil
    }
  }
}
