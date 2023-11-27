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
    .library(name: .avFoundation, targets: [.avFoundation]),
    .library(name: .composableArchitecture, targets: [.composableArchitecture]),
    .library(name: .composablePhotos, targets: [.composablePhotos]),
    .library(name: .concurrency, targets: [.concurrency]),
    .library(name: .dependencies, targets: [.dependencies]),
    .library(name: .foundation, targets: [.foundation]),
    .library(name: .graphics, targets: [.graphics]),
    .library(name: .logging, targets: [.logging]),
    .library(name: .paywallReducer, targets: [.paywallReducer]),
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
      from: "2.6.2"
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
      from: "10.12.0"
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
      from: "1.5.0"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-custom-dump",
      from: "1.0.0"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-dependencies",
      from: "1.0.0"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-tagged",
      from: "0.10.0"
    ),
    .package(
      url:"https://github.com/shaps80/SwiftUIBackports",
      from: "2.8.0"
    ),
    .package(
      url: "https://github.com/yandexmobile/metrica-sdk-ios",
      from: "4.5.2"
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
      name: .Client.photosAuthorization,
      dependencies: [
        .External.dependencies,
        .External.tagged
      ],
      path: "Sources/PhotosAuthorization",
      linkerSettings: [
        .linkedFramework("Photos")
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
      name: .videoPlayer,
      dependencies: [
        .swiftUI
      ],
      path: "Sources/VideoPlayer",
      linkerSettings: [
        .linkedFramework("AVKit")
      ]
    ),
    .composablePhotos,
    .photos,
    .photosUI,
    .Client.analytics,
    .Client.application,
    .Client.appMetrica,
    .Client.connectivity,
    .Client.facebook,
    .Client.feedback,
    .Client.firebase,
    .Client.instagramSharing,
    .Client.pasteboard,
    .Client.purchases,
    .Client.remoteSettings,
    .Client.userIdentifier,
    .Client.userSettings,
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
    static let analytics = target(
      name: .Client.analytics,
      dependencies: [
        .foundation,
        .logging,
        .External.dependencies,
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
        .External.Yandex.appMetrica,
        .External.Yandex.appMetricaCrashes
      ],
      path: "Sources/AppMetricaClient"
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
        .External.dependencies
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

    static let purchases = target(
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

  static let composablePhotos = target(
    name: .composablePhotos,
    dependencies: [
      .photosUI,
      .External.composableArchitecture,
    ],
    path: "Sources/ComposablePhotos"
  )

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

  static let paywallReducer = target(
    name: .paywallReducer,
    dependencies: [
      .Client.analytics,
      .Client.purchases,
      .composableArchitecture,
      .External.composableArchitecture
    ],
    path: "Sources/PaywallReducer"
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
  static let composablePhotos = byName(name: .composablePhotos)
  static let concurrency = byName(name: .concurrency)
  static let dependencies = byName(name: .dependencies)
  static let foundation = byName(name: .foundation)
  static let graphics = byName(name: .graphics)
  static let instagram = byName(name: .instagramSharing)
  static let logging = byName(name: .logging)
  static let paywallReducer = byName(name: .paywallReducer)
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

    enum Yandex {
      static let appMetrica = Target.Dependency.product(
        name: "YandexMobileMetrica",
        package: "metrica-sdk-ios"
      )

      static let appMetricaCrashes = Target.Dependency.product(
        name: "YandexMobileMetricaCrashes",
        package: "metrica-sdk-ios"
      )
    }
  }
}

extension String {
  static let avFoundation = "DuckAVFoundation"
  static let concurrency = "DuckConcurrency"
  static let composableArchitecture = "DuckComposableArchitecture"
  static let composablePhotos = "DuckComposablePhotos"
  static let dependencies = "DuckDependencies"
  static let foundation = "DuckFoundation"
  static let graphics = "DuckGraphics"
  static let instagramSharing = "Instagram"
  static let logging = "DuckLogging"
  static let paywallReducer = "DuckPaywallReducer"
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
    static let photosAuthorization = "DuckPhotosAuthorization"
    static let purchases = "DuckPurchasesClient"
    static let remoteSettings = "DuckRemoteSettingsClient"
    static let userIdentifier = "DuckUserIdentifierClient"
    static let userSettings = "DuckUserSettings"
    static let userTracking = "DuckUserTracking"
  }
}
