// swift-tools-version:5.10

import PackageDescription

let package = Package(
  name: "Untitled",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
    .macOS(.v13)
  ],
  products: [
    .library(name: .AutoPresentation.rateUs, targets: [.AutoPresentation.rateUs]),

    .library(name: .Client.analytics, targets: [.Client.analytics]),
    .library(name: .Client.application, targets: [.Client.application]),
    .library(name: .Client.appMetrica, targets: [.Client.appMetrica]),
    .library(name: .Client.autoPresentation, targets: [.Client.autoPresentation]),
    .library(name: .Client.connectivity, targets: [.Client.connectivity]),
    .library(name: .Client.facebook, targets: [.Client.facebook]),
    .library(name: .Client.feedback, targets: [.Client.feedback]),
    .library(name: .Client.firebase, targets: [.Client.firebase]),
    .library(name: .Client.instagramSharing, targets: [.Client.instagramSharing]),
    .library(name: .Client.pasteboard, targets: [.Client.pasteboard]),
    .library(name: .Client.photosAuthorization, targets: [.Client.photosAuthorization]),
    .library(name: .Client.purchases, targets: [.Client.purchases]),
    .library(name: .Client.purchasesOffers, targets: [.Client.purchasesOffers]),
    .library(name: .Client.remoteSettings, targets: [.Client.remoteSettings]),
    .library(name: .Client.userAttribution, targets: [.Client.userAttribution]),
    .library(name: .Client.userIdentifier, targets: [.Client.userIdentifier]),
    .library(name: .Client.userSession, targets: [.Client.userSession]),
    .library(name: .Client.userSettings, targets: [.Client.userSettings]),
    .library(name: .Client.userTracking, targets: [.Client.userTracking]),

    .library(name: .Composable.connectivity, targets: [.Composable.connectivity]),
    .library(name: .Composable.paywall, targets: [.Composable.paywall]),
    .library(name: .Composable.photos, targets: [.Composable.photos]),
    .library(name: .Composable.photosAuthorization, targets: [.Composable.photosAuthorization]),
    .library(name: .Composable.purchases, targets: [.Composable.purchases]),
    .library(name: .Composable.remoteSettings, targets: [.Composable.remoteSettings]),
    .library(name: .Composable.userSession, targets: [.Composable.userSession]),

    .library(name: .Dependencies.paywall, targets: [.Dependencies.paywall]),

    .library(name: .Feature.rateUs, targets: [.Feature.rateUs]),

    .library(name: .avFoundation, targets: [.avFoundation]),
    .library(name: .composableArchitecture, targets: [.composableArchitecture]),
    .library(name: .concurrency, targets: [.concurrency]),
    .library(name: .core, targets: [.core]),
    .library(name: .coreImage, targets: [.coreImage]),
    .library(name: .dependencies, targets: [.dependencies]),
    .library(name: .foundation, targets: [.foundation]),
    .library(name: .graphics, targets: [.graphics]),
    .library(name: .logging, targets: [.logging]),
    .library(name: .photos, targets: [.photos]),
    .library(name: .photosUI, targets: [.photosUI]),
    .library(name: .purchases, targets: [.purchases]),
    .library(name: .purchasesCore, targets: [.purchasesCore]),
    .library(name: .sfSymbol, targets: [.sfSymbol]),
    .library(name: .swiftUI, targets: [.swiftUI]),
    .library(name: .uiKit, targets: [.uiKit]),
    .library(name: .videoPlayer, targets: [.videoPlayer]),
    .library(name: .webView, targets: [.webView])
  ],
  dependencies: [
    .package(
      url: "https://github.com/adaptyteam/AdaptySDK-iOS",
      from: "3.8.0"
    ),
    .package(
      url: "https://github.com/appmetrica/appmetrica-sdk-ios",
      from: "5.11.0"
    ),
    .package(
      url: "https://github.com/rwbutler/Connectivity",
      from: "8.0.0"
    ),
    .package(
      url: "https://github.com/devicekit/DeviceKit",
      from: "5.6.0"
    ),
    .package(
      url: "https://github.com/facebook/facebook-ios-sdk",
      from: "18.0.0"
    ),
    .package(
      url: "https://github.com/firebase/firebase-ios-sdk",
      from: "11.13.0"
    ),
    .package(
      url: "https://github.com/kishikawakatsumi/KeychainAccess",
      from: "4.2.2"
    ),
    .package(
      url: "https://github.com/apple/swift-collections",
      from: "1.1.4"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "1.18.0"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-concurrency-extras",
      from: "1.3.1"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-custom-dump",
      from: "1.3.3"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-dependencies",
      from: "1.8.1"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-sharing",
      from: "2.3.3"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-tagged",
      from: "0.10.0"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-navigation",
      from: "2.3.0"
    )
  ],
  targets: [
    .target(
      name: .composableArchitecture,
      dependencies: [
        .dependencies,
        .swiftUI,
        .External.composableArchitecture,
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

    .core,
    .dependencies,
    .foundation,
    .logging,
    .photos,
    .photosUI,
    .purchases,
    .purchasesCore,
    .swiftUI,
    .uiKit,
    .webView,

    .AutoPresentation.rateUs,

    .Client.analytics,
    .Client.application,
    .Client.appMetrica,
    .Client.autoPresentation,
    .Client.connectivity,
    .Client.facebook,
    .Client.feedback,
    .Client.firebase,
    .Client.instagramSharing,
    .Client.pasteboard,
    .Client.photosAuthorization,
    .Client.purchases,
    .Client.purchasesOffers,
    .Client.remoteSettings,
    .Client.userAttribution,
    .Client.userIdentifier,
    .Client.userSession,
    .Client.userSettings,
    .Client.userTracking,

    .Composable.connectivity,
    .Composable.paywall,
    .Composable.photos,
    .Composable.photosAuthorization,
    .Composable.purchases,
    .Composable.remoteSettings,
    .Composable.userSession,

    .Dependencies.paywall,

    .Feature.rateUs,
  ]
)

extension Target {
  enum AutoPresentation {
    static let rateUs = target(
      name: .AutoPresentation.rateUs,
      dependencies: [
        .Client.autoPresentation,
        .Client.remoteSettings,
        .Client.userSettings,
        .Composable.remoteSettings,
      ],
      path: "Sources/AutoPresentationRateUs"
    )
  }

  enum Client {
    static let analytics = target(
      name: .Client.analytics,
      dependencies: [
        .core,
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

    static let autoPresentation = target(
      name: .Client.autoPresentation,
      dependencies: [
        .core,
        .dependencies,
        .logging,
        .Client.userSession,
        .Client.userSettings,
        .External.Collections.orderedCollections,
        .External.composableArchitecture,
        .External.dependencies,
        .External.Dependencies.macros,
      ],
      path: "Sources/AutoPresentationClient"
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
        .External.dependencies,
        .External.Dependencies.macros
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
        .foundation,
        .logging,
        .purchasesCore,
        .Client.analytics,
        .Client.remoteSettings,
        .Client.userIdentifier,
        .Client.userSettings,
        .External.adapty,
        .External.dependencies,
        .External.Dependencies.macros,
        .External.tagged
      ],
      path: "Sources/PurchasesClient",
      linkerSettings: [
        .linkedFramework("Combine"),
        .linkedFramework("StoreKit")
      ]
    )

    static let purchasesOffers = target(
      name: .Client.purchasesOffers,
      dependencies: [
        .External.dependencies,
        .External.Dependencies.macros,
        .dependencies,
        .logging,
        .Client.purchases,
        .Client.remoteSettings,
        .Dependencies.paywall
      ],
      path: "Sources/PurchasesOffersClient"
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

    static let userAttribution = target(
      name: .Client.userAttribution,
      dependencies: [
        .External.dependencies,
        .External.Dependencies.macros
      ],
      path: "Sources/UserAttributionClient"
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

    static let userSession = target(
      name: .Client.userSession,
      dependencies: [
        .core,
        .dependencies,
        .External.dependencies,
        .External.Dependencies.macros,
        .External.keychainAccess
      ],
      path: "Sources/UserSessionClient"
    )

    static let userSettings = target(
      name: .Client.userSettings,
      dependencies: [
        .core,
        .External.dependencies,
        .External.Dependencies.macros
      ],
      path: "Sources/UserSettings"
    )

    static let userTracking = target(
      name: .Client.userTracking,
      dependencies: [
        .Client.analytics,
        .External.adapty,
        .External.dependencies,
        .External.Dependencies.macros,
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
        .External.sharing,
      ],
      path: "Sources/ConnectivityComposable"
    )

    static let paywall = target(
      name: .Composable.paywall,
      dependencies: [
        .composableArchitecture,
        .purchases,
        .Client.analytics,
        .Client.purchasesOffers,
        .Composable.remoteSettings,
        .Dependencies.paywall,
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
        .External.composableArchitecture,
        .External.sharing,
      ],
      path: "Sources/PhotosComposable"
    )

    static let photosAuthorization = target(
      name: .Composable.photosAuthorization,
      dependencies: [
        .photosUI,
        .Client.photosAuthorization,
        .External.sharing,
      ],
      path: "Sources/PhotosAuthorizationComposable"
    )

    static let purchases = target(
      name: .Composable.purchases,
      dependencies: [
        .Client.purchases,
        .Client.purchasesOffers,
        .Composable.remoteSettings,
        .External.sharing,
      ],
      path: "Sources/PurchasesComposable"
    )

    static let remoteSettings = target(
      name: .Composable.remoteSettings,
      dependencies: [
        .Client.remoteSettings,
        .External.sharing,
      ],
      path: "Sources/RemoteSettingsComposable"
    )

    static let userSession = target(
      name: .Composable.userSession,
      dependencies: [
        .Client.userSession,
        .External.sharing,
      ],
      path: "Sources/UserSessionComposable"
    )
  }

  enum Dependencies {
    static let paywall = target(
      name: .Dependencies.paywall,
      dependencies: [
        .core,
        .purchasesCore,
        .External.dependencies,
      ],
      path: "Sources/PaywallDependencies"
    )
  }

  enum Feature {
    static let rateUs = target(
      name: .Feature.rateUs,
      dependencies: [
        .dependencies,
        .foundation,
        .purchases,
        .swiftUI,
        .External.composableArchitecture,
        .Client.analytics,
      ],
      path: "Sources/RateUsFeature"
    )
  }

  static let core = target(
    name: .core,
    dependencies: [
      .External.composableArchitecture,
      .External.tagged
    ],
    path: "Sources/Core"
  )

  static let dependencies = target(
    name: .dependencies,
    dependencies: [
      .core,
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

  static let purchases = target(
    name: .purchases,
    dependencies: [
      .purchasesCore,
      .Client.purchases,
      .Client.purchasesOffers,
      .Composable.purchases,
    ],
    path: "Sources/Purchases"
  )

  static let purchasesCore = target(
    name: .purchasesCore,
    dependencies: [
      .foundation,
      .Client.remoteSettings,
      .External.adapty,
      .External.tagged
    ],
    path: "Sources/PurchasesCore",
    exclude: ["swiftgen.yml"],
    resources: [
      .process("Resources")
    ],
    linkerSettings: [
      .linkedFramework("StoreKit")
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
  static let core = byName(name: .core)
  static let coreImage = byName(name: .coreImage)
  static let dependencies = byName(name: .dependencies)
  static let foundation = byName(name: .foundation)
  static let graphics = byName(name: .graphics)
  static let instagram = byName(name: .instagramSharing)
  static let logging = byName(name: .logging)
  static let photos = byName(name: .photos)
  static let photosUI = byName(name: .photosUI)
  static let purchases = byName(name: .purchases)
  static let purchasesCore = byName(name: .purchasesCore)
  static let sfSymbol = byName(name: .sfSymbol)
  static let swiftUI = byName(name: .swiftUI)
  static let uiKit = byName(name: .uiKit)
  static let videoPlayer = byName(name: .videoPlayer)
  static let webView = byName(name: .webView)

  enum AutoPresentation {
    static let rateUs = byName(name: .AutoPresentation.rateUs)
  }

  enum Client {
    static let analytics = byName(name: .Client.analytics)
    static let application = byName(name: .Client.application)
    static let appMetrica = byName(name: .Client.appMetrica)
    static let autoPresentation = byName(name: .Client.autoPresentation)
    static let connectivity = byName(name: .Client.connectivity)
    static let facebook = byName(name: .Client.facebook)
    static let feedbackGenerator = byName(name: .Client.feedback)
    static let firebase = byName(name: .Client.firebase)
    static let instagramSharing = byName(name: .Client.instagramSharing)
    static let pasteboard = byName(name: .Client.pasteboard)
    static let photosAuthorization = byName(name: .Client.photosAuthorization)
    static let purchases = byName(name: .Client.purchases)
    static let purchasesOffers = byName(name: .Client.purchasesOffers)
    static let remoteSettings = byName(name: .Client.remoteSettings)
    static let userAttribution = byName(name: .Client.userAttribution)
    static let userIdentifier = byName(name: .Client.userIdentifier)
    static let userSession = byName(name: .Client.userSession)
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
    static let userSession = byName(name: .Composable.userSession)
  }

  enum Dependencies {
    static let paywall = byName(name: .Dependencies.paywall)
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

    static let sharing = product(
      name: "Sharing",
      package: "swift-sharing"
    )

    static let swiftUINavigation = product(
      name: "SwiftUINavigation",
      package: "swift-navigation"
    )

    static let tagged = product(
      name: "Tagged",
      package: "swift-tagged"
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
  static let core = "DuckCore"
  static let coreImage = "DuckCoreImage"
  static let composableArchitecture = "DuckComposableArchitecture"
  static let dependencies = "DuckDependencies"
  static let foundation = "DuckFoundation"
  static let graphics = "DuckGraphics"
  static let instagramSharing = "Instagram"
  static let logging = "DuckLogging"
  static let photos = "DuckPhotos"
  static let photosUI = "DuckPhotosUI"
  static let purchases = "DuckPurchases"
  static let purchasesCore = "DuckPurchasesCore"
  static let sfSymbol = "SFSymbol"
  static let swiftUI = "DuckSwiftUI"
  static let uiKit = "DuckUIKit"
  static let videoPlayer = "DuckVideoPlayer"
  static let webView = "DuckWebView"

  enum AutoPresentation {
    static let rateUs = "DuckAutoPresentationRateUs"
  }

  enum Client {
    static let analytics = "DuckAnalyticsClient"
    static let application = "DuckApplicationClient"
    static let appMetrica = "DuckAppMetricaClient"
    static let autoPresentation = "DuckAutoPresentationClient"
    static let connectivity = "DuckConnectivityClient"
    static let facebook = "DuckFacebookClient"
    static let feedback = "DuckFeedbackClient"
    static let firebase = "DuckFirebaseClient"
    static let instagramSharing = "DuckInstagramSharingClient"
    static let pasteboard = "DuckPasteboardClient"
    static let photosAuthorization = "DuckPhotosAuthorizationClient"
    static let purchases = "DuckPurchasesClient"
    static let purchasesOffers = "DuckPurchasesOffersClient"
    static let remoteSettings = "DuckRemoteSettingsClient"
    static let userAttribution = "DuckUserAttributionClient"
    static let userIdentifier = "DuckUserIdentifierClient"
    static let userSession = "DuckUserSessionClient"
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
    static let userSession = "DuckUserSessionComposable"
  }

  enum Dependencies {
    static let paywall = "DuckPaywallDependencies"
  }

  enum Feature {
    static let rateUs = "DuckRateUsFeature"
  }
}
