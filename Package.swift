// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TokenPeek",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "TokenPeek", targets: ["TokenPeek"])
    ],
    targets: [
        .executableTarget(name: "TokenPeek", path: "Sources")
    ]
)
