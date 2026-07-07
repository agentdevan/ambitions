@testable import Ambitions
import XCTest

final class SourceAtlasPublicPackRefreshTargetRegistryArtifactLoaderTests: XCTestCase {
    func testValidPublicArtifactLoadsRegistryAndPreservesModeSelection() throws {
        let registry = SourceAtlasPublicPackRefreshTargetRegistry(
            entries: [
                entry(
                    id: "z-disabled",
                    status: .disabled,
                    allowedModes: [.activeLifecycle]
                ),
                entry(
                    id: "a-active",
                    status: .active,
                    allowedModes: [.activeLifecycle]
                ),
            ]
        )
        let resolution = try SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader.loadArtifact(
            data: artifactData(registry: registry)
        )

        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.artifactID, "source-atlas-public-refresh-targets.test")
        XCTAssertFalse(resolution.usedFallbackEmptyRegistry)
        XCTAssertEqual(resolution.registry.resolveTargets(for: .activeLifecycle).selectedTargetIDs, ["a-active"])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testMissingDefaultBundleArtifactFallsBackToEmptyRegistry() {
        let resolution = SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader.loadDefaultAppArtifact(
            bundle: Bundle(for: Self.self),
            resourceName: "missing-source-atlas-public-refresh-targets-\(UUID().uuidString)"
        )

        XCTAssertEqual(resolution.issues, [.artifactUnavailable])
        XCTAssertTrue(resolution.usedFallbackEmptyRegistry)
        XCTAssertEqual(resolution.registry.entries, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testInvalidArtifactDataFallsBackToEmptyRegistry() {
        let resolution = SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader.loadArtifact(
            data: Data("{ not json }".utf8)
        )

        XCTAssertEqual(resolution.issues, [.artifactDecodeFailed])
        XCTAssertTrue(resolution.usedFallbackEmptyRegistry)
        XCTAssertEqual(resolution.registry.entries, [])
    }

    func testUnsupportedAndNonPublicArtifactFallsBackToEmptyRegistry() throws {
        let resolution = try SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader.loadArtifact(
            data: artifactData(
                schemaVersion: "9.9.9",
                publicReferenceOnly: false,
                registry: SourceAtlasPublicPackRefreshTargetRegistry(entries: [
                    entry(id: "a-active", status: .active, allowedModes: [.activeLifecycle]),
                ])
            )
        )

        XCTAssertEqual(Set(resolution.issues), [.unsupportedSchemaVersion, .nonPublicArtifact])
        XCTAssertTrue(resolution.usedFallbackEmptyRegistry)
        XCTAssertEqual(resolution.registry.entries, [])
    }

    func testPrivateArtifactMetadataFallsBackBeforeRegistryUse() throws {
        let resolution = try SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader.loadArtifact(
            data: artifactData(
                artifactID: "source-atlas-public-refresh-targets.user_id.private",
                registry: SourceAtlasPublicPackRefreshTargetRegistry(entries: [
                    entry(id: "a-active", status: .active, allowedModes: [.activeLifecycle]),
                ])
            )
        )

        XCTAssertEqual(resolution.issues, [.privateArtifactMetadata])
        XCTAssertTrue(resolution.usedFallbackEmptyRegistry)
        XCTAssertEqual(resolution.registry.entries, [])
        XCTAssertEqual(Set(resolution.egressFindings.map(\.forbiddenToken)), ["user_id"])
    }

    func testUnsafeRegistryTargetFallsBackToEmptyRegistry() throws {
        let registry = SourceAtlasPublicPackRefreshTargetRegistry(
            entries: [
                SourceAtlasPublicPackRefreshTargetRegistryEntry(
                    target: SourceAtlasPublicPackLifecycleRefreshTarget(
                        id: "goal_text-refresh",
                        domainID: "goal_text",
                        channel: "stable",
                        schemaVersion: "1.0.0",
                        appVersion: "1.0",
                        targetPackID: "source-atlas/v1/user_id/private-goal"
                    ),
                    allowedModes: [.activeLifecycle],
                    status: .active
                ),
            ]
        )

        let resolution = try SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader.loadArtifact(
            data: artifactData(registry: registry)
        )

        XCTAssertEqual(resolution.issues, [.unsafeRegistryEntries])
        XCTAssertTrue(resolution.usedFallbackEmptyRegistry)
        XCTAssertEqual(resolution.registry.entries, [])
        XCTAssertTrue(resolution.registryFindings.contains(.init(targetID: "goal_text-refresh", issue: .privateTargetMetadata)))
        XCTAssertTrue(resolution.registryFindings.contains(.init(targetID: "goal_text-refresh", issue: .unsafeManifestRequest)))
        XCTAssertEqual(Set(resolution.egressFindings.map(\.forbiddenToken)), ["goal_text", "user_id"])
    }

    func testFoundryGeneratedTrain24ArtifactLoadsAsReviewRequiredOnly() throws {
        let artifactURL = try Self.repoRoot()
            .appendingPathComponent("tools/source-atlas/generated/native-refresh-registry/train-24-fixture/source-atlas-public-refresh-targets.json")
        let resolution = try SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader.loadArtifact(
            data: Data(contentsOf: artifactURL)
        )

        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.artifactID, "source_atlas_public_refresh_targets.078b393fe1c2f8c0")
        XCTAssertFalse(resolution.usedFallbackEmptyRegistry)
        XCTAssertEqual(resolution.registry.entries.count, 1)
        XCTAssertEqual(resolution.registry.entries.first?.status, .reviewRequired)
        XCTAssertEqual(
            resolution.registry.resolveTargets(for: .startup).selectedTargetIDs,
            []
        )
        XCTAssertEqual(
            resolution.registry.resolveTargets(for: .startup).excludedTargetIDs,
            ["source-atlas-refresh-target.public_civic_requirements.candidate.20260627T000000Z"]
        )
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testBundledProductionStableArtifactLoadsActiveApprovedTargetsFromMainBundle() {
        let resolution = SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader.loadDefaultAppArtifact()

        XCTAssertEqual(resolution.issues, [])
        XCTAssertEqual(resolution.artifactID, "source_atlas_public_refresh_targets.4d61a41e5350290c")
        XCTAssertFalse(resolution.usedFallbackEmptyRegistry)
        XCTAssertEqual(resolution.registry.entries.count, 14)
        XCTAssertEqual(Set(resolution.registry.entries.map(\.status)), [.active])
        XCTAssertEqual(
            Set(resolution.registry.entries.compactMap(\.reviewArtifactID)),
            [
                "tools/source-atlas/generated/r2-owner-approval/train-131-tetradeca-ledger-gated/r2-owner-approval.json",
            ]
        )
        XCTAssertEqual(
            resolution.registry.resolveTargets(for: .startup).selectedTargetIDs,
            [
                "source-atlas-refresh-target.business_entrepreneurship.stable.20260628T000000Z",
                "source-atlas-refresh-target.creative_project_reference.stable.20260628T000000Z",
                "source-atlas-refresh-target.education_credentialing.stable.20260628T000000Z",
                "source-atlas-refresh-target.finance_public_reference.stable.20260628T000000Z",
                "source-atlas-refresh-target.health_wellness_reference.stable.20260628T000000Z",
                "source-atlas-refresh-target.health_wellness_reference_ca_statistics.stable.20260628T000000Z",
                "source-atlas-refresh-target.hobbies_recreation.stable.20260628T000000Z",
                "source-atlas-refresh-target.home_life_admin.stable.20260628T000000Z",
                "source-atlas-refresh-target.occupation_foundation.stable.20260628T000000Z",
                "source-atlas-refresh-target.personal_growth.stable.20260628T000000Z",
                "source-atlas-refresh-target.public_civic_requirements.stable.20260628T041500Z",
                "source-atlas-refresh-target.relationships_family.stable.20260628T000000Z",
                "source-atlas-refresh-target.travel_relocation.stable.20260628T000000Z",
                "source-atlas-refresh-target.volunteering_public_reference.stable.20260628T180600Z",
            ]
        )
        XCTAssertEqual(
            resolution.registry.resolveTargets(for: .startup).excludedTargetIDs,
            []
        )
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }
}

private extension SourceAtlasPublicPackRefreshTargetRegistryArtifactLoaderTests {
    static func repoRoot() throws -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            if FileManager.default.fileExists(atPath: url.appendingPathComponent("project.yml").path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        throw NSError(domain: "SourceAtlasPublicPackRefreshTargetRegistryArtifactLoaderTests", code: 1)
    }

    func artifactData(
        schemaVersion: String = SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader.supportedSchemaVersion,
        artifactID: String = "source-atlas-public-refresh-targets.test",
        publicReferenceOnly: Bool = true,
        registry: SourceAtlasPublicPackRefreshTargetRegistry
    ) throws -> Data {
        let artifact = SourceAtlasPublicPackRefreshTargetRegistryArtifact(
            schemaVersion: schemaVersion,
            artifactID: artifactID,
            createdAt: "2026-06-28T00:00:00Z",
            publicReferenceOnly: publicReferenceOnly,
            registry: registry,
            nonClaims: [
                "not a final user plan",
                "not a Step generator",
                "not legal approval",
            ]
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(artifact)
    }

    func entry(
        id: String,
        status: SourceAtlasPublicPackRefreshTargetRegistryStatus,
        allowedModes: Set<SourceAtlasPublicPackLifecycleRefreshMode>
    ) -> SourceAtlasPublicPackRefreshTargetRegistryEntry {
        SourceAtlasPublicPackRefreshTargetRegistryEntry(
            target: SourceAtlasPublicPackLifecycleRefreshTarget(
                id: id,
                domainID: "sports",
                channel: "stable",
                schemaVersion: "1.0.0",
                appVersion: "1.0",
                publicLocale: "en-US",
                targetPackID: "source-atlas/v1/domain/sports/20260627T000000Z"
            ),
            allowedModes: allowedModes,
            status: status,
            reviewArtifactID: "docs/qa/source-atlas/native/source-atlas-native-public-refresh-registry-artifact-loader-train-23.md",
            nonClaims: [
                "not a final user plan",
                "not a Step generator",
            ]
        )
    }
}
