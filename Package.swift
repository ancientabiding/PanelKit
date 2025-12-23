// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "FullScreenPanel",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "FullScreenPanel",
            targets: ["FullScreenPanel"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/euclidaxiom/VisualEffectView.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "FullScreenPanel",
            dependencies: [
                "VisualEffectView"
            ]),
        .executableTarget(
            name: "FullScreenPanelDemo",
            dependencies: ["FullScreenPanel"],
        ),
    ]
)
