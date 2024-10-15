extension Collection where Index: Strideable, Index.Stride: SignedInteger {
  /// Returns the subsequence at the specified index if it is within bounds, otherwise nil.
  public subscript(safe range: Range<Index>) -> SubSequence {
    self[Swift.min(range.startIndex, endIndex)..<Swift.min(range.endIndex, endIndex)]
  }
}
