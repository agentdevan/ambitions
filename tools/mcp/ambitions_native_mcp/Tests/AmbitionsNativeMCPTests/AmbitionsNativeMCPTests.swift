import AmbitionsNativeMCPCore
import Foundation
import Testing

private func ambitionsRepoRootForTests() -> URL {
    var url = URL(fileURLWithPath: #filePath)
    for _ in 0..<6 {
        url.deleteLastPathComponent()
    }
    return url
}

@Test func toolsetParsingUsesExplicitArgument() {
    #expect(Toolset(arguments: ["--toolset", "swift-semantic"]) == .swiftSemantic)
    #expect(Toolset(arguments: ["--toolset", "source-atlas"]) == .sourceAtlas)
    #expect(Toolset(arguments: ["visual"]) == .visual)
    #expect(Toolset(arguments: []) == .all)
}

@Test func repoPostureKeepsCaptureOutOfTopLevelTabs() throws {
    let context = RepoContext(repoRoot: ambitionsRepoRootForTests())
    let registry = ToolRegistry(context: context, toolset: .repo)
    let output = try registry.call(name: "repo_posture", arguments: [:])

    #expect(output.contains("\"Today\""))
    #expect(output.contains("\"Goals\""))
    #expect(output.contains("\"Time\""))
    #expect(output.contains("\"You\""))
    #expect(output.contains("\"globalComposer\""))
    #expect(!output.contains("Today / Goals / Capture / Time / You"))
}

@Test func architectureOwnerTreatsCoreRuntimeAsRemovedAndLocalRuntimeOSAsCanonical() throws {
    let context = RepoContext(repoRoot: ambitionsRepoRootForTests())
    let registry = ToolRegistry(context: context, toolset: .repo)
    let removedRuntimePath = ["Native", "Ambitions", "Core", "Runtime", "LifeShapeEngine.swift"].joined(separator: "/")
    let removedRuntimeOwner = "removed " + ["Core", "Runtime"].joined(separator: "/")
    let output = try registry.call(name: "repo_architecture_owner_report", arguments: [
        "paths": .array([
            .string("Native/Ambitions/Core/LocalRuntimeOS/Scheduling/LifeShapeEngine.swift"),
            .string(removedRuntimePath),
        ]),
    ])

    #expect(output.contains("\"owner\" : \"Core/LocalRuntimeOS\""))
    #expect(output.contains("\"status\" : \"canonical runtime authority\""))
    #expect(output.contains("\"owner\" : \"\(removedRuntimeOwner)\""))
    #expect(output.contains("forbidden removed owner after AMB-1730"))
    #expect(output.contains("\"debt\" : true"))
}

@Test func claimScanFindsReleaseClaimInTempRepo() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    let unsupportedClaims = "This is App Store " + "ready and accessibility " + "compliant.\n"
    try unsupportedClaims.write(
        to: root.appendingPathComponent("claim.md"),
        atomically: true,
        encoding: .utf8
    )

    let registry = ToolRegistry(context: RepoContext(repoRoot: root), toolset: .repo)
    let output = try registry.call(name: "repo_claim_scan", arguments: [
        "paths": .array([.string("claim.md")]),
    ])

    #expect(output.contains("\"findingCount\""))
    #expect(output.contains("release_ready"))
    #expect(output.contains("accessibility_claim"))
}

@Test func visualPacketValidatorRequiresImagesAndManifest() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let packet = root.appendingPathComponent("packet")
    try FileManager.default.createDirectory(at: packet, withIntermediateDirectories: true)
    try "{}".write(to: packet.appendingPathComponent("manifest.json"), atomically: true, encoding: .utf8)
    FileManager.default.createFile(atPath: packet.appendingPathComponent("today-empty.png").path, contents: Data())

    let registry = ToolRegistry(context: RepoContext(repoRoot: root), toolset: .visual)
    let output = try registry.call(name: "visual_validate_packet", arguments: [
        "packetPath": .string("packet"),
    ])

    #expect(output.contains("\"validPacketShape\" : true"))
    #expect(output.contains("\"today\" : true"))
}

@Test func sourceAtlasCreatesAndValidatesReferencePack() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try "Official public reference notes for SwiftUI availability review.\n".write(
        to: root.appendingPathComponent("reference.md"),
        atomically: true,
        encoding: .utf8
    )

    let registry = ToolRegistry(context: RepoContext(repoRoot: root), toolset: .sourceAtlas)
    let createOutput = try registry.call(name: "source_atlas_pack_create", arguments: [
        "packID": .string("ios26-swiftui-reference"),
        "versionID": .string("2026-06-24"),
        "displayName": .string("iOS 26 SwiftUI Reference"),
        "outputPath": .string("output/source-atlas/packs/ios26-swiftui-reference.json"),
        "sourcePaths": .array([.string("reference.md")]),
        "sourceURLs": .array([.string("https://developer.apple.com/documentation/swiftui")]),
        "domains": .array([.string("swiftui"), .string("ios26")]),
    ])

    #expect(createOutput.contains("\"packID\" : \"ios26-swiftui-reference\""))
    #expect(FileManager.default.fileExists(atPath: root.appendingPathComponent("output/source-atlas/packs/ios26-swiftui-reference.json").path))

    let validateOutput = try registry.call(name: "source_atlas_pack_validate", arguments: [
        "packPath": .string("output/source-atlas/packs/ios26-swiftui-reference.json"),
    ])

    #expect(validateOutput.contains("\"valid\" : true"))
    #expect(!validateOutput.contains("contains private-boundary trigger"))
}

@Test func sourceAtlasR2ValidationScansGeneratedOutputBundles() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let bundle = root.appendingPathComponent("output/source-atlas/public")
    try FileManager.default.createDirectory(at: bundle, withIntermediateDirectories: true)
    try #"{"manifest": true}"#.write(to: bundle.appendingPathComponent("manifest.json"), atomically: true, encoding: .utf8)
    try "This public bundle accidentally includes calendar data.\n".write(
        to: bundle.appendingPathComponent("unsafe.md"),
        atomically: true,
        encoding: .utf8
    )

    let registry = ToolRegistry(context: RepoContext(repoRoot: root), toolset: .sourceAtlas)
    let output = try registry.call(name: "source_atlas_r2_public_bundle_validate", arguments: [
        "bundlePath": .string("output/source-atlas/public"),
        "bucket": .string("ambitions-reference-packs"),
        "prefix": .string("staging/ios26"),
    ])

    #expect(output.contains("\"fileCount\" : 2"))
    #expect(output.contains("calendar data"))
    #expect(output.contains("\"validForPublicReferenceR2\" : false"))
}

@Test func sourceAtlasFoundryCompilesValidatesAndPlansR2Staging() throws {
    let repoRoot = ambitionsRepoRootForTests()
    let outputRoot = "output/source-atlas/foundry-tests/\(UUID().uuidString)"
    let versionID = "swift-mcp-foundry-test"
    defer {
        try? FileManager.default.removeItem(at: repoRoot.appendingPathComponent(outputRoot))
    }

    let registry = ToolRegistry(context: RepoContext(repoRoot: repoRoot), toolset: .sourceAtlas)
    let status = try registry.call(name: "source_atlas_foundry_status", arguments: [:])
    #expect(status.contains("\"tool\": \"source-atlas-foundry\"") || status.contains("\"tool\" : \"source-atlas-foundry\""))
    #expect(status.contains("pathwaySeedCount"))

    let compileOutput = try registry.call(name: "source_atlas_foundry_compile_bundle", arguments: [
        "versionID": .string(versionID),
        "outputRoot": .string(outputRoot),
        "channel": .string("staging"),
    ])
    #expect(compileOutput.contains("\"packCount\": 2") || compileOutput.contains("\"packCount\" : 2"))

    let bundleRoot = "\(outputRoot)/\(versionID)"
    let validateOutput = try registry.call(name: "source_atlas_foundry_validate_bundle", arguments: [
        "bundleRoot": .string(bundleRoot),
    ])
    #expect(validateOutput.contains("\"valid\": true") || validateOutput.contains("\"valid\" : true"))

    let planOutput = try registry.call(name: "source_atlas_foundry_r2_plan", arguments: [
        "bundleRoot": .string(bundleRoot),
        "bucket": .string("ambitions-source-atlas-staging"),
        "prefix": .string("source-atlas/v1"),
        "channel": .string("staging"),
    ])
    #expect(planOutput.contains("\"validForUpload\": true") || planOutput.contains("\"validForUpload\" : true"))
    #expect(planOutput.contains("/provenance/"))
    #expect(!planOutput.contains("CLOUDFLARE_R2_SECRET_ACCESS_KEY"))
}
