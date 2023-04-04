import Photos
@_exported import Tagged

extension PHAsset: Identifiable {
  public typealias ID = Tagged<PHAsset, String>

  public var id: ID {
    .init(localIdentifier)
  }
}
