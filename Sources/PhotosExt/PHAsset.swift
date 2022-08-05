import Photos
import Tagged

extension PHAsset: Identifiable {
  public typealias ID = Tagged<PHAsset, String>

  public var id: ID {
    .init(rawValue: localIdentifier)
  }
}
