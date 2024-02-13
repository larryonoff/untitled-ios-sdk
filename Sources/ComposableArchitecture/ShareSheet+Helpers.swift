extension ShareSheet.State: Equatable where Data: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id &&
    lhs.data == rhs.data
  }
}
