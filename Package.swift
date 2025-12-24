// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "PanelKit",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "PanelKit",
            targets: ["PanelKit"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PanelKit",
            dependencies: []),
    ]
)
