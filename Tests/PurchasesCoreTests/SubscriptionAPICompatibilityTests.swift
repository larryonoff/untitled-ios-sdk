import DuckPurchasesCore
import Foundation
import Testing

struct SubscriptionAPICompatibilityTests {
  @Test func `converting a weekly price to a daily price preserves the rate`() {
    let week = Product.SubscriptionPeriod(unit: .week, value: 1)
    let day = Product.SubscriptionPeriod(unit: .day, value: 1)
    #expect(week.convertedPrice(70, to: day) == 10)
  }

  @Test func `preferred formatting labels preserve persisted legacy keys`() throws {
    let style = Product.SubscriptionPeriod.FormatStyle(collapsedUnits: [.month], expandedUnits: [.week])
    let data = try JSONEncoder().encode(style)
    let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    #expect(Set(object.keys) == ["unitStyle", "unitsCollapsed", "unitsExpanded", "valueDisplayStrategy"])
    let decoded = try JSONDecoder().decode(Product.SubscriptionPeriod.FormatStyle.self, from: data)
    #expect(decoded == style)
  }
}
