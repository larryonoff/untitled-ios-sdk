// swift-tools-version:5.6

import PackageDescription

extension Target.Dependency {
  static let composableArchitecture: Target.Dependency = .product(
    name: "ComposableArchitecture",
    package: "swift-composable-architecture"
  )

  static let tagged: Target.Dependency = .product(
    name: "Tagged",
    package: "swift-tagged"
  )
}

let package = Package(
  name: "sugar",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v14),
    .macOS(.v11)
  ],
  products: [
    .library(name: "Analytics", targets: ["Analytics"]),
    .library(name: "AppStoreClient", targets: ["AppStoreClient"]),
    .library(name: "AppVersion", targets: ["AppVersion"]),
    .library(name: "ComposableArchitectureExt", targets: ["ComposableArchitectureExt"]),
    .library(name: "FeedbackGenerator", targets: ["FeedbackGenerator"]),
    .library(name: "FoundationExt", targets: ["FoundationExt"]),
    .library(name: "GraphicsExt", targets: ["GraphicsExt"]),
    .library(name: "LoggerExt", targets: ["LoggerExt"]),
    .library(name: "OpenURL", targets: ["OpenURL"]),
    .library(name: "SFSymbol", targets: ["SFSymbol"]),
    .library(name: "SwiftUIExt", targets: ["SwiftUIExt"]),
    .library(name: "UIKitExt", targets: ["UIKitExt"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/adaptyteam/AdaptySDK-iOS",
      from: "1.17.7"
    ),
    .package(
      url: "https://github.com/amplitude/Amplitude-iOS",
      from: "8.10.2"
    ),
    .package(
      url: "https://github.com/JohnSundell/AsyncCompatibilityKit",
      from: "0.1.2"
    ),
    .package(
      url: "https://github.com/facebook/facebook-ios-sdk",
      from: "14.0.0"
    ),
    .package(
      url: "https://github.com/firebase/firebase-ios-sdk",
      from: "9.2.0"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "0.38.1"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-tagged.git",
      from: "0.7.0"
    )
  ],
  targets: [
    .target(
      name: "Analytics",
      dependencies: [
        .product(name: "Amplitude", package: "Amplitude-iOS"),
        .composableArchitecture,
        .product(name: "FacebookCore", package: "facebook-ios-sdk"),
        .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
        "FoundationExt",
        .tagged
      ]
    ),
    .target(
      name: "AppStoreClient",
      dependencies: [
        .product(name: "Adapty", package: "AdaptySDK-iOS"),
        "AsyncCompatibilityKit",
        .composableArchitecture,
        "FoundationExt",
        "Analytics",
        .tagged
      ],
      linkerSettings: [
        .linkedFramework("Combine"),
        .linkedFramework("StoreKit")
      ]
    ),
    .target(name: "AppVersion"),
    .target(
      name: "ComposableArchitectureExt",
      dependencies: [
        .composableArchitecture
      ]
    ),
    .target(name: "FeedbackGenerator"),
    .target(name: "FoundationExt"),
    .target(name: "GraphicsExt"),
    .target(
      name: "LoggerExt",
      linkerSettings: [
        .linkedFramework("OSLog")
      ]
    ),
    .target(name: "OpenURL"),
    .target(name: "SFSymbol"),
    .target(
      name: "SwiftUIExt",
      dependencies: [
        "GraphicsExt"
      ]
    ),
    .target(name: "UIKitExt")
  ]
)
