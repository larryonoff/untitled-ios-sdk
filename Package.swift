// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "Untitled",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v15),
    .macOS(.v12)
  ],
  products: [
    .library(name: .Client.analytics, targets: [.Client.analytics]),
    .library(name: .appsFlyer, targets: [.appsFlyer]),
    .library(name: .appVersion, targets: [.appVersion]),
    .library(name: .avFoundationExt, targets: [.avFoundationExt]),
    .library(name: "ComposableArchitectureExt", targets: ["ComposableArchitectureExt"]),
    .library(name: .concurrencyExt, targets: [.concurrencyExt]),
    .library(name: .Client.facebook, targets: [.Client.facebook]),
    .library(name: "FeedbackGenerator", targets: ["FeedbackGenerator"]),
    .library(name: .foundationSupport, targets: [.foundationSupport]),
    .library(name: "GraphicsExt", targets: ["GraphicsExt"]),
    .library(name: .instagram, targets: [.instagram]),
    .library(name: .loggingSupport, targets: [.loggingSupport]),
    .library(name: .photosExt, targets: [.photosExt]),
    .library(name: .sfSymbol, targets: [.sfSymbol]),
    .library(name: .Client.photosAuthorization, targets: [.Client.photosAuthorization]),
    .library(name: .Client.purchases, targets: [.Client.purchases]),
    .library(name: "SwiftUIExt", targets: ["SwiftUIExt"]),
    .library(name: "UIKitExt", targets: ["UIKitExt"]),
    .library(name: .userIdentifier, targets: [.userIdentifier]),
    .library(name: .Client.userSettings, targets: [.Client.userSettings]),
    .library(name: .Client.userTracking, targets: [.Client.userTracking]),
    .library(name: .videoPlayer, targets: [.videoPlayer]),
    .library(name: .webView, targets: [.webView])
  ],
  dependencies: [
    .package(
      url: "https://github.com/adaptyteam/AdaptySDK-iOS",
      from: "1.17.7"
    ),
    .package(
      url: "https://github.com/amplitude/Amplitude-iOS",
      from: "8.14.0"
    ),
    .package(
      url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework",
      from: "6.8.1"
    ),
    .package(
      url: "https://github.com/JohnSundell/AsyncCompatibilityKit",
      from: "0.1.2"
    ),
    .package(
      url: "https://github.com/facebook/facebook-ios-sdk",
      from: "14.1.0"
    ),
    .package(
      url: "https://github.com/firebase/firebase-ios-sdk",
      from: "9.5.0"
    ),
    .package(
      url: "https://github.com/kishikawakatsumi/KeychainAccess",
      from: "4.2.2"
    ),
    .package(
      url: "https://github.com/apple/swift-collections",
      from: "1.0.3"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "0.40.1"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-custom-dump",
      from: "0.5.0"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-tagged",
      from: "0.7.0"
    ),
    .package(
      url:"https://github.com/shaps80/SwiftUIBackports",
      from: "1.8.2"
    ),
    .package(
      url: "https://github.com/MarcoEidinger/URLCompatibilityKit",
      from: "1.0.0"
    )
  ],
  targets: [
    .target(
      name: .Client.analytics,
      dependencies: [
        .foundationSupport,
        .External.amplitude,
        .External.composableArchitecture,
        .External.Facebook.core,
        .External.Firebase.analytics,
        .External.tagged
      ]
    ),
    .target(name: .appVersion),
    .target(
      name: "ComposableArchitectureExt",
      dependencies: [
        .External.composableArchitecture
      ]
    ),
    .target(
      name: .avFoundationExt,
      linkerSettings: [
        .linkedFramework("AVFoundation")
      ]
    ),
    .target(
      name: .concurrencyExt,
      linkerSettings: [
        .linkedFramework("Combine")
      ]
    ),
    .target(
      name: .Client.facebook,
      dependencies: [
        .External.Facebook.core
      ]
    ),
    .target(name: "FeedbackGenerator"),
    .target(name: "GraphicsExt"),
    .target(
      name: .instagram,
      dependencies: [
        .External.composableArchitecture,
        .External.customDump
      ]
    ),
    .target(name: .sfSymbol),
    .target(
      name: .photosExt,
      dependencies: [
        .External.asyncCompatibilityKit,
        .External.composableArchitecture,
        .External.customDump
      ],
      linkerSettings: [
        .linkedFramework("Photos"),
        .linkedFramework("PhotosUI")
      ]
    ),
    .target(
      name: .Client.photosAuthorization,
      dependencies: [
        .External.composableArchitecture,
        .External.tagged
      ],
      linkerSettings: [
        .linkedFramework("Photos")
      ]
    ),
    .target(
      name: .Client.purchases,
      dependencies: [
        .Client.analytics,
        .foundationSupport,
        .loggingSupport,
        .userIdentifier,
        .External.adapty,
        .External.asyncCompatibilityKit,
        .External.composableArchitecture,
        .External.tagged
      ],
      exclude: ["swiftgen.yml"],
      resources: [
        .process("Resources")
      ],
      linkerSettings: [
        .linkedFramework("Combine"),
        .linkedFramework("StoreKit")
      ]
    ),
    .target(
      name: "SwiftUIExt",
      dependencies: [
        "GraphicsExt",
        .External.composableArchitecture,
        .External.swiftUIBackports
      ]
    ),
    .target(name: "UIKitExt"),
    .target(
      name: .Client.userSettings,
      dependencies: [
        .External.composableArchitecture
      ]
    ),
    .target(
      name: .videoPlayer,
      linkerSettings: [
        .linkedFramework("AVKit")
      ]
    ),
    .target(
      name: .Client.userTracking,
      dependencies: [
        .Client.analytics,
        .External.composableArchitecture,
        .External.Facebook.core
      ],
      linkerSettings: [
        .linkedFramework("AppTrackingTransparency")
      ]
    ),
    .appsFlyer,
    .foundationSupport,
    .loggingSupport,
    .userIdentifier,
    .webView
  ]
)

extension Target {
  static let appsFlyer = target(
    name: .appsFlyer,
    dependencies: [
      .loggingSupport,
      .Client.purchases,
      .userIdentifier,
      .External.adapty,
      .External.appsFlyer,
      .External.composableArchitecture
    ],
    path: "Sources/AppsFlyer",
    linkerSettings: [
      .linkedFramework("AppTrackingTransparency")
    ]
  )

  static let foundationSupport = target(
    name: .foundationSupport,
    dependencies: [
      .External.urlCompatibilityKit
    ]
  )

  static let loggingSupport = target(
    name: .loggingSupport,
    dependencies: [
      .External.customDump
    ],
    linkerSettings: [
      .linkedFramework("OSLog")
    ]
  )

  static let userIdentifier = target(
    name: .userIdentifier,
    dependencies: [
      .External.composableArchitecture,
      .External.keychainAccess
    ]
  )

  static let webView = target(
    name: .webView,
    linkerSettings: [
      .linkedFramework("WebKit")
    ]
  )
}

extension Target.Dependency {
  static let appsFlyer = byName(name: .appsFlyer)
  static let appVersion = byName(name: .appVersion)
  static let avFoundationExt = byName(name: .avFoundationExt)
  static let concurrencyExt = byName(name: .concurrencyExt)
  static let foundationSupport = byName(name: .foundationSupport)
  static let instagram = byName(name: .instagram)
  static let loggingSupport = byName(name: .loggingSupport)
  static let photosExt = byName(name: .photosExt)
  static let sfSymbol = byName(name: .sfSymbol)
  static let userIdentifier = byName(name: .userIdentifier)
  static let videoPlayer = byName(name: .videoPlayer)
  static let webView = byName(name: .webView)

  enum Client {
    static let analytics = byName(name: .Client.analytics)
    static let facebook = byName(name: .Client.facebook)
    static let photosAuthorization = byName(name: .Client.photosAuthorization)
    static let purchases = byName(name: .Client.purchases)
    static let userSettings = byName(name: .Client.userSettings)
    static let userTracking = byName(name: .Client.userTracking)
  }

  enum External {
    static let adapty = product(
      name: "Adapty",
      package: "AdaptySDK-iOS"
    )

    static let amplitude = product(
      name: "Amplitude",
      package: "Amplitude-iOS"
    )

    static let appsFlyer = product(
      name: "AppsFlyerLib",
      package: "AppsFlyerFramework"
    )

    static let asyncCompatibilityKit =
      byName(name: "AsyncCompatibilityKit")

    enum Collections {
      static let orderedCollections = product(
        name: "OrderedCollections",
        package: "swift-collections"
      )
    }

    static let composableArchitecture = product(
      name: "ComposableArchitecture",
      package: "swift-composable-architecture"
    )

    static let customDump = product(
      name: "CustomDump",
      package: "swift-custom-dump"
    )

    enum Facebook {
      static let core = product(
        name: "FacebookCore",
        package: "facebook-ios-sdk"
      )
    }

    enum Firebase {
      static let analytics = product(
        name: "FirebaseAnalytics",
        package: "firebase-ios-sdk"
      )

      static let crashlytics = product(
        name: "FirebaseCrashlytics",
        package: "firebase-ios-sdk"
      )
    }

    static let keychainAccess = byName(name: "KeychainAccess")

    static let tagged = product(
      name: "Tagged",
      package: "swift-tagged"
    )

    static let swiftUIBackports = byName(name: "SwiftUIBackports")

    static let urlCompatibilityKit = byName(name: "URLCompatibilityKit")
  }
}

extension String {
  static let appsFlyer = "AppsFlyer"
  static let appVersion = "AppVersion"
  static let avFoundationExt = "AVFoundationExt"
  static let concurrencyExt = "ConcurrencyExt"
  static let foundationSupport = "FoundationSupport"
  static let instagram = "Instagram"
  static let loggingSupport = "LoggingSupport"
  static let photosExt = "PhotosExt"
  static let sfSymbol = "SFSymbol"
  static let userIdentifier = "UserIdentifier"
  static let videoPlayer = "VideoPlayer"
  static let webView = "WebView"

  enum Client {
    static let analytics = "Analytics"
    static let facebook = "FacebookClient"
    static let photosAuthorization = "PhotosAuthorization"
    static let purchases = "PurchasesClient"
    static let userSettings = "UserSettings"
    static let userTracking = "UserTracking"
  }
}
