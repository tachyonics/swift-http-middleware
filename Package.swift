// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-http-client-middleware",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .watchOS(.v6), .tvOS(.v13)
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
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "HttpMiddleware", dependencies: [
            ]),
        .target(
            name: "HttpClientMiddleware", dependencies: [
                .target(name: "HttpMiddleware")
            ]),
        .target(
            name: "HttpServerMiddleware", dependencies: [
                .target(name: "HttpMiddleware")
            ]),
        .target(
            name: "StandardHttpClientMiddleware", dependencies: [
                .target(name: "HttpClientMiddleware")
            ]),
        .target(
            name: "StandardHttpServerMiddleware", dependencies: [
                .target(name: "HttpServerMiddleware")
            ]),
    ],
    swiftLanguageVersions: [.v5]
)
