import OrderedCollections
import Photos

public func PHFetchResultToArray<Object: PHObject>(
  _ fetchResult: PHFetchResult<Object>,
  options: NSEnumerationOptions = [],
  fetchLimit: Int = 0
) -> [Object] {
  var result = ContiguousArray<Object>()

  if fetchLimit > 0 {
    result.reserveCapacity(fetchLimit)

    fetchResult.enumerateObjects(
      options: options,
      using: { object, _, stop in
        result.append(object)

        if result.count >= fetchLimit {
          stop.pointee = true
        }
      }
    )
  } else {
    result.reserveCapacity(fetchResult.count)

    fetchResult.enumerateObjects(
      options: options,
      using: { object, _, _ in result.append(object) }
    )
  }

  return Array(result)
}

public func PHFetchResultToOrderedDictionary<Object: PHObject>(
  _ fetchResult: PHFetchResult<Object>,
  options: NSEnumerationOptions = [],
  fetchLimit: Int = 0
) -> OrderedDictionary<String, Object> {
  let objects = PHFetchResultToArray(
    fetchResult,
    options: options,
    fetchLimit: fetchLimit
  )

  var dictionary = OrderedDictionary<String, Object>(
    minimumCapacity: objects.underestimatedCount
  )

  for object in objects {
    let old = dictionary.updateValue(
      object,
      forKey: object.localIdentifier
    )

#if DEBUG
    if old != nil {
      assertionFailure("Duplicate key: '\(object.localIdentifier)'")
    }
#endif
  }

  return dictionary
}
