// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let swiftSettings: [SwiftSetting] = []

let package = Package(
    name: "swift-http-client-middleware",
    platforms: [
        .macOS(.v13), .iOS(.v16), .watchOS(.v9), .tvOS(.v16)
        ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "HttpMiddleware",
            targets: ["HttpMiddleware"]),
        .library(
            name: "HttpClientMiddleware",
            targets: ["HttpClientMiddleware"]),
        .library(
            name: "HttpServerMiddleware",
            targets: ["HttpServerMiddleware"]),
        .library(
            name: "StandardHttpClientMiddleware",
            targets: ["StandardHttpClientMiddleware"]),
        .library(
            name: "StandardHttpServerMiddleware",
            targets: ["StandardHttpServerMiddleware"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/tachyonics/swift-middleware.git", branch: "static_poc"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "HttpMiddleware", dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "SwiftMiddleware", package: "swift-middleware"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "HttpClientMiddleware", dependencies: [
                .target(name: "HttpMiddleware")
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "HttpServerMiddleware", dependencies: [
                .target(name: "HttpMiddleware"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "StandardHttpClientMiddleware", dependencies: [
                .target(name: "HttpClientMiddleware")
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "StandardHttpServerMiddleware", dependencies: [
                .target(name: "HttpServerMiddleware")
            ],
            swiftSettings: swiftSettings
        ),
    ],
    swiftLanguageVersions: [.v5]
)
