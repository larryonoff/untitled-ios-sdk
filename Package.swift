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
    .library(name: .amplitudeClient, targets: [.amplitudeClient]),
    .library(name: .Client.analytics, targets: [.Client.analytics]),
    .library(name: .appsFlyer, targets: [.appsFlyer]),
    .library(name: .avFoundationExt, targets: [.avFoundationExt]),
    .library(name: "ComposableArchitectureExt", targets: ["ComposableArchitectureExt"]),
    .library(name: .concurrencyExt, targets: [.concurrencyExt]),
    .library(name: .Client.facebook, targets: [.Client.facebook]),
    .library(name: .firebaseClient, targets: [.firebaseClient]),
    .library(name: "FeedbackGenerator", targets: ["FeedbackGenerator"]),
    .library(name: .foundationSupport, targets: [.foundationSupport]),
    .library(name: "GraphicsExt", targets: ["GraphicsExt"]),
    .library(name: .instagram, targets: [.instagram]),
    .library(name: .loggingSupport, targets: [.loggingSupport]),
    .library(name: .paywallReducer, targets: [.paywallReducer]),
    .library(name: .photosExt, targets: [.photosExt]),
    .library(name: .sfSymbol, targets: [.sfSymbol]),
    .library(name: .Client.photosAuthorization, targets: [.Client.photosAuthorization]),
    .library(name: .Client.purchases, targets: [.Client.purchases]),
    .library(name: "SwiftUIExt", targets: ["SwiftUIExt"]),
    .library(name: "UIKitExt", targets: ["UIKitExt"]),
    .library(name: .userIdentifier, targets: [.userIdentifier]),
    .library(name: .Client.userSettings, targets: [.Client.userSettings]),
    .library(name: .Client.userTracking, targets: [.Client.userTracking]),
    .library(name: .version, targets: [.version]),
    .library(name: .videoPlayer, targets: [.videoPlayer]),
    .library(name: .webView, targets: [.webView])
  ],
  dependencies: [
    .package(
      url: "https://github.com/adaptyteam/AdaptySDK-iOS",
      from: "2.1.0"
    ),
    .package(
      url: "https://github.com/amplitude/Amplitude-iOS",
      from: "8.14.0"
    ),
    .package(
      url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework",
      from: "6.9.0"
    ),
    .package(
      url: "https://github.com/JohnSundell/AsyncCompatibilityKit",
      from: "0.1.2"
    ),
    .package(
      url: "https://github.com/facebook/facebook-ios-sdk",
      from: "15.1.0"
    ),
    .package(
      url: "https://github.com/firebase/firebase-ios-sdk",
      from: "10.2.0"
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
      from: "0.46.0"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-custom-dump",
      from: "0.6.1"
    ),
    // .package(
    //   url: "https://github.com/pointfreeco/swift-identified-collections",
    //   from: "0.5.0"
    // ),
    .package(
      url: "https://github.com/pointfreeco/swift-tagged",
      from: "0.8.0"
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
        .External.dependencies,
        .External.Facebook.core,
        .External.Firebase.analytics,
        .External.tagged
      ]
    ),
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
        .External.composableArchitecture,
        .External.dependencies,
        .External.Facebook.core
      ]
    ),
    .target(
      name: "FeedbackGenerator",
      dependencies: [
        .External.composableArchitecture,
        .External.dependencies
      ]
    ),
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
        .External.customDump,
        .External.tagged
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
        .External.dependencies,
        .External.tagged
      ],
      linkerSettings: [
        .linkedFramework("Photos")
      ]
    ),
    .target(
      name: .Client.purchases,
      dependencies: [
        "ComposableArchitectureExt",
        .Client.analytics,
        .foundationSupport,
        .loggingSupport,
        .userIdentifier,
        .External.adapty,
        .External.asyncCompatibilityKit,
        .External.composableArchitecture,
        .External.dependencies,
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
        .External.composableArchitecture,
        .External.dependencies,
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
        .External.dependencies,
        .External.Facebook.core
      ],
      linkerSettings: [
        .linkedFramework("AppTrackingTransparency")
      ]
    ),
    .amplitudeClient,
    .appsFlyer,
    .foundationSupport,
    .firebaseClient,
    .loggingSupport,
    .paywallReducer,
    .userIdentifier,
    .version,
    .webView
  ]
)

extension Target {
  static let amplitudeClient = target(
    name: .amplitudeClient,
    dependencies: [
      .loggingSupport,
      .userIdentifier,
      .External.amplitude,
      .External.composableArchitecture,
      .External.dependencies
    ],
    path: "Sources/AmplitudeClient"
  )

  static let appsFlyer = target(
    name: .appsFlyer,
    dependencies: [
      .loggingSupport,
      .Client.purchases,
      .userIdentifier,
      .External.adapty,
      .External.appsFlyer,
      .External.composableArchitecture,
      .External.dependencies
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

  static let firebaseClient = target(
    name: .firebaseClient,
    dependencies: [
      .loggingSupport,
      .userIdentifier,
      .External.Firebase.analytics,
      .External.Firebase.crashlytics,
      .External.composableArchitecture,
      .External.dependencies
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

  static let paywallReducer = target(
    name: .paywallReducer,
    dependencies: [
      .Client.analytics,
      .Client.purchases,
      .External.composableArchitecture,
    ]
  )

  static let userIdentifier = target(
    name: .userIdentifier,
    dependencies: [
      .External.composableArchitecture,
      .External.dependencies,
      .External.keychainAccess
    ]
  )

  static let version = target(
    name: .version,
    dependencies: [
      .External.composableArchitecture,
      .External.dependencies
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
  static let amplitudeClient = byName(name: .amplitudeClient)
  static let appsFlyer = byName(name: .appsFlyer)
  static let avFoundationExt = byName(name: .avFoundationExt)
  static let concurrencyExt = byName(name: .concurrencyExt)
  static let foundationSupport = byName(name: .foundationSupport)
  static let firebaseClient = byName(name: .firebaseClient)
  static let instagram = byName(name: .instagram)
  static let loggingSupport = byName(name: .loggingSupport)
  static let paywallReducer = byName(name: .paywallReducer)
  static let photosExt = byName(name: .photosExt)
  static let sfSymbol = byName(name: .sfSymbol)
  static let userIdentifier = byName(name: .userIdentifier)
  static let version = byName(name: .version)
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

    static let dependencies = product(
      name: "Dependencies",
      package: "swift-composable-architecture"
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

    // static let identifiedCollections = product(
    //     name: "IdentifiedCollections",
    //     package: "swift-identified-collections"
    //   )

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
  static let amplitudeClient = "AmplitudeClient"
  static let appsFlyer = "AppsFlyer"
  static let version = "Version"
  static let avFoundationExt = "AVFoundationExt"
  static let concurrencyExt = "ConcurrencyExt"
  static let foundationSupport = "FoundationSupport"
  static let firebaseClient = "FirebaseClient"
  static let instagram = "Instagram"
  static let loggingSupport = "LoggingSupport"
  static let paywallReducer = "PaywallReducer"
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
