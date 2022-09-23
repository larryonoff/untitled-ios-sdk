import ComposableArchitecture

extension AlertState {
  public static func failure(_ error: Swift.Error) -> Self {
    .init(
      title: .init(error.localizedDescription),
      buttons: [
        .cancel(.init("OK"))
      ] // todo
    )
  }
}
