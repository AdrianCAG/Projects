// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoffeeShopDecoratorPatternApp",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "CoffeeShopDecoratorPatternApp",
            dependencies: [],
            path: "Sources"
        )
    ]
)
