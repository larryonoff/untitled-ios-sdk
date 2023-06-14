// swift-tools-version:5.8

import PackageDescription

let package = Package(
  name: "Untitled",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v15),
    .macOS(.v12)
  ],
  products: [
    .library(name: .Client.amplitude, targets: [.Client.amplitude]),
    .library(name: .Client.analytics, targets: [.Client.analytics]),
    .library(name: .Client.application, targets: [.Client.application]),
    .library(name: .Client.appsFlyer, targets: [.Client.appsFlyer]),
    .library(name: .Client.connectivity, targets: [.Client.connectivity]),
    .library(name: .Client.facebook, targets: [.Client.facebook]),
    .library(name: .Client.feedbackGenerator, targets: [.Client.feedbackGenerator]),
    .library(name: .Client.firebase, targets: [.Client.firebase]),
    .library(name: .Client.pasteboard, targets: [.Client.pasteboard]),
    .library(name: .Client.photosAuthorization, targets: [.Client.photosAuthorization]),
    .library(name: .Client.purchases, targets: [.Client.purchases]),
    .library(name: .Client.remoteSettings, targets: [.Client.remoteSettings]),
    .library(name: .Client.userIdentifier, targets: [.Client.userIdentifier]),
    .library(name: .Client.userSettings, targets: [.Client.userSettings]),
    .library(name: .Client.userTracking, targets: [.Client.userTracking]),
    .library(name: .avFoundation, targets: [.avFoundation]),
    .library(name: .composableArchitectureExt, targets: [.composableArchitectureExt]),
    .library(name: .concurrency, targets: [.concurrency]),
    .library(name: .dependencies, targets: [.dependencies]),
    .library(name: .foundation, targets: [.foundation]),
    .library(name: .graphics, targets: [.graphics]),
    .library(name: .instagram, targets: [.instagram]),
    .library(name: .logging, targets: [.logging]),
    .library(name: .paywallReducer, targets: [.paywallReducer]),
    .library(name: .photos, targets: [.photos]),
    .library(name: .sfSymbol, targets: [.sfSymbol]),
    .library(name: .swiftUI, targets: [.swiftUI]),
    .library(name: .uiKit, targets: [.uiKit]),
    .library(name: .videoPlayer, targets: [.videoPlayer]),
    .library(name: .webView, targets: [.webView])
  ],
  dependencies: [
    .package(
      url: "https://github.com/adaptyteam/AdaptySDK-iOS",
      from: "2.6.0"
    ),
    .package(
      url: "https://github.com/amplitude/Amplitude-iOS",
      from: "8.16.0"
    ),
    .package(
      url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework",
      from: "6.11.2"
    ),
    .package(
      url: "https://github.com/rwbutler/Connectivity",
      from: "6.0.0"
    ),
    .package(
      url: "https://github.com/devicekit/DeviceKit",
      from: "5.0.0"
    ),
    .package(
      url: "https://github.com/facebook/facebook-ios-sdk",
      from: "16.1.0"
    ),
    .package(
      url: "https://github.com/firebase/firebase-ios-sdk",
      from: "10.11.0"
    ),
    .package(
      url: "https://github.com/kishikawakatsumi/KeychainAccess",
      from: "4.2.2"
    ),
    .package(
      url: "https://github.com/apple/swift-collections",
      from: "1.0.4"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      .upToNextMinor(from: "0.53.2")
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-custom-dump",
      from: "0.10.3"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-dependencies",
      from: "0.5.0"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-tagged",
      from: "0.10.0"
    ),
    .package(
      url:"https://github.com/shaps80/SwiftUIBackports",
      from: "2.7.0"
    ),
    .package(
      url: "https://github.com/MarcoEidinger/URLCompatibilityKit",
      from: "1.0.0"
    )
  ],
  targets: [
    .target(
      name: .composableArchitectureExt,
      dependencies: [
        .External.composableArchitecture,
        .swiftUI
      ]
    ),
    .target(
      name: .avFoundation,
      path: "Sources/AVFoundation",
      linkerSettings: [
        .linkedFramework("AVFoundation")
      ]
    ),
    .target(
      name: .concurrency,
      path: "Sources/Concurrency",
      linkerSettings: [
        .linkedFramework("Combine")
      ]
    ),
    .target(
      name: .graphics,
      path: "Sources/Graphics"
    ),
    .target(
      name: .instagram,
      dependencies: [
        .External.customDump
      ]
    ),
    .target(name: .sfSymbol),
    .target(
      name: .photos,
      dependencies: [
        .graphics,
        .uiKit,
        .External.composableArchitecture,
        .External.customDump,
        .External.dependencies,
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
        .Client.analytics,
        .foundation,
        .logging,
        .Client.userIdentifier,
        .External.adapty,
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
      name: .swiftUI,
      dependencies: [
        .graphics,
        .External.composableArchitecture,
        .External.swiftUIBackports
      ],
      path: "Sources/SwiftUI"
    ),
    .target(
      name: .uiKit,
      path: "Sources/UIKit"
    ),
    .target(
      name: .Client.userSettings,
      dependencies: [
        .External.dependencies
      ]
    ),
    .target(
      name: .videoPlayer,
      dependencies: [
        .swiftUI
      ],
      linkerSettings: [
        .linkedFramework("AVKit")
      ]
    ),
    .Client.amplitude,
    .Client.analytics,
    .Client.application,
    .Client.appsFlyer,
    .Client.connectivity,
    .Client.facebook,
    .Client.feedbackGenerator,
    .Client.firebase,
    .Client.pasteboard,
    .Client.remoteSettings,
    .Client.userIdentifier,
    .Client.userTracking,
    .dependencies,
    .foundation,
    .logging,
    .paywallReducer,
    .webView
  ]
)

extension Target {
  enum Client {
    static let amplitude = target(
      name: .Client.amplitude,
      dependencies: [
        .logging,
        .Client.userIdentifier,
        .External.amplitude,
        .External.dependencies
      ],
      path: "Sources/AmplitudeClient"
    )

    static let analytics = target(
      name: .Client.analytics,
      dependencies: [
        .foundation,
        .External.amplitude,
        .External.dependencies,
        .External.Facebook.core,
        .External.Firebase.analytics,
        .External.tagged
      ]
    )

    static let application = target(
      name: .Client.application,
      dependencies: [
        .logging,
        .External.dependencies
      ],
      path: "Sources/ApplicationClient"
    )

    static let appsFlyer = target(
      name: .Client.appsFlyer,
      dependencies: [
        .concurrency,
        .logging,
        .Client.purchases,
        .Client.userIdentifier,
        .External.adapty,
        .External.appsFlyer,
        .External.dependencies
      ],
      path: "Sources/AppsFlyer",
      linkerSettings: [
        .linkedFramework("AppTrackingTransparency")
      ]
    )

    static let connectivity = target(
      name: .Client.connectivity,
      dependencies: [
        .logging,
        .External.connectivity,
        .External.dependencies
      ],
      path: "Sources/ConnectivityClient"
    )

    static let facebook = target(
      name: .Client.facebook,
      dependencies: [
        .External.dependencies,
        .External.Facebook.core
      ]
    )

    static let feedbackGenerator = target(
      name: "FeedbackGenerator",
      dependencies: [
        .External.dependencies
      ]
    )

    static let firebase = target(
      name: .Client.firebase,
      dependencies: [
        .logging,
        .Client.userIdentifier,
        .External.Firebase.analytics,
        .External.Firebase.crashlytics,
        .External.dependencies
      ]
    )

    static let pasteboard = target(
      name: .Client.pasteboard,
      dependencies: [
        .logging,
        .External.dependencies
      ],
      path: "Sources/PasteboardClient",
      linkerSettings: [
        .linkedFramework("UIKit")
      ]
    )

    static let remoteSettings = target(
      name: .Client.remoteSettings,
      dependencies: [
        .logging,
        .External.dependencies,
        .External.Firebase.remoteConfig
      ],
      path: "Sources/RemoteSettingsClient",
      linkerSettings: [
        .linkedFramework("UIKit")
      ]
    )

    static let userIdentifier = target(
      name: .Client.userIdentifier,
      dependencies: [
        .External.dependencies,
        .External.keychainAccess,
        .External.tagged
      ]
    )

    static let userTracking  = target(
      name: .Client.userTracking,
      dependencies: [
        .Client.analytics,
        .External.adapty,
        .External.amplitude,
        .External.dependencies,
        .External.Firebase.analytics,
        .External.Facebook.core
      ],
      linkerSettings: [
        .linkedFramework("AdServices"),
        .linkedFramework("AdSupport"),
        .linkedFramework("AppTrackingTransparency")
      ]
    )
  }

  static let dependencies = target(
    name: .dependencies,
    dependencies: [
      .External.dependencies,
      .External.deviceKit
    ],
    path: "Sources/Dependencies"
  )

  static let foundation = target(
    name: .foundation,
    dependencies: [
      .External.urlCompatibilityKit
    ],
    path: "Sources/Foundation"
  )

  static let logging = target(
    name: .logging,
    dependencies: [
      .External.customDump
    ],
    path: "Sources/Logging",
    linkerSettings: [
      .linkedFramework("OSLog")
    ]
  )

  static let paywallReducer = target(
    name: .paywallReducer,
    dependencies: [
      .Client.analytics,
      .Client.purchases,
      .composableArchitectureExt,
      .External.composableArchitecture
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
  static let avFoundation = byName(name: .avFoundation)
  static let composableArchitectureExt = byName(name: .composableArchitectureExt)
  static let concurrency = byName(name: .concurrency)
  static let dependenciesExt = byName(name: .dependencies)
  static let foundation = byName(name: .foundation)
  static let graphics = byName(name: .graphics)
  static let instagram = byName(name: .instagram)
  static let logging = byName(name: .logging)
  static let paywallReducer = byName(name: .paywallReducer)
  static let photosExt = byName(name: .photos)
  static let sfSymbol = byName(name: .sfSymbol)
  static let swiftUI = byName(name: .swiftUI)
  static let uiKit = byName(name: .uiKit)
  static let videoPlayer = byName(name: .videoPlayer)
  static let webView = byName(name: .webView)

  enum Client {
    static let amplitude = byName(name: .Client.amplitude)
    static let analytics = byName(name: .Client.analytics)
    static let application = byName(name: .Client.application)
    static let appsFlyer = byName(name: .Client.appsFlyer)
    static let connectivity = byName(name: .Client.connectivity)
    static let facebook = byName(name: .Client.facebook)
    static let feedbackGenerator = byName(name: .Client.feedbackGenerator)
    static let firebase = byName(name: .Client.firebase)
    static let pasteboard = byName(name: .Client.pasteboard)
    static let photosAuthorization = byName(name: .Client.photosAuthorization)
    static let purchases = byName(name: .Client.purchases)
    static let remoteSettings = byName(name: .Client.remoteSettings)
    static let userIdentifier = byName(name: .Client.userIdentifier)
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

    static let connectivity = byName(name: "Connectivity")

    static let customDump = product(
      name: "CustomDump",
      package: "swift-custom-dump"
    )

    static let dependencies = product(
      name: "Dependencies",
      package: "swift-dependencies"
    )

    static let deviceKit = byName(name: "DeviceKit")

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

      static let remoteConfig = product(
        name: "FirebaseRemoteConfigSwift",
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
  static let version = "Version"
  static let avFoundation = "AVFoundationExt"
  static let concurrency = "ConcurrencyExt"
  static let composableArchitectureExt = "ComposableArchitectureExt"
  static let dependencies = "DependenciesExt"
  static let device = "Device"
  static let foundation = "FoundationSupport"
  static let graphics = "GraphicsExt"
  static let instagram = "Instagram"
  static let logging = "LoggingSupport"
  static let paywallReducer = "PaywallReducer"
  static let photos = "PhotosExt"
  static let sfSymbol = "SFSymbol"
  static let swiftUI = "SwiftUIExt"
  static let uiKit = "UIKitExt"
  static let videoPlayer = "VideoPlayer"
  static let webView = "WebView"

  enum Client {
    static let amplitude = "AmplitudeClient"
    static let analytics = "AnalyticsClient"
    static let application = "ApplicationClient"
    static let appsFlyer = "AppsFlyer"
    static let connectivity = "ConnectivityClient"
    static let facebook = "FacebookClient"
    static let feedbackGenerator = "FeedbackGenerator"
    static let firebase = "FirebaseClient"
    static let pasteboard = "PasteboardClient"
    static let photosAuthorization = "PhotosAuthorization"
    static let purchases = "PurchasesClient"
    static let remoteSettings = "RemoteSettingsClient"
    static let userIdentifier = "UserIdentifier"
    static let userSettings = "UserSettings"
    static let userTracking = "UserTracking"
  }
}
