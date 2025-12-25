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
    dependencies: [
        .package(url: "https://github.com/jeffersongreco/VisualEffectKit.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(
            name: "PanelKit",
            dependencies: ["VisualEffectKit"]),
    ]
)
