// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SingletonWeatherApp",
    dependencies: [
        // No external dependencies for this demo app
    ],
    targets: [
        .executableTarget(
            name: "SingletonWeatherApp",
            dependencies: [],
            path: "Sources"
        )
    ]
)
