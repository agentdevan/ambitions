// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AmbitionsExternalContracts",
    platforms: [
        .iOS(.v26),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "AmbitionsExternalContracts",
            targets: ["AmbitionsExternalContracts"]
        )
    ],
    targets: [
        .target(name: "AmbitionsExternalContracts"),
        .testTarget(
            name: "AmbitionsExternalContractsTests",
            dependencies: ["AmbitionsExternalContracts"]
        )
    ]
)
