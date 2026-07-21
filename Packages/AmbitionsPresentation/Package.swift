// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AmbitionsPresentation",
    platforms: [
        .iOS(.v26),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "AmbitionsPresentationContracts",
            targets: ["AmbitionsPresentationContracts"]
        ),
        .library(
            name: "AmbitionsFlagshipFoundation",
            targets: ["AmbitionsFlagshipFoundation"]
        ),
        .library(
            name: "AmbitionsFlagshipUI",
            targets: ["AmbitionsFlagshipUI"]
        )
    ],
    targets: [
        .target(name: "AmbitionsPresentationContracts"),
        .target(name: "AmbitionsFlagshipFoundation"),
        .target(
            name: "AmbitionsFlagshipUI",
            dependencies: [
                "AmbitionsPresentationContracts",
                "AmbitionsFlagshipFoundation"
            ]
        ),
        .testTarget(
            name: "AmbitionsPresentationContractsTests",
            dependencies: ["AmbitionsPresentationContracts"]
        )
    ]
)
