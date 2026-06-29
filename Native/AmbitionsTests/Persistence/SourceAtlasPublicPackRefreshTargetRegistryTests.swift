import XCTest
@testable import Ambitions

final class SourceAtlasPublicPackRefreshTargetRegistryTests: XCTestCase {
    func testActiveTargetsAreStableOrderedAndModeScoped() {
        let registry = SourceAtlasPublicPackRefreshTargetRegistry(
            entries: [
                entry(
                    id: "z-startup-only",
                    status: .active,
                    allowedModes: [.startup]
                ),
                entry(
                    id: "b-active",
                    status: .active,
                    allowedModes: [.activeLifecycle, .background]
                ),
                entry(
                    id: "review-required",
                    status: .reviewRequired,
                    allowedModes: [.activeLifecycle]
                ),
                entry(
                    id: "a-active",
                    status: .active,
                    allowedModes: [.activeLifecycle]
                ),
                entry(
                    id: "disabled",
                    status: .disabled,
                    allowedModes: [.activeLifecycle]
                ),
            ]
        )

        let resolution = registry.resolveTargets(for: .activeLifecycle)

        XCTAssertEqual(resolution.configuredEntryCount, 5)
        XCTAssertEqual(resolution.selectedTargetIDs, ["a-active", "b-active"])
        XCTAssertEqual(
            resolution.excludedTargetIDs,
            ["disabled", "review-required", "z-startup-only"]
        )
        XCTAssertTrue(resolution.findings.contains(.init(targetID: "disabled", issue: .inactiveTarget)))
        XCTAssertTrue(resolution.findings.contains(.init(targetID: "review-required", issue: .inactiveTarget)))
        XCTAssertTrue(resolution.findings.contains(.init(targetID: "z-startup-only", issue: .modeNotAllowed)))
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.lifecycleIssues, [])
        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testPrivateRegistryTargetIsRejectedBeforeSelection() {
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
                    status: .active,
                    reviewArtifactID: "docs/qa/source-atlas/native/source-atlas-native-active-target-approval-gate-train-26.md"
                ),
            ]
        )

        let resolution = registry.resolveTargets(for: .activeLifecycle)

        XCTAssertEqual(resolution.selectedTargetIDs, [])
        XCTAssertEqual(resolution.excludedTargetIDs, ["goal_text-refresh"])
        XCTAssertTrue(resolution.findings.contains(.init(targetID: "goal_text-refresh", issue: .privateTargetMetadata)))
        XCTAssertTrue(resolution.findings.contains(.init(targetID: "goal_text-refresh", issue: .unsafeManifestRequest)))
        XCTAssertEqual(resolution.lifecycleIssues, [.privateTargetMetadata, .unsafeManifestRequest])
        XCTAssertEqual(Set(resolution.egressFindings.map(\.forbiddenToken)), ["goal_text", "user_id"])
    }

    func testActiveTargetWithoutApprovalArtifactIsRejectedBeforeSelection() {
        let registry = SourceAtlasPublicPackRefreshTargetRegistry(
            entries: [
                SourceAtlasPublicPackRefreshTargetRegistryEntry(
                    target: SourceAtlasPublicPackLifecycleRefreshTarget(
                        id: "sports-stable",
                        domainID: "sports",
                        channel: "stable",
                        schemaVersion: "1.0.0",
                        appVersion: "1.0",
                        publicLocale: "en-US",
                        targetPackID: "source-atlas/v1/domain/sports/20260627T000000Z"
                    ),
                    allowedModes: [.activeLifecycle],
                    status: .active
                ),
            ]
        )

        let resolution = registry.resolveTargets(for: .activeLifecycle)

        XCTAssertEqual(resolution.selectedTargetIDs, [])
        XCTAssertEqual(resolution.excludedTargetIDs, ["sports-stable"])
        XCTAssertEqual(resolution.findings, [.init(targetID: "sports-stable", issue: .missingApprovalArtifact)])
        XCTAssertEqual(resolution.lifecycleIssues, [.missingApprovalArtifact])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testPrivateApprovalArtifactMetadataIsRejectedBeforeSelection() {
        let registry = SourceAtlasPublicPackRefreshTargetRegistry(
            entries: [
                entry(
                    id: "private-approval",
                    status: .active,
                    allowedModes: [.activeLifecycle],
                    reviewArtifactID: "docs/qa/source-atlas/native/user_id-approval.md"
                ),
            ]
        )

        let resolution = registry.resolveTargets(for: .activeLifecycle)

        XCTAssertEqual(resolution.selectedTargetIDs, [])
        XCTAssertEqual(resolution.excludedTargetIDs, ["private-approval"])
        XCTAssertTrue(resolution.findings.contains(.init(targetID: "private-approval", issue: .privateTargetMetadata)))
        XCTAssertEqual(resolution.lifecycleIssues, [.privateTargetMetadata])
        XCTAssertEqual(Set(resolution.egressFindings.map(\.forbiddenToken)), ["user_id"])
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testDuplicateTargetIDsAreRejected() {
        let registry = SourceAtlasPublicPackRefreshTargetRegistry(
            entries: [
                entry(id: "duplicate", status: .active, allowedModes: [.activeLifecycle]),
                entry(id: "duplicate", status: .active, allowedModes: [.activeLifecycle]),
            ]
        )

        let resolution = registry.resolveTargets(for: .activeLifecycle)

        XCTAssertEqual(resolution.selectedTargetIDs, [])
        XCTAssertEqual(resolution.excludedTargetIDs, ["duplicate"])
        XCTAssertEqual(
            resolution.findings.filter { $0.issue == .duplicateTargetID }.map(\.targetID),
            ["duplicate"]
        )
        XCTAssertEqual(resolution.lifecycleIssues, [.unsafeTarget])
    }

    func testRegistryIsCodableAndStableOrdered() throws {
        let registry = SourceAtlasPublicPackRefreshTargetRegistry(
            entries: [
                entry(id: "b-active", status: .active, allowedModes: [.background]),
                entry(id: "a-active", status: .active, allowedModes: [.activeLifecycle]),
            ]
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(registry)
        let decoded = try JSONDecoder().decode(SourceAtlasPublicPackRefreshTargetRegistry.self, from: data)

        XCTAssertEqual(decoded.entries.map(\.id), ["a-active", "b-active"])
        XCTAssertEqual(decoded.resolveTargets(for: .activeLifecycle).selectedTargetIDs, ["a-active"])
    }
}

private extension SourceAtlasPublicPackRefreshTargetRegistryTests {
    func entry(
        id: String,
        status: SourceAtlasPublicPackRefreshTargetRegistryStatus,
        allowedModes: Set<SourceAtlasPublicPackLifecycleRefreshMode>,
        reviewArtifactID: String = "docs/qa/source-atlas/native/source-atlas-native-active-target-approval-gate-train-26.md"
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
            reviewArtifactID: reviewArtifactID,
            nonClaims: [
                "not a final user plan",
                "not a Step generator",
            ]
        )
    }
}
