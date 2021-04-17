// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WalletConnector",
    platforms: [.iOS(.v14), .macOS(.v10_14)],
    products: [
        .library(
            name: "WalletConnector",
            targets: ["WalletConnector"]),
        .library(
            name: "WalletConnectorUI",
            targets: ["WalletConnectorUI"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/WalletConnect/WalletConnectSwift.git",
            from: Version(1, 3, 1)),
    ],
    targets: [
        .target(
            name: "WalletConnector",
            dependencies: ["WalletConnectSwift"]),
        .target(
            name: "WalletConnectorUI",
            dependencies: ["WalletConnector"],
            resources: [.process("Resources")]),
        .testTarget(
            name: "WalletConnectorTests",
            dependencies: ["WalletConnector"]),
    ]
)
