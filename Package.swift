// swift-tools-version: 5.9

import PackageDescription

let SwiftBoost: Target.Dependency = .product(name: "SwiftBoost", package: "SwiftBoost")

let package = Package(
    name: "FirebaseWrapper",
    defaultLocalization: "en",
    platforms: [.iOS(.v13), .macCatalyst(.v13), .macOS(.v10_13), .tvOS(.v12), .watchOS(.v7)],
    products: [
        .library(
            name: "FirebaseWrapper",
            targets: ["FirebaseWrapper"]
        ),
        .library(
            name: "FirebaseWrapperRemoteConfig", 
            targets: ["FirebaseWrapperRemoteConfig"]
        ),
        .library(
            name: "FirebaseWrapperAuth",
            targets: ["FirebaseWrapperAuth"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMajor(from: "10.23.0")),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", .upToNextMajor(from: "7.1.0")),
        .package(url: "https://github.com/sparrowcode/SwiftBoost", .upToNextMajor(from: "4.0.9")),
    ],
    targets: [
        .target(
            name: "FirebaseWrapper",
            dependencies: [
                SwiftBoost,
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
            ]
        ),
        .target(
            name: "FirebaseWrapperRemoteConfig",
            dependencies: [
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .target(name: "FirebaseWrapper")
            ]
        ),
        .target(
            name: "FirebaseWrapperAuth",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .target(name: "FirebaseWrapper")
            ]
        )
    ]
)
