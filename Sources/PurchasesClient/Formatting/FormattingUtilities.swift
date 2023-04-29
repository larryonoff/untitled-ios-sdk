import Foundation

extension Int {
  var grammaticalNumber: Morphology.GrammaticalNumber {
    switch abs(self) {
    case 0...1:
      return .singular
    case 1...4:
      return .plural
    default:
      return .pluralTwo
    }
  }
}
