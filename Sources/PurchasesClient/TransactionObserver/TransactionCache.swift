import DuckUserSettings
import Foundation

final actor TransactionCache {
  private let userSettings: UserSettingsClient

  init(userSettings: UserSettingsClient) {
    self.userSettings = userSettings
  }

  nonisolated
  func transactionIDs() -> Set<UInt64> {
    userSettings.transactionIDs()
  }

  func setTransactionIDs(_ newValue: Set<UInt64>) async {
    await userSettings.setTransactionIDs(newValue)
  }

  func append(transactionID: UInt64) async {
    var transactionIDs = userSettings.transactionIDs()
    transactionIDs.insert(transactionID)

    await userSettings.setTransactionIDs(transactionIDs)
  }

  func append(transactionIDs: [UInt64]) async {
    var transactionIDs = userSettings.transactionIDs()
    transactionIDs.formUnion(transactionIDs)

    await userSettings.setTransactionIDs(transactionIDs)
  }

  func remove(transactionID: UInt64) async {
    var transactionIDs = userSettings.transactionIDs()
    transactionIDs.remove(transactionID)

    await userSettings.setTransactionIDs(transactionIDs)
  }

  nonisolated
  func newCandidatesDate() -> Date? {
    userSettings.objectForKey(.newCandidatesDateKey) as? Date
  }

  func setNewCandidatesDate(_ newValue: Date) async {
    await userSettings.setObject(newValue, .newCandidatesDateKey)
  }

  nonisolated
  func hasRestoredPurchases() -> Bool {
    userSettings.boolForKey(.hasRestoredPurchasesKey) ?? false
  }

  func setHasRestoredPurchases(_ newValue: Bool) async {
    await userSettings.setBool(newValue, .hasRestoredPurchasesKey)
  }

  func reset() async {
    await userSettings.removeValue(forKey: .transactionIDsKey)
    await userSettings.removeValue(forKey: .newCandidatesDateKey)
    await userSettings.removeValue(forKey: .hasRestoredPurchasesKey)
  }
}

private extension UserSettingsClient {
  func transactionIDs() -> Set<UInt64> {
    dataForKey(.transactionIDsKey)
      .flatMap { String(data: $0, encoding: .utf8) }
      .flatMap { string -> Set<UInt64> in
        let ids = string
          .split(separator: .transactionIDsDelimiter)
          .compactMap { UInt64($0) }

        return Set(ids)
      } ?? []
  }

  func setTransactionIDs(_ newValue: Set<UInt64>) async {
    let newStringValue = newValue
      .map { String($0) }
      .joined(separator: String(.transactionIDsDelimiter))

    await setData(newStringValue.data(using: .utf8), .transactionIDsKey)
  }
}

private extension Character {
  static var transactionIDsDelimiter: Self { "," }
}

private extension String {
  static var hasRestoredPurchasesKey: Self {
    "SDK_TransactionCache_HasRestoredPurchases"
  }

  static var newCandidatesDateKey: Self {
    "SDK_TransactionCache_NewCandidatesDate"
  }

  static var transactionIDsKey: Self {
    "SDK_TransactionCache_TransactionIDs"
  }
}
