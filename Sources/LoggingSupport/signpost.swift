import Foundation
import os.log

extension OSLog {
  func signpost(
    _ type: OSSignpostType,
    dso: UnsafeRawPointer = #dsohandle,
    name: StaticString,
    signpostID: OSSignpostID = .exclusive
  ) {
    os_signpost(
      type,
      dso: dso,
      log: self,
      name: name,
      signpostID: signpostID
    )
  }
}
