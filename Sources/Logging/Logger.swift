import CustomDump
import os.log

extension Logger {
  public func info(
    _ message: @autoclosure @escaping () -> String,
    dump args: @autoclosure () -> [String: Any]
  ) {
    let argsDump = String(customDumping: args())
    self.info("\(message(), privacy: .public)\n\(argsDump)")
  }

  public func debug(
    _ message: @autoclosure @escaping () -> String,
    dump args: @autoclosure () -> [String: Any]
  ) {
    let argsDump = String(customDumping: args())
    self.debug("\(message(), privacy: .public)\n\(argsDump, privacy: .public)")
  }

  public func warning(
    _ message: @autoclosure @escaping () -> String,
    dump args: @autoclosure () -> [String: Any]
  ) {
    let argsDump = String(customDumping: args())
    self.warning("\(message(), privacy: .public)\n\(argsDump)")
  }

  public func error(
    _ message: @autoclosure @escaping () -> String,
    dump args: @autoclosure () -> [String: Any]
  ) {
    let argsDump = String(customDumping: args())
    self.error("\(message(), privacy: .public)\n\(argsDump, privacy: .public)")
  }

  public func critical(
    _ message: @autoclosure @escaping () -> String,
    dump args: @autoclosure () -> [String: Any]
  ) {
    let argsDump = String(customDumping: args())
    self.critical("\(message(), privacy: .public)\n\(argsDump, privacy: .public)")
  }

  public func fault(
    _ message: @autoclosure @escaping () -> String,
    dump args: @autoclosure () -> [String: Any]
  ) {
    let argsDump = String(customDumping: args())
    self.fault("\(message(), privacy: .public)\n\(argsDump)")
  }
}
