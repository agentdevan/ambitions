import XCTest
@testable import Ambitions

final class AmbitionsOSSourceTruthModelsTests: XCTestCase {
    private let validator = AmbitionsOSSourceTruthValidator()

    func testCurrentOfficialClaimWithApprovedSourceCanDriveSourceSensitiveUse() {
        let ledger = validLedger()

        XCTAssertEqual(ledger.validationIssues, [])
        XCTAssertTrue(ledger.claims[0].canBeTreatedAsCurrentOfficial)
        XCTAssertTrue(ledger.claims[0].canDriveSourceSensitiveRecommendation)
    }

    func testUnsupportedSchemaAndMalformedClaimAreRejected() {
        let claim = validClaim(
            id: "",
            text: "",
            schemaVersion: "old.schema"
        )
        let ledger = AmbitionsOSSourceTruthLedger(claims: [claim], sources: [officialSource()])

        let issues = validator.validate(ledger)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedClaim))
    }

    func testOfficialClaimRequiresApprovedOfficialSource() {
        let claim = validClaim(
            sourceQualityState: .userProvided,
            sourceIDs: ["source-user"]
        )
        let source = AmbitionsOSSourceReference(
            id: "source-user",
            kind: .userProvided,
            qualityState: .userProvided,
            approvedForOfficialClaims: false
        )
        let ledger = AmbitionsOSSourceTruthLedger(claims: [claim], sources: [source])

        let issues = validator.validate(ledger)

        XCTAssertFalse(claim.canBeTreatedAsCurrentOfficial)
        XCTAssertTrue(issues.contains(.officialClaimWithoutApprovedSource))
        XCTAssertTrue(issues.contains(.userProvidedClaimTreatedAsOfficial))
    }

    func testStaleHighRiskClaimCannotDriveCurrentRecommendation() {
        let claim = validClaim(
            freshnessState: .staleCritical,
            riskClass: .certificationEligibility
        )
        let ledger = AmbitionsOSSourceTruthLedger(claims: [claim], sources: [officialSource()])

        XCTAssertFalse(claim.canDriveSourceSensitiveRecommendation)
        XCTAssertTrue(validator.validate(ledger).contains(.staleHighRiskClaim))
    }

    func testConflictAndRevocationStatesRequireReviewInsteadOfChoosingAWinner() {
        let conflicting = validClaim(
            id: "claim-conflict",
            state: .conflicting,
            conflictClaimIDs: ["claim-other"],
            reviewState: .needsSourceReview
        )
        let revoked = validClaim(
            id: "claim-revoked",
            state: .revoked,
            reviewState: .needsSourceReview
        )
        let ledger = AmbitionsOSSourceTruthLedger(claims: [conflicting, revoked], sources: [officialSource()])

        let issues = validator.validate(ledger)

        XCTAssertTrue(issues.contains(.unresolvedConflict))
        XCTAssertTrue(issues.contains(.revokedClaimActive))
    }

    func testClaimTransitionsRequireReviewReceiptsBeforeMutation() {
        let transition = AmbitionsOSSourceTruthTransition(
            claimID: "claim-1",
            fromState: .sourceNeeded,
            toState: .officialSourceBacked,
            reason: "Source attached",
            receiptIDs: [],
            changedSourceIDs: ["source-official"],
            userReviewed: false
        )
        let ledger = AmbitionsOSSourceTruthLedger(
            claims: [validClaim()],
            sources: [officialSource()],
            transitions: [transition]
        )

        XCTAssertFalse(transition.isReviewable)
        XCTAssertTrue(validator.validate(ledger).contains(.silentClaimMutation))
    }

    func testClaimTransitionToOfficialSourceBackedRequiresProvenanceOrSourceEvidence() {
        let claim = validClaim(
            id: "claim-no-provenance",
            state: .sourceNeeded,
            sourceIDs: [],
            sourceQualityState: .secondaryReference
        )
        let transition = AmbitionsOSSourceTruthTransition(
            claimID: "claim-no-provenance",
            fromState: .sourceNeeded,
            toState: .officialSourceBacked,
            reason: "Promoted without source bridge",
            receiptIDs: ["receipt-1"],
            userReviewed: true
        )
        let ledger = AmbitionsOSSourceTruthLedger(
            claims: [claim],
            sources: [officialSource()],
            transitions: [transition]
        )

        XCTAssertTrue(validator.validate(ledger).contains(.invalidClaimTransition))
    }

    func testDisputedOrRevokedClaimsDoNotDriveRecommendation() {
        let disputed = validClaim(
            id: "claim-disputed",
            state: .disputed,
            reviewState: .ready
        )
        let sourceChanged = validClaim(
            id: "claim-source-changed",
            state: .changed,
            reviewState: .ready
        )
        let conflicting = validClaim(
            id: "claim-conflicting",
            state: .conflicting,
            reviewState: .ready
        )
        let revoked = validClaim(
            id: "claim-revoked",
            state: .revoked,
            reviewState: .ready
        )

        XCTAssertFalse(disputed.canDriveSourceSensitiveRecommendation)
        XCTAssertFalse(revoked.canDriveSourceSensitiveRecommendation)
        XCTAssertFalse(sourceChanged.canDriveSourceSensitiveRecommendation)
        XCTAssertFalse(conflicting.canDriveSourceSensitiveRecommendation)
    }

    func testUnknownOrStaleCriticalClaimsCannotDriveSourceSensitiveRecommendations() {
        let staleCritical = validClaim(
            id: "claim-stale-critical",
            state: .officialSourceBacked,
            freshnessState: .staleCritical,
            sourceQualityState: .official,
            riskClass: .certificationEligibility
        )
        let unknown = validClaim(
            id: "claim-unknown",
            state: .sourceNeeded,
            freshnessState: .unknown,
            sourceQualityState: .secondaryReference,
            riskClass: .certificationEligibility
        )

        let ledger = AmbitionsOSSourceTruthLedger(claims: [staleCritical, unknown], sources: [officialSource()])
        let issues = validator.validate(ledger)

        XCTAssertFalse(staleCritical.canDriveSourceSensitiveRecommendation)
        XCTAssertFalse(unknown.canDriveSourceSensitiveRecommendation)
        XCTAssertTrue(issues.contains(.staleHighRiskClaim))
    }

    func testSensitiveClaimIsBlockedFromExternalProjectionWithoutRedaction() {
        let sensitive = validClaim(privacyClass: .sensitive)
        let redacted = validClaim(id: "claim-redacted", privacyClass: .externalRedacted)

        XCTAssertFalse(sensitive.isExternalProjectionSafe)
        XCTAssertTrue(
            validator.validate(AmbitionsOSSourceTruthLedger(claims: [sensitive], sources: [officialSource()]))
                .contains(.privateExternalProjectionRisk)
        )
        XCTAssertTrue(redacted.isExternalProjectionSafe)
        XCTAssertEqual(
            validator.validate(AmbitionsOSSourceTruthLedger(claims: [redacted], sources: [officialSource()])),
            []
        )
    }

    func testLedgerRejectsRuntimeStoreBehaviorAndCertificationOverclaim() {
        let ledger = AmbitionsOSSourceTruthLedger(
            claims: [validClaim()],
            sources: [officialSource()],
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: false,
                mutatesPlans: false,
                writesPersistence: false
            ),
            claimsSourceCertification: true
        )

        let issues = validator.validate(ledger)

        XCTAssertTrue(issues.contains(.runtimeStoreBehavior))
        XCTAssertTrue(issues.contains(.sourceCertificationOverclaim))
    }
}

private extension AmbitionsOSSourceTruthModelsTests {
    func validLedger() -> AmbitionsOSSourceTruthLedger {
        AmbitionsOSSourceTruthLedger(claims: [validClaim()], sources: [officialSource()])
    }

    func officialSource() -> AmbitionsOSSourceReference {
        AmbitionsOSSourceReference(
            id: "source-official",
            kind: .official,
            qualityState: .official,
            approvedForOfficialClaims: true
        )
    }

    func validClaim(
        id: String = "claim-1",
        text: String = "The source-backed requirement applies inside this scope.",
        state: AmbitionsOSSourceTruthClaimState = .officialSourceBacked,
        sourceQualityState: AmbitionsOSSourceQualityState = .official,
        freshnessState: HumanProgressFreshnessState = .current,
        riskClass: SourceAtlasRiskClass = .careerContext,
        sourceIDs: [String] = ["source-official"],
        conflictClaimIDs: [String] = [],
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        schemaVersion: String = ambitionsOSSourceTruthSchemaVersion
    ) -> AmbitionsOSSourceTruthClaim {
        AmbitionsOSSourceTruthClaim(
            id: id,
            text: text,
            scopeID: "scope-goal-detail",
            state: state,
            sourceQualityState: sourceQualityState,
            freshnessState: freshnessState,
            riskClass: riskClass,
            sourceIDs: sourceIDs,
            sourcePackIDs: ["source-pack-1"],
            conflictClaimIDs: conflictClaimIDs,
            reviewState: reviewState,
            privacyClass: privacyClass,
            lastReviewedAt: "2026-05-06T23:15:00Z",
            schemaVersion: schemaVersion
        )
    }
}
