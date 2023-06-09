import SwiftUI

extension View {
  @ViewBuilder
  public func `if`<Transform: View>(
    _ condition: Bool,
    transform: (Self) -> Transform
  ) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }

  @ViewBuilder
  public func `if`<TrueContent: View, FalseContent: View>(
    _ condition: Bool,
    if ifTransform: (Self) -> TrueContent,
    else elseTransform: (Self) -> FalseContent
  ) -> some View {
    if condition {
      ifTransform(self)
    } else {
      elseTransform(self)
    }
  }

  @ViewBuilder
  public func ifLet<V, Transform: View>(
    _ value: V?,
    transform: (Self, V) -> Transform
  ) -> some View {
    if let value = value {
      transform(self, value)
    } else {
      self
    }
  }

  @ViewBuilder
  public func ifLet<V1, V2, Transform: View>(
    _ value1: V1?,
    _ value2: V2?,
    transform: (Self, V1, V2) -> Transform
  ) -> some View {
    if let value1 = value1, let value2 = value2 {
      transform(self, value1, value2)
    } else {
      self
    }
  }
}
