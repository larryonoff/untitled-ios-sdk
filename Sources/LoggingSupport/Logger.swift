import CustomDump
import os.log

extension Logger {
  public func info(
    _ message: @autoclosure @escaping () -> String,
    dump args: @autoclosure @escaping () -> [String: Any]
  ) {
    let argsDump = String(customDumping: args())
    self.info("\(message())\n\(argsDump)")
  }

  public func debug(
    _ message: @autoclosure @escaping () -> String,
    dump args: @autoclosure @escaping () -> [String: Any]
  ) {
    let argsDump = String(customDumping: args())
    self.debug("\(message())\n\(argsDump)")
  }

  public func warning(
    _ message: @autoclosure @escaping () -> String,
    dump args: @autoclosure @escaping () -> [String: Any]
  ) {
    let argsDump = String(customDumping: args())
    self.warning("\(message())\n\(argsDump)")
  }

  public func error(
    _ message: @autoclosure @escaping () -> String,
    dump args: @autoclosure @escaping () -> [String: Any]
  ) {
    let argsDump = String(customDumping: args())
    self.error("\(message())\n\(argsDump)")
  }

  public func critical(
    _ message: @autoclosure @escaping () -> String,
    dump args: @autoclosure @escaping () -> [String: Any]
  ) {
    let argsDump = String(customDumping: args())
    self.critical("\(message())\n\(argsDump)")
  }

  public func fault(
    _ message: @autoclosure @escaping () -> String,
    dump args: @autoclosure @escaping () -> [String: Any]
  ) {
    let argsDump = String(customDumping: args())
    self.fault("\(message())\n\(argsDump)")
  }
}
