// swift-tools-version:5.9

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
    .library(name: .Client.application, targets: [.Client.application]),
    .library(name: .Client.appMetrica, targets: [.Client.appMetrica]),
    .library(name: .Client.connectivity, targets: [.Client.connectivity]),
    .library(name: .Client.facebook, targets: [.Client.facebook]),
    .library(name: .Client.feedback, targets: [.Client.feedback]),
    .library(name: .Client.firebase, targets: [.Client.firebase]),
    .library(name: .Client.instagramSharing, targets: [.Client.instagramSharing]),
    .library(name: .Client.pasteboard, targets: [.Client.pasteboard]),
    .library(name: .Client.photosAuthorization, targets: [.Client.photosAuthorization]),
    .library(name: .Client.purchases, targets: [.Client.purchases]),
    .library(name: .Client.remoteSettings, targets: [.Client.remoteSettings]),
    .library(name: .Client.userIdentifier, targets: [.Client.userIdentifier]),
    .library(name: .Client.userSettings, targets: [.Client.userSettings]),
    .library(name: .Client.userTracking, targets: [.Client.userTracking]),

    .library(name: .Composable.connectivity, targets: [.Composable.connectivity]),
    .library(name: .Composable.paywall, targets: [.Composable.paywall]),
    .library(name: .Composable.photos, targets: [.Composable.photos]),
    .library(name: .Composable.photosAuthorization, targets: [.Composable.photosAuthorization]),
    .library(name: .Composable.purchases, targets: [.Composable.purchases]),
    .library(name: .Composable.remoteSettings, targets: [.Composable.remoteSettings]),

    .library(name: .Feature.rateUs, targets: [.Feature.rateUs]),

    .library(name: .avFoundation, targets: [.avFoundation]),
    .library(name: .composableArchitecture, targets: [.composableArchitecture]),
    .library(name: .concurrency, targets: [.concurrency]),
    .library(name: .coreImage, targets: [.coreImage]),
    .library(name: .dependencies, targets: [.dependencies]),
    .library(name: .foundation, targets: [.foundation]),
    .library(name: .graphics, targets: [.graphics]),
    .library(name: .logging, targets: [.logging]),
    .library(name: .photos, targets: [.photos]),
    .library(name: .photosUI, targets: [.photosUI]),
    .library(name: .sfSymbol, targets: [.sfSymbol]),
    .library(name: .swiftUI, targets: [.swiftUI]),
    .library(name: .uiKit, targets: [.uiKit]),
    .library(name: .videoPlayer, targets: [.videoPlayer]),
    .library(name: .webView, targets: [.webView])
  ],
  dependencies: [
    .package(
      url: "https://github.com/adaptyteam/AdaptySDK-iOS",
      from: "3.0.0"
    ),
    .package(
      url: "https://github.com/rwbutler/Connectivity",
      from: "6.1.1"
    ),
    .package(
      url: "https://github.com/devicekit/DeviceKit",
      from: "5.4.0"
    ),
    .package(
      url: "https://github.com/facebook/facebook-ios-sdk",
      from: "17.0.2"
    ),
    .package(
      url: "https://github.com/firebase/firebase-ios-sdk",
      from: "11.0.0"
    ),
    .package(
      url: "https://github.com/kishikawakatsumi/KeychainAccess",
      from: "4.2.2"
    ),
    .package(
      url: "https://github.com/apple/swift-collections",
      from: "1.1.1"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "1.11.1"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-custom-dump",
      from: "1.3.0"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-dependencies",
      from: "1.3.1"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-tagged",
      from: "0.10.0"
    ),
    .package(
      url:"https://github.com/shaps80/SwiftUIBackports",
      from: "2.8.1"
    ),
    .package(
      url:"https://github.com/pointfreeco/swiftui-navigation",
      from: "1.5.0"
    ),
    .package(
      url: "https://github.com/appmetrica/appmetrica-sdk-ios",
      from: "5.4.0"
    )
  ],
  targets: [
    .target(
      name: .composableArchitecture,
      dependencies: [
        .External.composableArchitecture,
        .swiftUI
      ],
      path: "Sources/ComposableArchitecture"
    ),
    .target(
      name: .coreImage,
      dependencies: [],
      path: "Sources/CoreImage"
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
    .target(name: .sfSymbol),
    .target(
      name: .videoPlayer,
      dependencies: [
        .swiftUI
      ],
      path: "Sources/VideoPlayer",
      linkerSettings: [
        .linkedFramework("AVKit")
      ]
    ),
    .photos,
    .photosUI,
    .swiftUI,
    .uiKit,
    .Client.analytics,
    .Client.application,
    .Client.appMetrica,
    .Client.connectivity,
    .Client.facebook,
    .Client.feedback,
    .Client.firebase,
    .Client.instagramSharing,
    .Client.pasteboard,
    .Client.photosAuthorization,
    .Client.purchases,
    .Client.remoteSettings,
    .Client.userIdentifier,
    .Client.userSettings,
    .Client.userTracking,
    .Composable.connectivity,
    .Composable.paywall,
    .Composable.photos,
    .Composable.photosAuthorization,
    .Composable.purchases,
    .Composable.remoteSettings,
    .Feature.rateUs,
    .dependencies,
    .foundation,
    .logging,
    .webView
  ]
)

extension Target {
  enum Client {
    static let analytics = target(
      name: .Client.analytics,
      dependencies: [
        .foundation,
        .logging,
        .External.dependencies,
        .External.Dependencies.macros,
        .External.tagged
      ],
      path: "Sources/AnalyticsClient"
    )

    static let application = target(
      name: .Client.application,
      dependencies: [
        .logging,
        .External.dependencies
      ],
      path: "Sources/ApplicationClient"
    )

    static let appMetrica = target(
      name: .Client.appMetrica,
      dependencies: [
        .concurrency,
        .dependencies,
        .logging,
        .Client.analytics,
        .Client.userIdentifier,
        .External.dependencies,
        .External.Dependencies.macros,
        .External.AppMetrica.core,
        .External.AppMetrica.crashes
      ],
      path: "Sources/AppMetricaClient"
    )

    static let connectivity = target(
      name: .Client.connectivity,
      dependencies: [
        .logging,
        .External.connectivity,
        .External.dependencies,
        .External.Dependencies.macros
      ],
      path: "Sources/ConnectivityClient"
    )

    static let facebook = target(
      name: .Client.facebook,
      dependencies: [
        .External.dependencies,
        .External.Dependencies.macros,
        .External.Facebook.core
      ],
      path: "Sources/FacebookClient"
    )

    static let feedback = target(
      name: .Client.feedback,
      dependencies: [
        .External.dependencies
      ],
      path: "Sources/FeedbackClient"
    )

    static let firebase = target(
      name: .Client.firebase,
      dependencies: [
        .logging,
        .Client.analytics,
        .Client.userIdentifier,
        .External.Firebase.analytics,
        .External.Firebase.crashlytics,
        .External.dependencies,
        .External.Dependencies.macros
      ],
      path: "Sources/FirebaseClient"
    )

    static let instagramSharing = target(
      name: .Client.instagramSharing,
      dependencies: [
        .External.customDump,
        .External.dependencies
      ],
      path: "Sources/InstagramSharingClient"
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

    static let photosAuthorization = target(
      name: .Client.photosAuthorization,
      dependencies: [
        .logging,
        .External.dependencies,
        .External.Dependencies.macros,
        .External.tagged
      ],
      path: "Sources/PhotosAuthorizationClient",
      linkerSettings: [
        .linkedFramework("Photos")
      ]
    )

    static let purchases = target(
      name: .Client.purchases,
      dependencies: [
        .Client.analytics,
        .Client.remoteSettings,
        .foundation,
        .logging,
        .Client.userIdentifier,
        .External.adapty,
        .External.dependencies,
        .External.tagged
      ],
      path: "Sources/PurchasesClient",
      exclude: ["swiftgen.yml"],
      resources: [
        .process("Resources")
      ],
      linkerSettings: [
        .linkedFramework("Combine"),
        .linkedFramework("StoreKit")
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
      ],
      path: "Sources/UserIdentifier"
    )

    static let userSettings = target(
      name: .Client.userSettings,
      dependencies: [
        .External.dependencies
      ],
      path: "Sources/UserSettings"
    )

    static let userTracking = target(
      name: .Client.userTracking,
      dependencies: [
        .Client.analytics,
        .External.adapty,
        .External.dependencies,
        .External.Firebase.analytics,
        .External.Facebook.core
      ],
      path: "Sources/UserTracking",
      linkerSettings: [
        .linkedFramework("AdServices"),
        .linkedFramework("AdSupport"),
        .linkedFramework("AppTrackingTransparency")
      ]
    )
  }

  enum Composable {
    static let connectivity = target(
      name: .Composable.connectivity,
      dependencies: [
        .Client.connectivity,
        .External.composableArchitecture
      ],
      path: "Sources/ConnectivityComposable"
    )

    static let paywall = target(
      name: .Composable.paywall,
      dependencies: [
        .Client.analytics,
        .Client.purchases,
        .Composable.purchases,
        .Composable.remoteSettings,
        .composableArchitecture,
        .External.composableArchitecture
      ],
      path: "Sources/PaywallReducer",
      exclude: ["swiftgen.yml"],
      resources: [
        .process("Resources")
      ]
    )

    static let photos = target(
      name: .Composable.photos,
      dependencies: [
        .photosUI,
        .External.composableArchitecture
      ],
      path: "Sources/PhotosComposable"
    )

    static let photosAuthorization = target(
      name: .Composable.photosAuthorization,
      dependencies: [
        .photosUI,
        .Client.photosAuthorization,
        .External.composableArchitecture
      ],
      path: "Sources/PhotosAuthorizationComposable"
    )

    static let purchases = target(
      name: .Composable.purchases,
      dependencies: [
        .Client.purchases,
        .External.composableArchitecture
      ],
      path: "Sources/PurchasesComposable"
    )

    static let remoteSettings = target(
      name: .Composable.remoteSettings,
      dependencies: [
        .Client.remoteSettings,
        .External.composableArchitecture
      ],
      path: "Sources/RemoteSettingsComposable"
    )
  }

  enum Feature {
    static let rateUs = target(
      name: .Feature.rateUs,
      dependencies: [
        .dependencies,
        .foundation,
        .swiftUI,
        .External.composableArchitecture,
        .Client.analytics,
        .Client.purchases,
      ],
      path: "Sources/RateUsFeature"
    )
  }

  static let dependencies = target(
    name: .dependencies,
    dependencies: [
      .uiKit,
      .External.composableArchitecture,
      .External.dependencies,
      .External.deviceKit
    ],
    path: "Sources/Dependencies"
  )

  static let foundation = target(
    name: .foundation,
    dependencies: [],
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

  static let photos = target(
    name: .photos,
    dependencies: [
      .graphics,
      .uiKit,
      .External.customDump,
      .External.dependencies,
      .External.tagged
    ],
    path: "Sources/Photos",
    linkerSettings: [
      .linkedFramework("Photos")
    ]
  )

  static let photosUI = target(
    name: .photosUI,
    dependencies: [
      .graphics,
      .photos,
      .uiKit,
      .External.customDump,
      .External.dependencies,
      .External.tagged
    ],
    path: "Sources/PhotosUI",
    linkerSettings: [
      .linkedFramework("Photos"),
      .linkedFramework("PhotosUI")
    ]
  )

  static let swiftUI = target(
    name: .swiftUI,
    dependencies: [
      .graphics,
      .uiKit,
      .External.composableArchitecture,
      .External.swiftUIBackports,
      .External.swiftUINavigation
    ],
    path: "Sources/SwiftUI"
  )

  static let uiKit = target(
    name: .uiKit,
    path: "Sources/UIKit"
  )

  static let webView = target(
    name: .webView,
    path: "Sources/WebView",
    linkerSettings: [
      .linkedFramework("WebKit")
    ]
  )
}

extension Target.Dependency {
  static let avFoundation = byName(name: .avFoundation)
  static let composableArchitecture = byName(name: .composableArchitecture)
  static let concurrency = byName(name: .concurrency)
  static let coreImage = byName(name: .coreImage)
  static let dependencies = byName(name: .dependencies)
  static let foundation = byName(name: .foundation)
  static let graphics = byName(name: .graphics)
  static let instagram = byName(name: .instagramSharing)
  static let logging = byName(name: .logging)
  static let photos = byName(name: .photos)
  static let photosUI = byName(name: .photosUI)
  static let sfSymbol = byName(name: .sfSymbol)
  static let swiftUI = byName(name: .swiftUI)
  static let uiKit = byName(name: .uiKit)
  static let videoPlayer = byName(name: .videoPlayer)
  static let webView = byName(name: .webView)

  enum Client {
    static let analytics = byName(name: .Client.analytics)
    static let application = byName(name: .Client.application)
    static let appMetrica = byName(name: .Client.appMetrica)
    static let connectivity = byName(name: .Client.connectivity)
    static let facebook = byName(name: .Client.facebook)
    static let feedbackGenerator = byName(name: .Client.feedback)
    static let firebase = byName(name: .Client.firebase)
    static let instagramSharing = byName(name: .Client.instagramSharing)
    static let pasteboard = byName(name: .Client.pasteboard)
    static let photosAuthorization = byName(name: .Client.photosAuthorization)
    static let purchases = byName(name: .Client.purchases)
    static let remoteSettings = byName(name: .Client.remoteSettings)
    static let userIdentifier = byName(name: .Client.userIdentifier)
    static let userSettings = byName(name: .Client.userSettings)
    static let userTracking = byName(name: .Client.userTracking)
  }

  enum Composable {
    static let connectivity = byName(name: .Composable.connectivity)
    static let paywall = byName(name: .Composable.paywall)
    static let photos = byName(name: .Composable.photos)
    static let photosAuthorization = byName(name: .Composable.photosAuthorization)
    static let purchases = byName(name: .Composable.purchases)
    static let remoteSettings = byName(name: .Composable.remoteSettings)
  }

  enum Feature {
    static let rateUs = byName(name: .Feature.rateUs)
  }

  enum External {
    static let adapty = product(
      name: "Adapty",
      package: "AdaptySDK-iOS"
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

    enum Dependencies {
      static let macros = product(
        name: "DependenciesMacros",
        package: "swift-dependencies"
      )
    }

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
        name: "FirebaseRemoteConfig",
        package: "firebase-ios-sdk"
      )
    }

    static let keychainAccess = byName(name: "KeychainAccess")

    static let tagged = product(
      name: "Tagged",
      package: "swift-tagged"
    )

    static let swiftUIBackports = byName(name: "SwiftUIBackports")

    static let swiftUINavigation = product(
      name: "SwiftUINavigation",
      package: "swiftui-navigation"
    )

    enum AppMetrica {
      static let core = Target.Dependency.product(
        name: "AppMetricaCore",
        package: "appmetrica-sdk-ios"
      )

      static let crashes = Target.Dependency.product(
        name: "AppMetricaCrashes",
        package: "appmetrica-sdk-ios"
      )
    }
  }
}

extension String {
  static let avFoundation = "DuckAVFoundation"
  static let concurrency = "DuckConcurrency"
  static let coreImage = "DuckCoreImage"
  static let composableArchitecture = "DuckComposableArchitecture"
  static let dependencies = "DuckDependencies"
  static let foundation = "DuckFoundation"
  static let graphics = "DuckGraphics"
  static let instagramSharing = "Instagram"
  static let logging = "DuckLogging"
  static let photos = "DuckPhotos"
  static let photosUI = "DuckPhotosUI"
  static let sfSymbol = "SFSymbol"
  static let swiftUI = "DuckSwiftUI"
  static let uiKit = "DuckUIKit"
  static let videoPlayer = "DuckVideoPlayer"
  static let webView = "DuckWebView"

  enum Client {
    static let analytics = "DuckAnalyticsClient"
    static let application = "DuckApplicationClient"
    static let appMetrica = "DuckAppMetricaClient"
    static let connectivity = "DuckConnectivityClient"
    static let facebook = "DuckFacebookClient"
    static let feedback = "DuckFeedbackClient"
    static let firebase = "DuckFirebaseClient"
    static let instagramSharing = "DuckInstagramSharingClient"
    static let pasteboard = "DuckPasteboardClient"
    static let photosAuthorization = "DuckPhotosAuthorizationClient"
    static let purchases = "DuckPurchasesClient"
    static let remoteSettings = "DuckRemoteSettingsClient"
    static let userIdentifier = "DuckUserIdentifierClient"
    static let userSettings = "DuckUserSettings"
    static let userTracking = "DuckUserTracking"
  }

  enum Composable {
    static let connectivity = "DuckConnectivityComposable"
    static let paywall = "DuckPaywallReducer"
    static let photos = "DuckPhotosComposable"
    static let photosAuthorization = "DuckPhotosAuthorizationComposable"
    static let purchases = "DuckPurchasesComposable"
    static let remoteSettings = "DuckRemoteSettingsComposable"
  }

  enum Feature {
    static let rateUs = "DuckRateUsFeature"
  }
}
