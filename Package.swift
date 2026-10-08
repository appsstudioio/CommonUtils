// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CommonUtils",
    defaultLocalization: "ko",
    platforms: [.iOS(.v15), .macOS(.v12), .tvOS(.v15), .watchOS(.v9)],
    products: [
        .library(
            name: "CommonUtils",
            targets: ["CommonUtils"]),
    ],
    dependencies: [
        // 패키지 추가
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.3")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/devxoul/Then", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/uwiseone-ios/ProgressHUD", branch: "master"),
        .package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "8.13.0")),
        .package(url: "https://github.com/weichsel/ZIPFoundation", .upToNextMajor(from: "0.9.20"))
    ],
    targets: [
        .target(
            name: "CommonUtils",
            dependencies: [
                "Moya",
                "SnapKit",
                "Then",
                "ProgressHUD",
                "Kingfisher",
                "ZIPFoundation"
            ],
            resources: [.process("Resources")]),
        .testTarget(
            name: "CommonUtilsTests",
            dependencies: ["CommonUtils"],
            resources: [
                .process("TestSampleData")
            ])
    ],
    swiftLanguageModes: [.v5]
)
