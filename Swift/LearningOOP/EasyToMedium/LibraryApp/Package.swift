// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LibraryApp",
    dependencies: [
        // No external dependencies for this simple app
    ],
    targets: [
        .executableTarget(
            name: "LibraryApp",
            dependencies: [],
            path: "Sources"
        )
    ]
)
