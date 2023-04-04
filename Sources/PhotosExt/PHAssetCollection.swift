import Photos
@_exported import Tagged

extension PHAssetCollection {
  public var assetCount: Int {
    let fetchOptions = PHFetchOptions()
    fetchOptions.wantsIncrementalChangeDetails = false

    return PHAsset.fetchAssets(
      in: self,
      options: fetchOptions
    )
    .count
  }

  public static var smartAlbumUserLibrary: PHAssetCollection? {
    let options = PHFetchOptions()
    options.fetchLimit = 1
    options.includeAllBurstAssets = false

    return PHAssetCollection
      .fetchAssetCollections(
        with: .smartAlbum,
        subtype: .smartAlbumUserLibrary,
        options: options
      )
      .firstObject
  }
}

extension PHAssetCollection: Identifiable {
  public typealias ID = Tagged<PHAssetCollection, String>

  public var id: ID {
    .init(localIdentifier)
  }
}
