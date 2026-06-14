// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AmbitionsDesignSystem",
    platforms: [
        .iOS(.v26),
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "AmbitionsDesignSystem",
            targets: ["AmbitionsDesignSystem"]
        ),
        .library(
            name: "AmbitionsWidgetUI",
            targets: ["AmbitionsWidgetUI"]
        )
    ],
    targets: [
        .target(
            name: "AmbitionsDesignSystem",
            path: "Sources"
        ),
        .target(
            name: "AmbitionsWidgetUI",
            dependencies: ["AmbitionsDesignSystem"],
            path: "AppUI/Sources"
        )
    ]
)
