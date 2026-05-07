import XCTest
@testable import Ambitions

final class AmbitionsOSLongevityModelsTests: XCTestCase {
    private let validator = AmbitionsOSLongevityValidator()

    func testReviewReadyArchivePlanRoundTripsAndValidates() throws {
        let plan = archivePlan()

        let data = try JSONEncoder().encode(plan)
        let decoded = try JSONDecoder().decode(AmbitionsOSLongevityArchivePlan.self, from: data)

        XCTAssertEqual(decoded.schemaVersion, ambitionsOSLongevitySchemaVersion)
        XCTAssertEqual(decoded.archiveState, .agingReview)
        XCTAssertEqual(decoded.actionKind, .ageArchive)
        XCTAssertEqual(validator.validate(decoded), [])
    }

    func testInvalidSchemaMalformedPlanIsRejected() {
        let plan = archivePlan(
            id: "",
            objectID: "",
            summary: "",
            legacyPayloads: [
                legacyPayload(
                    id: "",
                    originalSchemaVersion: "",
                    payloadSummary: "",
                    preservedFieldNames: []
                )
            ],
            receipts: [receipt(id: "", action: "", occurredAt: "")],
            schemaVersion: "legacy.schema"
        )

        let issues = validator.validate(plan)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedPlan))
    }

    func testArchiveAgingRequiresSourceContinuityAndFreshnessReview() {
        let plan = archivePlan(
            sourceState: .sourceNeeded,
            freshnessState: .staleCritical,
            reviewState: .needsSourceReview,
            sourceClaimIDs: [],
            sourcePackIDs: []
        )

        let issues = validator.validate(plan)

        XCTAssertFalse(plan.hasReviewReadySourceContinuity)
        XCTAssertTrue(issues.contains(.sourceContinuityMissing))
        XCTAssertTrue(issues.contains(.staleHighRiskSource))
        XCTAssertTrue(issues.contains(.userReviewMissing))
    }

    func testProofAndLegacyEvidenceMustSurviveArchive() {
        let plan = archivePlan(
            proofReferenceIDs: [],
            legacyPayloads: [
                legacyPayload(proofReferenceIDs: [], sourceClaimIDs: [])
            ]
        )

        XCTAssertFalse(plan.preservesProofOrLegacyEvidence)
        XCTAssertTrue(validator.validate(plan).contains(.proofSurvivalMissing))
    }

    func testSensitiveLegacyPayloadRequiresRedactedLocalProjection() {
        let plan = archivePlan(
            privacyClass: .sensitive,
            sensitiveAreas: [.family, .privateAttachment],
            projectionPolicy: .fullLocal,
            redactionSummary: ""
        )

        XCTAssertTrue(plan.isSensitivePayload)
        XCTAssertTrue(validator.validate(plan).contains(.sensitivePayloadNeedsRedaction))
    }

    func testDestructiveArchiveActionRequiresUserReviewRestoreAndRollback() {
        let plan = archivePlan(
            archiveState: .deletePending,
            actionKind: .retireLegacyPayload,
            reviewState: .needsUserReview,
            receipts: [receipt(userReviewed: false)],
            hasRestorePath: false,
            hasRollbackPlan: false
        )

        let issues = validator.validate(plan)

        XCTAssertTrue(plan.isTerminalOrDestructiveArchiveAction)
        XCTAssertTrue(issues.contains(.userReviewMissing))
        XCTAssertTrue(issues.contains(.restorePathMissing))
        XCTAssertTrue(issues.contains(.rollbackPlanMissing))
    }

    func testLegacyMigrationAndConflictReviewBoundariesAreExplicit() {
        let migration = archivePlan(
            actionKind: .prepareMigrationReview,
            hasMigrationReview: false
        )
        let merge = archivePlan(
            actionKind: .mergeMultiDeviceLedger,
            hasMigrationReview: false,
            hasConflictReview: false
        )

        XCTAssertTrue(validator.validate(migration).contains(.migrationReviewMissing))

        let mergeIssues = validator.validate(merge)
        XCTAssertTrue(mergeIssues.contains(.implementationBoundaryViolation))
        XCTAssertTrue(mergeIssues.contains(.migrationReviewMissing))
        XCTAssertTrue(mergeIssues.contains(.conflictReviewMissing))
    }

    func testPersistenceSyncRuntimeMutationRemoteDependencyAndReleaseLanguageAreBlocked() {
        let plan = archivePlan(
            actionKind: .writePersistence,
            changesAppState: true,
            dependsOnNetworkOrHostedService: true,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: true,
                mutatesPlans: true,
                writesPersistence: true
            ),
            surfaceLanguageSamples: [
                "Archive is sync ready, App Store ready, and device verified."
            ]
        )

        let issues = validator.validate(plan)

        XCTAssertTrue(issues.contains(.implementationBoundaryViolation))
        XCTAssertTrue(issues.contains(.hiddenMutationRisk))
        XCTAssertTrue(issues.contains(.runtimeStoreBehavior))
        XCTAssertTrue(issues.contains(.hostedOrRemoteDependency))
        XCTAssertTrue(issues.contains(.forbiddenLanguage))
        XCTAssertTrue(issues.contains(.releaseClaimWithoutEvidence))
    }
}

private extension AmbitionsOSLongevityModelsTests {
    func archivePlan(
        id: String = "longevity-goal-archive-review",
        objectID: String = "goal-learn-pickleball",
        objectKind: AmbitionsOSLongevityObjectKind = .goal,
        ownerSurface: AmbitionsOSControlPlaneSurface = .you,
        archiveState: AmbitionsOSLongevityArchiveState = .agingReview,
        actionKind: AmbitionsOSLongevityActionKind = .ageArchive,
        summary: String = "Review whether an older goal should stay visible, be archived, or be restored.",
        sourceState: HumanProgressSourceState = .sourceBacked,
        freshnessState: HumanProgressFreshnessState = .current,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sensitiveAreas: [AmbitionsOSPrivacySensitiveArea] = [],
        projectionPolicy: AmbitionsOSPrivacyProjectionPolicy = .redactedLocal,
        redactionSummary: String = "Legacy details stay local; only the archive reason is shown.",
        proofReferenceIDs: [String] = ["proof-goal-started"],
        sourceClaimIDs: [String] = ["source-claim-pickleball"],
        sourcePackIDs: [String] = ["source-pack-sports"],
        legacyPayloads: [AmbitionsOSLongevityLegacyPayload]? = nil,
        receipts: [AmbitionsOSLongevityReceipt]? = nil,
        hasRestorePath: Bool = true,
        hasRollbackPlan: Bool = true,
        hasMigrationReview: Bool = true,
        hasConflictReview: Bool = true,
        changesAppState: Bool = false,
        dependsOnNetworkOrHostedService: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        surfaceLanguageSamples: [String] = ["Archived still counts; restore is available after review."],
        schemaVersion: String = ambitionsOSLongevitySchemaVersion
    ) -> AmbitionsOSLongevityArchivePlan {
        AmbitionsOSLongevityArchivePlan(
            id: id,
            objectID: objectID,
            objectKind: objectKind,
            ownerSurface: ownerSurface,
            archiveState: archiveState,
            actionKind: actionKind,
            summary: summary,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            privacyClass: privacyClass,
            sensitiveAreas: sensitiveAreas,
            projectionPolicy: projectionPolicy,
            redactionSummary: redactionSummary,
            proofReferenceIDs: proofReferenceIDs,
            sourceClaimIDs: sourceClaimIDs,
            sourcePackIDs: sourcePackIDs,
            legacyPayloads: legacyPayloads ?? [legacyPayload()],
            receipts: receipts ?? [receipt()],
            hasRestorePath: hasRestorePath,
            hasRollbackPlan: hasRollbackPlan,
            hasMigrationReview: hasMigrationReview,
            hasConflictReview: hasConflictReview,
            changesAppState: changesAppState,
            dependsOnNetworkOrHostedService: dependsOnNetworkOrHostedService,
            runtimeBoundary: runtimeBoundary,
            surfaceLanguageSamples: surfaceLanguageSamples,
            schemaVersion: schemaVersion
        )
    }

    func legacyPayload(
        id: String = "legacy-v1-goal-payload",
        originalSchemaVersion: String = "goal_payload.v1",
        payloadSummary: String = "Older goal payload preserved for restore review.",
        preservedFieldNames: [String] = ["title", "proofIDs", "sourceClaimIDs"],
        droppedFieldNames: [String] = ["deprecatedMoodScore"],
        proofReferenceIDs: [String] = ["proof-goal-started"],
        sourceClaimIDs: [String] = ["source-claim-pickleball"],
        migrationReviewID: String? = "migration-review-1"
    ) -> AmbitionsOSLongevityLegacyPayload {
        AmbitionsOSLongevityLegacyPayload(
            id: id,
            originalSchemaVersion: originalSchemaVersion,
            payloadSummary: payloadSummary,
            preservedFieldNames: preservedFieldNames,
            droppedFieldNames: droppedFieldNames,
            proofReferenceIDs: proofReferenceIDs,
            sourceClaimIDs: sourceClaimIDs,
            migrationReviewID: migrationReviewID
        )
    }

    func receipt(
        id: String = "receipt-longevity-review",
        action: String = "archive aging reviewed",
        occurredAt: String = "2026-05-07T02:40:00Z",
        userReviewed: Bool = true
    ) -> AmbitionsOSLongevityReceipt {
        AmbitionsOSLongevityReceipt(
            id: id,
            action: action,
            occurredAt: occurredAt,
            userReviewed: userReviewed
        )
    }
}
