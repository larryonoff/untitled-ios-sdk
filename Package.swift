// swift-tools-version:5.5

import PackageDescription

extension Target.Dependency {
  static let composableArchitecture: Target.Dependency = .product(
    name: "ComposableArchitecture",
    package: "swift-composable-architecture"
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
    .library(name: "ComposableArchitectureExt", targets: ["ComposableArchitectureExt"]),
    .library(name: "FeedbackGenerator", targets: ["FeedbackGenerator"]),
    .library(name: "FoundationExt", targets: ["FoundationExt"]),
    .library(name: "GraphicsExt", targets: ["GraphicsExt"]),
    .library(name: "LoggerExt", targets: ["LoggerExt"]),
    .library(name: "SFSymbol", targets: ["SFSymbol"]),
    .library(name: "SwiftUIExt", targets: ["SwiftUIExt"]),
    .library(name: "UIKitExt", targets: ["UIKitExt"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "0.33.1"
    )
  ],
  targets: [
    .target(
      name: "ComposableArchitectureExt",
      dependencies: [
        .composableArchitecture
      ]
    ),
    .target(
      name: "FeedbackGenerator",
      linkerSettings: [
        .linkedFramework("UIKit")
      ]
    ),
    .target(name: "FoundationExt"),
    .target(
      name: "GraphicsExt",
      linkerSettings: [
        .linkedFramework("UIKit")
      ]
    ),
    .target(
      name: "LoggerExt",
      linkerSettings: [
        .linkedFramework("OSLog")
      ]
    ),
    .target(
      name: "SFSymbol",
      linkerSettings: [
        .linkedFramework("UIKit")
      ]
    ),
    .target(
      name: "SwiftUIExt",
      dependencies: [
        "GraphicsExt"
      ],
      linkerSettings: [
        .linkedFramework("SwiftUI")
      ]
    ),
    .target(
      name: "UIKitExt",
      linkerSettings: [
        .linkedFramework("UIKit")
      ]
    )
  ]
)
