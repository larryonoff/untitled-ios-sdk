import Foundation

public struct Version {

  /// The major version according to the semantic versioning standard.
  public let major: Int

  /// The minor version according to the semantic versioning standard.
  public let minor: Int

  /// The patch version according to the semantic versioning standard.
  public let patch: Int


  /// The pre-release identifier according to the semantic versioning standard, such as `-beta.1`.
  public let prereleaseIdentifiers: [String]

  /// The build metadata of this version according to the semantic versioning standard, such as a commit hash.
  public let buildMetadataIdentifiers: [String]

  /// Initializes a version struct with the provided components of a semantic version.
  ///
  /// - Parameters:
  ///   - major: The major version number.
  ///   - minor: The minor version number.
  ///   - patch: The patch version number.
  ///   - prereleaseIdentifiers: The pre-release identifier.
  ///   - buildMetaDataIdentifiers: Build metadata that identifies a build.
  ///
  /// - Precondition: `major >= 0 && minor >= 0 && patch >= 0`.
  /// - Precondition: `prereleaseIdentifiers` can contain only ASCII alpha-numeric characters and "-".
  /// - Precondition: `buildMetaDataIdentifiers` can contain only ASCII alpha-numeric characters and "-".
  public init(
    _ major: Int,
    _ minor: Int,
    _ patch: Int,
    prereleaseIdentifiers: [String] = [],
    buildMetadataIdentifiers: [String] = []
  ) {
    precondition(major >= 0 && minor >= 0 && patch >= 0, "Negative versioning is invalid.")
    precondition(
      prereleaseIdentifiers.allSatisfy {
        $0.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-") }
      },
      #"Pre-release identifiers can contain only ASCII alpha-numeric characters and "-"."#
    )
    precondition(
      buildMetadataIdentifiers.allSatisfy {
        $0.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-") }
      },
      #"Build metadata identifiers can contain only ASCII alpha-numeric characters and "-"."#
    )
    self.major = major
    self.minor = minor
    self.patch = patch
    self.prereleaseIdentifiers = prereleaseIdentifiers
    self.buildMetadataIdentifiers = buildMetadataIdentifiers
  }
}

extension Version: Comparable {
  public static func < (lhs: Version, rhs: Version) -> Bool {
    let lhsComparators = [lhs.major, lhs.minor, lhs.patch]
    let rhsComparators = [rhs.major, rhs.minor, rhs.patch]

    if lhsComparators != rhsComparators {
      return lhsComparators.lexicographicallyPrecedes(rhsComparators)
    }

    guard lhs.prereleaseIdentifiers.count > 0 else {
      return false // Non-prerelease lhs >= potentially prerelease rhs
    }

    guard rhs.prereleaseIdentifiers.count > 0 else {
      return true // Prerelease lhs < non-prerelease rhs
    }

    for (lhsPrereleaseIdentifier, rhsPrereleaseIdentifier) in zip(lhs.prereleaseIdentifiers, rhs.prereleaseIdentifiers) {
      if lhsPrereleaseIdentifier == rhsPrereleaseIdentifier {
        continue
      }

      // Check if either of the 2 pre-release identifiers is numeric.
      let lhsNumericPrereleaseIdentifier = Int(lhsPrereleaseIdentifier)
      let rhsNumericPrereleaseIdentifier = Int(rhsPrereleaseIdentifier)

      if let lhsNumericPrereleaseIdentifier = lhsNumericPrereleaseIdentifier,
         let rhsNumericPrereleaseIdentifier = rhsNumericPrereleaseIdentifier {
        return lhsNumericPrereleaseIdentifier < rhsNumericPrereleaseIdentifier
      } else if lhsNumericPrereleaseIdentifier != nil {
        return true // numeric pre-release < non-numeric pre-release
      } else if rhsNumericPrereleaseIdentifier != nil {
        return false // non-numeric pre-release > numeric pre-release
      } else {
        return lhsPrereleaseIdentifier < rhsPrereleaseIdentifier
      }
    }

    return lhs.prereleaseIdentifiers.count < rhs.prereleaseIdentifiers.count
  }
}

extension Version {
  public static let zero = Version(0, 0, 0)
}

extension Version: CustomStringConvertible {
  /// A textual description of the version object.
  public var description: String {
    var base = "\(major).\(minor).\(patch)"
    if !prereleaseIdentifiers.isEmpty {
      base += "-" + prereleaseIdentifiers.joined(separator: ".")
    }
    if !buildMetadataIdentifiers.isEmpty {
      base += "+" + buildMetadataIdentifiers.joined(separator: ".")
    }
    return base
  }
}

extension Version: Codable {
  public init(from decoder: any Decoder) throws {
    var container = try decoder.unkeyedContainer()
    let rawString = try container.decode(String.self)
    guard let version = Version(rawString) else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Cannot decode version from string"
      )
    }

    self = version
  }

  public func encode(to encoder: any Encoder) throws {
    var container = try encoder.unkeyedContainer()
    try container.encode(description)
  }
}

extension Version: Equatable {
  @inlinable
  public static func == (lhs: Version, rhs: Version) -> Bool {
    !(lhs < rhs) && !(lhs > rhs)
  }
}

extension Version: Hashable {}
extension Version: Sendable {}
