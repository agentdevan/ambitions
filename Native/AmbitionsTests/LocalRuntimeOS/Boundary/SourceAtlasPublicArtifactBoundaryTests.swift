@testable import Ambitions
import XCTest

final class SourceAtlasPublicArtifactBoundaryTests: XCTestCase {
    func testObjectKeyLogAndCacheMetadataStayPublicReferenceOnly() throws {
        let objectKey = SourceAtlasPublicArtifactObjectKey(
            channel: "stable",
            packID: "public-sports",
            versionID: "2026-06-public-reference",
            sha256: String(repeating: "b", count: 64)
        )
        let logRecord = SourceAtlasPublicArtifactLogRecord(
            event: "source_atlas_cache_selected",
            packID: "public-sports",
            manifestVersionID: "manifest.v1",
            sourceState: .officialCurrent,
            freshnessState: .current,
            selectedSource: .cached
        )
        let metadata = SourceAtlasPublicArtifactCacheMetadata(
            cacheNamespace: SourceAtlasLocalStorageBoundaryProof.publicReferenceCacheNamespace,
            packID: "public-sports",
            manifestVersionID: "manifest.v1",
            selectedSource: .cached,
            selectedSourceState: .officialCurrent,
            selectedFreshnessState: .current,
            quarantinedSourceCount: 0,
            fallbackTriggered: false
        )

        XCTAssertTrue(objectKey.value.hasPrefix("source-atlas/public/stable/public-sports"))
        XCTAssertEqual(
            SourceAtlasNoPrivateGraphEgressAudit.validate([
                objectKey.egressRecord,
                logRecord.egressRecord,
                metadata.egressRecord,
            ]),
            []
        )

        let encoded = try JSONEncoder().encode(metadata)
        let encodedString = String(data: encoded, encoding: .utf8) ?? ""
        XCTAssertFalse(encodedString.localizedCaseInsensitiveContains("user_id"))
        XCTAssertFalse(encodedString.localizedCaseInsensitiveContains("goal_text"))
        XCTAssertFalse(encodedString.localizedCaseInsensitiveContains("private_graph"))
    }

    func testObjectKeyPrivacyAuditRejectsUserAndAccountSpecificKeys() {
        let invalidRecords = [
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .objectKey,
                identifier: "user-key",
                inspectedValue: "source-atlas/public/stable/user_id-123/private_graph_id/node.json"
            ),
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .logLine,
                identifier: "secret-log",
                inspectedValue: "account_secret=secret goal_text=private"
            ),
        ]

        let findings = SourceAtlasNoPrivateGraphEgressAudit.validate(invalidRecords)
        XCTAssertTrue(findings.contains { $0.surface == .objectKey && $0.forbiddenToken == "user_id" })
        XCTAssertTrue(findings.contains { $0.surface == .objectKey && $0.forbiddenToken == "private_graph_id" })
        XCTAssertTrue(findings.contains { $0.surface == .logLine && $0.forbiddenToken == "account_secret" })
        XCTAssertTrue(findings.contains { $0.surface == .logLine && $0.forbiddenToken == "goal_text" })
    }

    func testLocalStorageBoundarySeparatesSourceAtlasCacheFromPrivateRuntimeStorage() {
        let proof = SourceAtlasLocalStorageBoundaryProof.current

        XCTAssertEqual(proof.validationFailures, [])
        XCTAssertNotEqual(proof.sourceAtlasCacheNamespace, proof.privateRuntimeNamespace)
        XCTAssertEqual(proof.privacyManifestPath, "Native/Ambitions/Resources/PrivacyInfo.xcprivacy")
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repoRoot().appendingPathComponent(proof.privacyManifestPath).path
            )
        )
    }

    func testAccountExportResetSignOutAndDeleteDoNotClaimAccountReadinessOrTreatCacheAsPrivateGraph() {
        let decisions = SourceAtlasAccountBoundaryAction.allCases.map(SourceAtlasAccountCacheBoundaryDecision.decision(for:))

        XCTAssertEqual(decisions.flatMap(\.validationFailures), [])
        XCTAssertTrue(decisions.allSatisfy(\.preservesPublicReferenceCache))
        XCTAssertTrue(decisions.allSatisfy { $0.accountReadinessClaimAllowed == false })
        XCTAssertEqual(
            decisions.first { $0.action == .prepareExport }?.exportsPrivateRuntimeData,
            true
        )
        XCTAssertEqual(
            decisions.first { $0.action == .deleteAccount }?.requiresAccountProviderFlow,
            true
        )
    }

    private func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Resources/PrivacyInfo.xcprivacy")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
