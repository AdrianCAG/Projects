// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "CloudSyncPlatform",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0"),
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.28.0"),
        .package(url: "https://github.com/onevcat/Rainbow.git", from: "4.0.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "2.2.0")
    ],
    targets: [
        .executableTarget(
            name: "CloudSyncPlatform",
            dependencies: [
                "Alamofire",
                "RxSwift",
                .product(name: "RealmSwift", package: "realm-swift"),
                "Rainbow",
                "SwiftyJSON",
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Crypto", package: "swift-crypto")
            ],
            path: "Sources"
        )
    ]
)
