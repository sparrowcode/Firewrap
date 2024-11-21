// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Firewrap",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macCatalyst(.v13),
        .macOS(.v10_13),
        .tvOS(.v12),
        .watchOS(.v7),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "FirewrapAuth",
            targets: ["FirewrapAuth"]
        ),
        .library(
            name: "FirewrapDatabase",
            targets: ["FirewrapDatabase"]
        ),
        .library(
            name: "FirewrapRemoteConfig",
            targets: ["FirewrapRemoteConfig"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMajor(from: "11.5.0")),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", .upToNextMajor(from: "8.0.0")),
        .package(url: "https://github.com/sparrowcode/SwiftBoost", .upToNextMajor(from: "4.0.9"))
    ],
    targets: [
        .target(
            name: "Firewrap",
            dependencies: [
                .product(name: "SwiftBoost", package: "SwiftBoost"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
            ]
        ),
        .target(
            name: "FirewrapAuth",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .target(name: "Firewrap")
            ]
        ),
        .target(
            name: "FirewrapDatabase",
            dependencies: [
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .target(name: "Firewrap")
            ]
        ),
        .target(
            name: "FirewrapRemoteConfig",
            dependencies: [
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .target(name: "Firewrap")
            ]
        )
    ]
)
