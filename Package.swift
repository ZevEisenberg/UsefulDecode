// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UsefulDecode",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "UsefulDecode",
            targets: ["UsefulDecode"]),
    ],
    dependencies: [
        .package(url: "https://github.com/GeorgeLyon/ExfiltratedJSONDecoder.git", .branch("main"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "UsefulDecode",
            dependencies: []),
        .testTarget(
            name: "UsefulDecodeTests",
            dependencies: [
                "UsefulDecode",
                "ExfiltratedJSONDecoder",
            ]),
    ]
)
