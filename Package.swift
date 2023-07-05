// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "URLQueryEncoder",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "URLQueryEncoder",
            targets: ["URLQueryEncoder"])
    ],
    dependencies: [
        .package(url: "https://github.com/developers-mylermedia/swift-coding-guidelines", from: "1.1.22")
    ],
    targets: [
        .target(
            name: "URLQueryEncoder",
            dependencies: []),
        .testTarget(
            name: "URLQueryEncoderTests",
            dependencies: ["URLQueryEncoder"])
    ])
