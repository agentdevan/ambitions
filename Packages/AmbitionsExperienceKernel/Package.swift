// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AmbitionsExperienceKernel",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [
        .library(name: "AmbitionsExperienceKernel", targets: ["AmbitionsExperienceKernel"])
    ],
    targets: [
        .target(
            name: "AmbitionsExperienceKernel",
            exclude: ["Resources/AmbitionsExperienceTokens.xcassets"],
            resources: [
                .process("Resources/Tokens"),
                .process("Resources/Manifests")
            ]
        ),
        .testTarget(
            name: "AmbitionsExperienceKernelTests",
            dependencies: ["AmbitionsExperienceKernel"]
        )
    ]
)
