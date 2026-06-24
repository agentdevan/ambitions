// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AmbitionsNativeMCP",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .executable(name: "ambitions-native-mcp", targets: ["AmbitionsNativeMCP"]),
    ],
    dependencies: [
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.11.0"),
    ],
    targets: [
        .target(
            name: "AmbitionsNativeMCPCore",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk"),
            ]
        ),
        .executableTarget(
            name: "AmbitionsNativeMCP",
            dependencies: ["AmbitionsNativeMCPCore"]
        ),
        .testTarget(
            name: "AmbitionsNativeMCPTests",
            dependencies: ["AmbitionsNativeMCPCore"]
        ),
    ]
)
