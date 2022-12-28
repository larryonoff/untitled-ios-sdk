import Photos
import Tagged

extension PHAssetCollection: Identifiable {
  public typealias ID = Tagged<PHAssetCollection, String>

  public var id: ID {
    .init(localIdentifier)
  }
}
