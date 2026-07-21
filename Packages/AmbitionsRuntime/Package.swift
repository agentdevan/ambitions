// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AmbitionsRuntime",
    platforms: [
        .iOS(.v26),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "AmbitionsRuntimeCore",
            targets: ["AmbitionsRuntimeCore"]
        ),
        .library(
            name: "AmbitionsRuntimeSQLite",
            targets: ["AmbitionsRuntimeSQLite"]
        ),
        .library(
            name: "AmbitionsRuntimeTestSupport",
            targets: ["AmbitionsRuntimeTestSupport"]
        )
    ],
    targets: [
        .target(name: "AmbitionsRuntimeCore"),
        .target(
            name: "AmbitionsRuntimeSQLite",
            dependencies: ["AmbitionsRuntimeCore"]
        ),
        .target(
            name: "AmbitionsRuntimeTestSupport",
            dependencies: [
                "AmbitionsRuntimeCore",
                "AmbitionsRuntimeSQLite"
            ]
        ),
        .testTarget(
            name: "AmbitionsRuntimeCoreTests",
            dependencies: ["AmbitionsRuntimeCore"]
        ),
        .testTarget(
            name: "AmbitionsRuntimeIntegrationTests",
            dependencies: [
                "AmbitionsRuntimeCore",
                "AmbitionsRuntimeSQLite"
            ]
        ),
        .testTarget(
            name: "AmbitionsRuntimeTestSupportTests",
            dependencies: [
                "AmbitionsRuntimeCore",
                "AmbitionsRuntimeSQLite",
                "AmbitionsRuntimeTestSupport"
            ]
        )
    ]
)
