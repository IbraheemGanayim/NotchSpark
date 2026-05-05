// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "NotchSpark",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "NotchSpark", targets: ["NotchSpark"]),
        .library(name: "NotchSparkCore", targets: ["NotchSparkCore"])
    ],
    targets: [
        .target(name: "NotchSparkCore"),
        .executableTarget(
            name: "NotchSpark",
            dependencies: ["NotchSparkCore"]
        ),
        .testTarget(
            name: "NotchSparkCoreTests",
            dependencies: ["NotchSparkCore"]
        )
    ]
)
