import XCTest
@testable import Ambitions

final class AmbitionsOSPrivacySafetyModelsTests: XCTestCase {
    private let validator = AmbitionsOSPrivacySafetyValidator()

    func testReviewReadyPrivacyPolicyRoundTripsAndValidates() throws {
        let policy = privacyPolicy()

        let data = try JSONEncoder().encode(policy)
        let decoded = try JSONDecoder().decode(AmbitionsOSPrivacySafetyPolicy.self, from: data)

        XCTAssertEqual(decoded.schemaVersion, ambitionsOSPrivacySafetySchemaVersion)
        XCTAssertEqual(decoded.permissionState, .privateOnly)
        XCTAssertEqual(decoded.projectionPolicy, .redactedLocal)
        XCTAssertEqual(validator.validate(decoded), [])
    }

    func testPrivatePolicyClassifiesAsLocalRedactedSafeReceiptCompatible() {
        let policy = privacyPolicy()

        let classification = validator.classify(policy)

        XCTAssertEqual(classification.classification, .localRedacted)
        XCTAssertEqual(classification.actionReceiptPrivacyLevel, .redacted)
        XCTAssertEqual(classification.eventLedgerPrivacyClassification, .privateUserText)
        XCTAssertEqual(classification.sideEffectLedgerBoundary, .localOnly)
        XCTAssertTrue(classification.localProjectionOnly)
        XCTAssertFalse(classification.externallyProjectable)
        XCTAssertFalse(classification.requiresUserReview)
        XCTAssertTrue(classification.requiresRedaction)
        XCTAssertTrue(classification.receiptCompatible)
        XCTAssertTrue(classification.isGreen)
    }

    func testSensitiveExternalProjectionRequiresRedactionAndReview() {
        let policy = privacyPolicy(
            surface: .externalProjection,
            privacyClass: .sensitive,
            sensitiveAreas: [.medical, .financial],
            reviewState: .needsPrivacyReview,
            projectionPolicy: .externalRedacted,
            redactionSummary: "Redacted content",
            receipts: [receipt(id: "ext-2"), receipt(id: "ext-1")]
        )

        let classification = validator.classify(policy)

        XCTAssertEqual(classification.classification, .externalRedacted)
        XCTAssertTrue(classification.externallyProjectable)
        XCTAssertTrue(classification.requiresRedaction)
        XCTAssertTrue(classification.requiresUserReview)
        XCTAssertEqual(classification.actionReceiptPrivacyLevel, .redacted)
        XCTAssertEqual(classification.eventLedgerPrivacyClassification, .sensitive)
        XCTAssertEqual(classification.sideEffectLedgerBoundary, .privacySensitive)
        XCTAssertFalse(classification.isGreen)
    }

    func testDeletePendingOrBlockedPermissionsAreHiddenAndNotExternallyProjectable() {
        let deletePendingPolicy = privacyPolicy(
            permissionState: .deletePending,
            privacyClass: .deletePending,
            projectionPolicy: .fullLocal
        )
        let blockedPolicy = privacyPolicy(
            permissionState: .externalBlocked,
            surface: .externalProjection,
            projectionPolicy: .externalBlocked
        )

        let deletePendingClassification = validator.classify(deletePendingPolicy)
        let blockedClassification = validator.classify(blockedPolicy)

        XCTAssertEqual(deletePendingClassification.classification, .blocked)
        XCTAssertFalse(deletePendingClassification.externallyProjectable)
        XCTAssertTrue(deletePendingClassification.receiptCompatible)
        XCTAssertEqual(blockedClassification.classification, .blocked)
        XCTAssertFalse(blockedClassification.externallyProjectable)
        XCTAssertTrue(blockedClassification.receiptCompatible)
    }

    func testRuntimeMutationOrExternalBoundaryClassifiesAsUnsafe() {
        let policy = privacyPolicy(
            toolIntent: .mutateGraph,
            toolApprovalState: .requiresPrivacyReview,
            deterministicFallbackAvailable: false,
            receipts: [receipt()],
            changesAppState: true,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: true,
                mutatesPlans: true,
                writesPersistence: true
            )
        )

        let classification = validator.classify(policy)

        XCTAssertEqual(classification.classification, .unsafe)
        XCTAssertEqual(classification.sideEffectLedgerBoundary, .destructive)
        XCTAssertFalse(classification.isGreen)
        XCTAssertFalse(classification.externallyProjectable)
        XCTAssertTrue(classification.issues.contains(.runtimeStoreBehavior))
        XCTAssertTrue(classification.issues.contains(.hiddenMutationRisk))
    }

    func testClassificationIsDeterministicAcrossUnorderedSensitiveAreasAndReceipts() {
        let firstPolicy = privacyPolicy(
            sensitiveAreas: [.medical, .financial],
            receipts: [receipt(id: "r-2"), receipt(id: "r-1")]
        )
        let secondPolicy = privacyPolicy(
            sensitiveAreas: [.financial, .medical],
            receipts: [receipt(id: "r-1"), receipt(id: "r-2")]
        )

        let firstClassification = validator.classify(firstPolicy)
        let secondClassification = validator.classify(secondPolicy)

        XCTAssertEqual(firstClassification.issueFingerprint, secondClassification.issueFingerprint)
        XCTAssertEqual(firstClassification, secondClassification)
    }

    func testInvalidSchemaMalformedPolicyAndBadReceiptAreRejected() {
        let policy = privacyPolicy(
            id: "",
            objectID: "",
            receipts: [receipt(id: "", action: "", occurredAt: "")],
            schemaVersion: "old.schema"
        )

        let issues = validator.validate(policy)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedPolicy))
    }

    func testInferredMemoryCannotBecomeFactWithoutReview() {
        let policy = privacyPolicy(
            permissionState: .inferredNeedsReview,
            reviewState: .ready
        )

        XCTAssertTrue(validator.validate(policy).contains(.inferredMemoryTreatedAsFact))
    }

    func testSensitiveAreasRequireReviewAndExternalRedaction() {
        let policy = privacyPolicy(
            surface: .externalProjection,
            permissionState: .remember,
            privacyClass: .sensitive,
            sensitiveAreas: [.medical, .thirdPartyPersonalData],
            reviewState: .needsPrivacyReview,
            projectionPolicy: .fullLocal
        )

        let issues = validator.validate(policy)

        XCTAssertTrue(issues.contains(.sensitiveAreaNeedsReview))
        XCTAssertTrue(issues.contains(.rawSensitiveExternalProjection))
    }

    func testExternalProjectionNeedsRedactionSummaryAndHonorsBlockedPermission() {
        let policy = privacyPolicy(
            surface: .externalProjection,
            permissionState: .externalBlocked,
            projectionPolicy: .externalRedacted,
            redactionSummary: ""
        )

        let issues = validator.validate(policy)

        XCTAssertTrue(issues.contains(.externalProjectionBlocked))
        XCTAssertTrue(issues.contains(.missingRedactionSummary))
    }

    func testDeletePendingContentMustStayHidden() {
        let policy = privacyPolicy(
            permissionState: .deletePending,
            privacyClass: .deletePending,
            projectionPolicy: .redactedLocal
        )

        let issues = validator.validate(policy)

        XCTAssertTrue(issues.contains(.deletePendingProjection))
        XCTAssertTrue(issues.contains(.externalProjectionBlocked))
    }

    func testToolFallbackReceiptMutationAndRuntimeBoundariesAreEnforced() {
        let policy = privacyPolicy(
            toolIntent: .mutateGraph,
            toolApprovalState: .requiresPrivacyReview,
            deterministicFallbackAvailable: false,
            receipts: [receipt(userReviewed: false)],
            changesAppState: true,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: true,
                mutatesPlans: true,
                writesPersistence: true
            )
        )

        let issues = validator.validate(policy)

        XCTAssertTrue(issues.contains(.toolApprovalRequired))
        XCTAssertTrue(issues.contains(.deterministicFallbackMissing))
        XCTAssertTrue(issues.contains(.privacyReceiptMissing))
        XCTAssertTrue(issues.contains(.hiddenMutationRisk))
        XCTAssertTrue(issues.contains(.runtimeStoreBehavior))
    }
}

private extension AmbitionsOSPrivacySafetyModelsTests {
    func privacyPolicy(
        id: String = "privacy-1",
        objectID: String = "goal-1",
        surface: AmbitionsOSControlPlaneSurface = .you,
        permissionState: AmbitionsOSPrivacyPermissionState = .privateOnly,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sensitiveAreas: [AmbitionsOSPrivacySensitiveArea] = [],
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .ready,
        projectionPolicy: AmbitionsOSPrivacyProjectionPolicy = .redactedLocal,
        toolIntent: AmbitionsOSPrivacyToolIntent = .readLocalSummary,
        toolApprovalState: AmbitionsOSLocalLanguageToolApprovalState = .reviewOnly,
        deterministicFallbackAvailable: Bool = true,
        redactionSummary: String = "Private summary",
        receipts: [AmbitionsOSPrivacyReceipt]? = nil,
        changesAppState: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSPrivacySafetySchemaVersion
    ) -> AmbitionsOSPrivacySafetyPolicy {
        AmbitionsOSPrivacySafetyPolicy(
            id: id,
            objectID: objectID,
            surface: surface,
            permissionState: permissionState,
            privacyClass: privacyClass,
            sensitiveAreas: sensitiveAreas,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            projectionPolicy: projectionPolicy,
            toolIntent: toolIntent,
            toolApprovalState: toolApprovalState,
            deterministicFallbackAvailable: deterministicFallbackAvailable,
            redactionSummary: redactionSummary,
            receipts: receipts ?? [receipt()],
            changesAppState: changesAppState,
            runtimeBoundary: runtimeBoundary,
            schemaVersion: schemaVersion
        )
    }

    func receipt(
        id: String = "receipt-1",
        action: String = "privacy reviewed",
        occurredAt: String = "2026-05-06T21:45:00Z",
        userReviewed: Bool = true
    ) -> AmbitionsOSPrivacyReceipt {
        AmbitionsOSPrivacyReceipt(
            id: id,
            action: action,
            occurredAt: occurredAt,
            userReviewed: userReviewed
        )
    }
}
