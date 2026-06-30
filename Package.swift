// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Nab",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "Nab", targets: ["Nab"]),
        .library(name: "NabCore", targets: ["NabCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "2.2.1"),
    ],
    targets: [
        .target(name: "NabCore"),
        .executableTarget(
            name: "Nab",
            dependencies: [
                "NabCore",
                .product(name: "KeyboardShortcuts", package: "KeyboardShortcuts"),
            ]
        ),
        .testTarget(name: "NabCoreTests", dependencies: ["NabCore"]),
    ]
)
