// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "AmbitionsDesignSystem",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "AmbitionsDesignSystem",
            targets: ["AmbitionsDesignSystem"]
        )
    ],
    targets: [
        .target(
            name: "AmbitionsDesignSystem",
            path: "Sources"
        )
    ]
)
