import DuckPurchasesCore
import Foundation
import Testing

@Suite(.timeLimit(.minutes(1)))
struct PriceFormattingTests {
  @Test func `concurrent prices keep their own currency and rounding`() async {
    await withTaskGroup(of: Void.self) { group in
      for index in 0..<16 {
        group.addTask {
          let locale = Locale(identifier: "en_US")
          let rounding: Product.FormatStyle.RoundingRule = index.isMultiple(of: 2) ? .down : .up
          let expected = index.isMultiple(of: 2) ? "$1.23" : "$1.24"
          for _ in 0..<300 {
            let price = Product.formattedPrice(Decimal(string: "1.239")!, locale: locale, roundingRule: rounding)
            #expect(price == expected)
          }
        }
      }
    }
  }
}
