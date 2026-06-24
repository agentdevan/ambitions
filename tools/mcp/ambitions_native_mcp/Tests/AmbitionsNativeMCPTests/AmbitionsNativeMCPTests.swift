import AmbitionsNativeMCPCore
import Foundation
import Testing

@Test func toolsetParsingUsesExplicitArgument() {
    #expect(Toolset(arguments: ["--toolset", "swift-semantic"]) == .swiftSemantic)
    #expect(Toolset(arguments: ["visual"]) == .visual)
    #expect(Toolset(arguments: []) == .all)
}

@Test func repoPostureKeepsCaptureOutOfTopLevelTabs() throws {
    let context = RepoContext(repoRoot: URL(fileURLWithPath: "/Users/devan/Documents/GitHub/ambitions"))
    let registry = ToolRegistry(context: context, toolset: .repo)
    let output = try registry.call(name: "repo_posture", arguments: [:])

    #expect(output.contains("\"Today\""))
    #expect(output.contains("\"Goals\""))
    #expect(output.contains("\"Time\""))
    #expect(output.contains("\"You\""))
    #expect(output.contains("\"globalComposer\""))
    #expect(!output.contains("Today / Goals / Capture / Time / You"))
}

@Test func claimScanFindsReleaseClaimInTempRepo() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try "This is App Store ready and accessibility compliant.\n".write(
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
