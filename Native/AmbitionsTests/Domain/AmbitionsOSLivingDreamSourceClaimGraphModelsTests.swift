import XCTest
@testable import Ambitions

final class AmbitionsOSLivingDreamSourceClaimGraphModelsTests: XCTestCase {
    private let validator = AmbitionsOSLivingDreamSourceClaimGraphValidator()

    func testReviewedSourceBackedClaimCanDriveConsequentialRecommendation() {
        let graph = validGraph()

        XCTAssertEqual(graph.validationIssues, [])
        XCTAssertEqual(graph.claimsReadyForConsequentialRecommendation.map(\.id), ["claim-training-age"])
        XCTAssertTrue(graph.claims[0].canDriveConsequentialRecommendation)
    }

    func testOfficialClaimRequiresApprovedOfficialSource() {
        let claim = validClaim(
            authorityLevel: .official,
            sourceRefIDs: ["source-unreviewed"]
        )
        let graph = AmbitionsOSLivingDreamSourceClaimGraph(
            claims: [claim],
            sourceRefs: [
                sourceRef(
                    id: "source-unreviewed",
                    approvedForOfficialClaims: false,
                    reviewState: .needsSourceReview
                )
            ]
        )

        let issues = validator.validate(graph)

        XCTAssertTrue(issues.contains(.officialClaimWithoutApprovedSource))
        XCTAssertTrue(graph.claimsReadyForConsequentialRecommendation.isEmpty)
    }

    func testStaleHighRiskClaimRequiresReviewBeforeUse() {
        let claim = validClaim(
            freshnessState: .staleCritical,
            riskClass: .legalCivic
        )
        let graph = AmbitionsOSLivingDreamSourceClaimGraph(
            claims: [claim],
            sourceRefs: [sourceRef()]
        )

        let issues = validator.validate(graph)

        XCTAssertTrue(issues.contains(.staleConsequentialClaim))
        XCTAssertFalse(claim.canDriveConsequentialRecommendation)
    }

    func testConflictSupersessionAndMissingSourceReferenceAreBlocked() {
        let conflicting = validClaim(
            id: "claim-conflict",
            sourceConflictState: .confirmed
        )
        let superseded = validClaim(
            id: "claim-superseded",
            supersededByClaimID: nil,
            sourceConflictState: .superseded
        )
        let missingSource = validClaim(
            id: "claim-missing-source",
            sourceRefIDs: ["missing-source"]
        )
        let graph = AmbitionsOSLivingDreamSourceClaimGraph(
            claims: [conflicting, superseded, missingSource],
            sourceRefs: [sourceRef()]
        )

        let issues = validator.validate(graph)

        XCTAssertTrue(issues.contains(.unresolvedConflict))
        XCTAssertTrue(issues.contains(.supersededClaimActive))
        XCTAssertTrue(issues.contains(.missingSourceReference))
    }

    func testValidatorRejectsMalformedClaimsRuntimeAndOverclaims() {
        let malformed = validClaim(
            id: "",
            value: "",
            jurisdiction: "",
            sourceRefIDs: [],
            freshnessPolicy: AmbitionsOSLivingDreamFreshnessPolicy(reviewIntervalDays: 0),
            professionalBoundary: false,
            reviewState: .needsSourceReview,
            claimsProfessionalAdvice: true,
            schemaVersion: "old"
        )
        let graph = AmbitionsOSLivingDreamSourceClaimGraph(
            claims: [malformed, malformed],
            sourceRefs: [
                sourceRef(id: "", title: "", locator: ""),
                sourceRef(id: "duplicate-source"),
                sourceRef(id: "duplicate-source")
            ],
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: true,
                mutatesPlans: true,
                writesPersistence: true
            ),
            claimsOfficialVerification: true,
            usesUserDataServer: true
        )

        let issues = validator.validate(graph)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedClaim))
        XCTAssertTrue(issues.contains(.duplicateClaimID))
        XCTAssertTrue(issues.contains(.malformedSourceReference))
        XCTAssertTrue(issues.contains(.professionalBoundaryMissing))
        XCTAssertTrue(issues.contains(.professionalAdviceClaim))
        XCTAssertTrue(issues.contains(.sourceCertificationOverclaim))
        XCTAssertTrue(issues.contains(.userDataServerBoundaryBroken))
        XCTAssertTrue(issues.contains(.runtimeBoundaryBroken))
    }
}

private extension AmbitionsOSLivingDreamSourceClaimGraphModelsTests {
    func validGraph() -> AmbitionsOSLivingDreamSourceClaimGraph {
        AmbitionsOSLivingDreamSourceClaimGraph(
            claims: [validClaim()],
            sourceRefs: [sourceRef()]
        )
    }

    func sourceRef(
        id: String = "source-official",
        title: String = "Reviewed official source",
        kind: SourceAtlasSourceKind = .official,
        locator: String = "https://example.invalid/source",
        approvedForOfficialClaims: Bool = true,
        reviewState: HumanProgressReviewState = .ready
    ) -> AmbitionsOSLivingDreamSourceClaimReference {
        AmbitionsOSLivingDreamSourceClaimReference(
            id: id,
            title: title,
            kind: kind,
            locator: locator,
            retrievedAt: "2026-05-07T15:30:00Z",
            approvedForOfficialClaims: approvedForOfficialClaims,
            reviewState: reviewState
        )
    }

    func validClaim(
        id: String = "claim-training-age",
        claimType: AmbitionsOSLivingDreamClaimType = .eligibility,
        value: String = "The reviewed source says this requirement applies in the named jurisdiction.",
        unit: String? = nil,
        jurisdiction: String = "US-EXAMPLE",
        authorityLevel: AmbitionsOSLivingDreamClaimAuthorityLevel = .official,
        sourceRefIDs: [String] = ["source-official"],
        sourceState: HumanProgressSourceState = .sourceBacked,
        freshnessPolicy: AmbitionsOSLivingDreamFreshnessPolicy = AmbitionsOSLivingDreamFreshnessPolicy(reviewIntervalDays: 30),
        freshnessState: HumanProgressFreshnessState = .current,
        lastVerified: String? = "2026-05-07T15:30:00Z",
        effectiveDate: String? = "2026-05-01",
        expiresAt: String? = nil,
        supersededByClaimID: String? = nil,
        professionalBoundary: Bool = true,
        sourceConflictState: AmbitionsOSLivingDreamSourceConflictState = .none,
        claimQualityState: AmbitionsOSLivingDreamClaimQualityState = .officialSourceBacked,
        riskClass: SourceAtlasRiskClass = .careerContext,
        reviewState: HumanProgressReviewState = .ready,
        claimsProfessionalAdvice: Bool = false,
        schemaVersion: String = ambitionsOSLivingDreamSourceClaimGraphSchemaVersion
    ) -> AmbitionsOSLivingDreamSourceClaim {
        AmbitionsOSLivingDreamSourceClaim(
            id: id,
            claimType: claimType,
            value: value,
            unit: unit,
            jurisdiction: jurisdiction,
            authorityLevel: authorityLevel,
            sourceRefIDs: sourceRefIDs,
            sourceState: sourceState,
            freshnessPolicy: freshnessPolicy,
            freshnessState: freshnessState,
            lastVerified: lastVerified,
            effectiveDate: effectiveDate,
            expiresAt: expiresAt,
            supersededByClaimID: supersededByClaimID,
            professionalBoundary: professionalBoundary,
            sourceConflictState: sourceConflictState,
            claimQualityState: claimQualityState,
            riskClass: riskClass,
            reviewState: reviewState,
            claimsProfessionalAdvice: claimsProfessionalAdvice,
            schemaVersion: schemaVersion
        )
    }
}
