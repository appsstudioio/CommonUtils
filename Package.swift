// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CommonUtils",
    defaultLocalization: "ko",
    platforms: [.iOS(.v13), .macOS(.v10_14), .tvOS(.v13), .watchOS(.v5)],
    products: [
        .library(
            name: "CommonUtils",
            targets: ["CommonUtils"]),
    ],
    targets: [
        .target(
            name: "CommonUtils", 
            resources: [.process("Resources")]),
        .testTarget(
            name: "CommonUtilsTests",
            dependencies: ["CommonUtils"]),
    ],
    swiftLanguageVersions: [.v5]
)
