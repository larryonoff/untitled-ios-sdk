import Foundation

extension Int {
  var grammaticalNumber: Morphology.GrammaticalNumber {
    switch abs(self) {
    case 0...1: .singular
    case 1...4: .plural
    default: .pluralTwo
    }
  }
}
