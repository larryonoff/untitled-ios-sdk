public struct SFSymbol {
  public var rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}

extension SFSymbol: Codable {}

extension SFSymbol: CustomStringConvertible {
  public var description: String {
    return String(describing: self.rawValue)
  }
}

extension SFSymbol: Equatable {}

extension SFSymbol: Hashable {}

extension SFSymbol: RawRepresentable {}

extension SFSymbol: Sendable {}

extension SFSymbol: ExpressibleByStringLiteral {
  public init(stringLiteral: String) {
    self.init(rawValue: stringLiteral)
  }
}

extension SFSymbol {
  public static let ant: SFSymbol = "ant"

  public enum Ant {
    public static let circle: SFSymbol = "ant.circle"
    public static let circleFill: SFSymbol = "ant.circle.fill"
    public static let fill: SFSymbol = "ant.fill"
  }

  public enum Arrow {
    public static let backward: SFSymbol = "arrow.backward"
    public static let clockwise: SFSymbol = "arrow.clockwise"
    public static let counterclockwise: SFSymbol = "arrow.counterclockwise"
    public static let forward: SFSymbol = "arrow.forward"
    public static let left: SFSymbol = "arrow.left"
    public static let right: SFSymbol = "arrow.right"
    public static let triangle2Circlepath: SFSymbol = "arrow.triangle.2.circlepath"
    public static let triangleRightFill: SFSymbol = "arrowtriangle.right.fill"
    public static let down: SFSymbol = "arrow.down"
    public static let up: SFSymbol = "arrow.up"
    public static let upCircle: SFSymbol = "arrow.up.circle"
    public static let upCircleFill: SFSymbol = "arrow.up.circle.fill"
  }

  public static let bell: SFSymbol = "bell"

  public static let checkmark: SFSymbol = "checkmark"

  public enum Checkmark {
    public static let shield: SFSymbol = "checkmark.shield"
    public static let squareFill: SFSymbol = "checkmark.square.fill"
    public static let circle: SFSymbol = "checkmark.circle"
    public static let circleFill: SFSymbol = "checkmark.circle.fill"
  }

  public enum Chevron {
    public static let left: SFSymbol = "chevron.left"
    public static let backward: SFSymbol = "chevron.backward"
    public static let right: SFSymbol = "chevron.right"
    public static let forward: SFSymbol = "chevron.forward"
    public static let up: SFSymbol = "chevron.up"
    public static let down: SFSymbol = "chevron.down"
  }

  public static let circle: SFSymbol = "circle"

  public static let clock: SFSymbol = "clock"

  public static let command: SFSymbol = "command"

  public static let creditCard: SFSymbol = "creditcard"

  public static let crown: SFSymbol = "crown"

  public enum Crown {
    public static let fill: SFSymbol = "crown.fill"
  }

  public static let docOnDoc: SFSymbol = "doc.on.doc"
  public static let docOnDocFill: SFSymbol = "doc.on.doc.fill"

  public static let ellipsis: SFSymbol = "ellipsis"

  public enum Ellipsis {
    public static let message: SFSymbol = "ellipsis.message"
  }

  public static let exclamationMark: SFSymbol = "exclamationmark"

  public enum ExclamationMark {
    public static let circleFill: SFSymbol = "exclamationmark.circle.fill"
  }

  public static let gear: SFSymbol = "gear"

  public static let gearshape: SFSymbol = "gearshape"

  public static let heart: SFSymbol = "heart"
  public static let heartFill: SFSymbol = "heart.fill"

  public static let house: SFSymbol = "house"
  public static let houseFill: SFSymbol = "house.fill"

  public static let icloud: SFSymbol = "icloud"

  public enum ICloud {
    public static let fill: SFSymbol = "icloud.fill"
    public static let exclamationMark: SFSymbol = "exclamationmark.icloud"
    public static let xmark: SFSymbol = "xmark.icloud"

    public static let arrowDown: SFSymbol = "icloud.and.arrow.down"
  }

  public static let infinity: SFSymbol = "infinity"

  public enum Infinity {
    public static let circle = "infinity.circle"
    public static let circleFill = "infinity.circle.fill"
  }

  public static let ladybug: SFSymbol = "ladybug"

  public enum Ladybug {
    public static let fill: SFSymbol = "ladybug.fill"
  }

  public enum Line3 {
    public static let horizontal: SFSymbol = "line.3.horizontal"
    public static let horizontalDecrease: SFSymbol = "line.3.horizontal.decrease"
  }

  public static let lock: SFSymbol = "lock"

  public enum Minus {
    public static let circleFill: SFSymbol = "minus.circle.fill"
  }

  public static let multiply: SFSymbol = "multiply"
  public static let multiplyCircle: SFSymbol = "multiply.circle"
  public static let multiplyCircleFill: SFSymbol = "multiply.circle.fill"

  public static let pause: SFSymbol = "pause"

  public enum Pause {
    public static let circle: SFSymbol = "pause.circle"
    public static let circleFill: SFSymbol = "pause.circle.fill"
    public static let fill: SFSymbol = "pause.fill"
    public static let rectangle: SFSymbol = "pause.rectangle"
  }

  public static let pencil: SFSymbol = "pencil"

  public enum Pencil {
    public static let line: SFSymbol = "pencil.line"
  }

  public static let photo: SFSymbol = "photo"

  public enum Photo {
    public static let artframe: SFSymbol = "photo.artframe"
    public static let circle: SFSymbol = "photo.circle"
    public static let fill: SFSymbol = "photo.fill"
    public static let onRectangle: SFSymbol = "photo.on.rectangle"
    public static let onRectangleAngled: SFSymbol = "photo.on.rectangle.angled"
    public static let onRectangleFill: SFSymbol = "photo.on.rectangle.fill"
    public static let stack: SFSymbol = "photo.stack"
    public static let stackFill: SFSymbol = "photo.stack.fill"
    public static let tv: SFSymbol = "photo.tv"
  }

  public static let play: SFSymbol = "play"

  public enum Play {
    public static let fill: SFSymbol = "play.fill"
    public static let circle: SFSymbol = "play.circle"
    public static let square: SFSymbol = "play.square"
    public static let rectangle: SFSymbol = "play.rectangle"
    public static let slash: SFSymbol = "play.slash"
  }

  public static let plus: SFSymbol = "plus"

  public enum Plus {
    public static let bubble: SFSymbol = "plus.bubble"
    public static let circle: SFSymbol = "plus.circle"
    public static let circleFill: SFSymbol = "plus.circle.fill"
    public static let square: SFSymbol = "plus.square"
    public static let rectangle: SFSymbol = "plus.rectangle"
  }

  public static let questionmark: SFSymbol = "questionmark"
  public static let questionmarkCircle: SFSymbol = "questionmark.circle"

  public static let rectangle: SFSymbol = "rectangle"

  public enum Rectangle {
    public static let onRectangle: SFSymbol = "rectangle.on.rectangle"

    public enum Portrait {
      public static let onRectanglePortrait: SFSymbol = "rectangle.portrait.on.rectangle.portrait"
    }
  }

  public static let sparkles: SFSymbol = "sparkles"

  public enum Sparkles {
    public static let rectangleStack: SFSymbol = "sparkles.rectangle.stack"
  }

  public static let speaker: SFSymbol = "speaker"

  public enum Speaker {
    public static let slash: SFSymbol = "speaker.slash"
    public static let wave1: SFSymbol = "speaker.wave.1"
    public static let wave2: SFSymbol = "speaker.wave.2"
    public static let wave3: SFSymbol = "speaker.wave.3"
  }

  public static let shuffle: SFSymbol = "shuffle"

  public enum Slider {
    public static let horizontal3: SFSymbol = "slider.horizontal.3"
    public static let horizontalBelowRectangle: SFSymbol = "slider.horizontal.below.rectangle"
    public static let horizontalBelowSquareFilledAndSquare: SFSymbol =
      "slider.horizontal.below.square.filled.and.square"
    public static let horizontal2RectangleAndArrowTriangle2Circlepath: SFSymbol =
      "slider.horizontal.2.rectangle.and.arrow.triangle.2.circlepath"
    public static let vertical3: SFSymbol = "slider.vertical.3"
  }

  public static let squareAndArrowUp: SFSymbol = "square.and.arrow.up"
  public static let squareAndPencil: SFSymbol = "square.and.pencil"

  public enum Square {
    public static let onSquare: SFSymbol = "square.on.square"
  }

  public static let trash: SFSymbol = "trash"

  public static let xmark: SFSymbol = "xmark"
}
