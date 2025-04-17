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
    dependencies: [
        // 패키지 추가
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.7.0")),
        .package(url: "https://github.com/devxoul/Then", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/relatedcode/ProgressHUD.git", .upToNextMajor(from: "14.1.3")),
        .package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "8.1.0"))
    ],
    targets: [
        .target(
            name: "CommonUtils",
            dependencies: [
                "Moya",
                "SnapKit",
                "Then",
                "ProgressHUD",
                "Kingfisher"
            ],
            resources: [.process("Resources")]),
        .testTarget(
            name: "CommonUtilsTests",
            dependencies: ["CommonUtils"],
            resources: [
                .process("TestSampleData")
            ])
    ],
    swiftLanguageVersions: [.v5]
)
