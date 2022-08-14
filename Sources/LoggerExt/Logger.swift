import CustomDump
import os.log

extension Logger {
  public func info(
    _ message: String,
    dump args: [String: Any]
  ) {
    var argsDump = ""
    _ = customDump(args, to: &argsDump)

    self.info("\(message)\n\(argsDump)")
  }

  public func debug(
    _ message: String,
    dump args: [String: Any]
  ) {
    var argsDump = ""
    _ = customDump(args, to: &argsDump)

    self.debug("\(message)\n\(argsDump)")
  }

  public func error(
    _ message: String,
    dump args: [String: Any]
  ) {
    var argsDump = ""
    _ = customDump(args, to: &argsDump)

    self.error("\(message)\n\(argsDump)")
  }

  public func fault(
    _ message: String,
    dump args: [String: Any]
  ) {
    var argsDump = ""
    _ = customDump(args, to: &argsDump)

    self.fault("\(message)\n\(argsDump)")
  }
}
