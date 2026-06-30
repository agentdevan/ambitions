@testable import Ambitions
import XCTest

final class SourceAtlasLocalRuntimeOSOwnershipTests: XCTestCase {
    func testSourceAtlasCanonicalOwnerFilesExistAndOldOwnersAreRemoved() {
        let root = repoRoot()

        for requiredPath in [
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/PublicPackRequestCompiler.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/ManifestVerifier.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SignatureVerifier.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/PublicPackCache.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/FreshnessEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/LastKnownGoodStore.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/R2GatewayClient.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/PublicOnlyFirewall.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasProjection.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasLocalPackCache.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackFetchPipeline.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasRuntimeBridgeReplay.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing SourceAtlas owner file: \(requiredPath)"
            )
        }

        for retiredOwner in [
            "Native/Ambitions/Core/Domain",
            "Native/Ambitions/Core/Persistence",
            "Native/Ambitions/Core/Runtime",
            "Native/AmbitionsTests/Domain",
            "Native/AmbitionsTests/Persistence",
            "Native/AmbitionsTests/Runtime",
        ] {
            let retiredOwnerURL = root.appendingPathComponent(retiredOwner)
            let retainedSourceAtlasFiles = try? FileManager.default.contentsOfDirectory(
                at: retiredOwnerURL,
                includingPropertiesForKeys: nil
            ).filter { url in
                url.lastPathComponent.hasPrefix("SourceAtlas") && url.pathExtension == "swift"
            }

            XCTAssertEqual(
                retainedSourceAtlasFiles ?? [],
                [],
                "Retired SourceAtlas owner still contains SourceAtlas Swift files: \(retiredOwner)"
            )
        }
    }

    private func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
