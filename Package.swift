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
