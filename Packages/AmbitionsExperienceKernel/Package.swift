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
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "AmbitionsExperienceKernelTests",
            dependencies: ["AmbitionsExperienceKernel"]
        )
    ]
)
