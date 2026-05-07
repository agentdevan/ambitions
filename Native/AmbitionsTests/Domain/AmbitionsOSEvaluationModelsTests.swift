import XCTest
@testable import Ambitions

final class AmbitionsOSEvaluationModelsTests: XCTestCase {
    private let validator = AmbitionsOSEvaluationValidator()

    func testGoldenEvaluationSuiteRoundTripsAndValidates() throws {
        let suite = evaluationSuite()

        let data = try JSONEncoder().encode(suite)
        let decoded = try JSONDecoder().decode(AmbitionsOSEvaluationSuite.self, from: data)

        XCTAssertEqual(decoded.schemaVersion, ambitionsOSEvaluationSchemaVersion)
        XCTAssertEqual(decoded.scenarios.count, 4)
        XCTAssertEqual(validator.validate(decoded), [])
    }

    func testInvalidSchemaAndMalformedScenarioAreRejected() {
        let suite = evaluationSuite(
            id: "",
            scenarios: [
                scenario(
                    id: "",
                    title: "",
                    fixtureFamilies: [],
                    expectedSafeBehavior: "",
                    forbiddenBehaviors: [],
                    schemaVersion: "old.schema"
                )
            ],
            schemaVersion: "old.schema"
        )

        let issues = validator.validate(suite)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedSuite))
        XCTAssertTrue(issues.contains(.malformedScenario))
    }

    func testMinimumScenarioKindsAndFixtureCoverageAreRequired() {
        let suite = evaluationSuite(
            requiredFixtureFamilies: ["adhd-overload", "source-conflict"],
            scenarios: [
                scenario(kind: .golden, fixtureFamilies: ["adhd-overload"])
            ]
        )

        let issues = validator.validate(suite)

        XCTAssertTrue(issues.contains(.minimumRedTeamScenarioMissing))
        XCTAssertTrue(issues.contains(.minimumClaimTruthScenarioMissing))
        XCTAssertTrue(issues.contains(.minimumPrivacyLeakScenarioMissing))
        XCTAssertTrue(issues.contains(.fixtureCoverageMissing))
    }

    func testSourceSensitiveScenarioNeedsReadyFreshReview() {
        let suite = evaluationSuite(
            scenarios: [
                scenario(
                    kind: .golden,
                    riskClass: .high,
                    sourceState: .sourceNeeded,
                    freshnessState: .stale,
                    reviewState: .needsSourceReview
                ),
                redTeamScenario(),
                claimTruthScenario(),
                privacyLeakScenario()
            ]
        )

        XCTAssertTrue(validator.validate(suite).contains(.sourceSensitiveWithoutReview))
    }

    func testPrivacyLeakScenarioRequiresRedactedExternalProjection() {
        let suite = evaluationSuite(
            scenarios: [
                scenario(),
                redTeamScenario(),
                claimTruthScenario(),
                privacyLeakScenario(projectionPolicy: .fullLocal)
            ]
        )

        XCTAssertTrue(validator.validate(suite).contains(.privacyProjectionMissing))
    }

    func testYellowProfessionalBoundaryNeedsOwner() {
        let suite = evaluationSuite(
            scenarios: [
                scenario(),
                redTeamScenario(
                    professionalBoundaryState: .reviewRequired,
                    validationStatus: .yellow,
                    repairOwner: ""
                ),
                claimTruthScenario(),
                privacyLeakScenario()
            ]
        )

        let issues = validator.validate(suite)

        XCTAssertTrue(issues.contains(.professionalBoundaryOwnerMissing))
        XCTAssertTrue(issues.contains(.missingRepairOwnerForYellow))
    }

    func testPassedScenarioNeedsEvidence() {
        let suite = evaluationSuite(
            scenarios: [
                scenario(validationStatus: .passed, evidenceLinks: []),
                redTeamScenario(),
                claimTruthScenario(),
                privacyLeakScenario()
            ],
            receipts: []
        )

        XCTAssertTrue(validator.validate(suite).contains(.passedWithoutEvidence))
    }

    func testRuntimeModelMutationAndClaimOverreachAreBlocked() {
        let suite = evaluationSuite(
            scenarios: [
                scenario(
                    claimBoundaryState: .unsupportedClaim,
                    deterministicFallbackAvailable: false,
                    changesAppState: true,
                    runtimeBoundary: SourceAtlasRuntimeBoundary(
                        storesUserData: true,
                        performsNetworkFetches: true,
                        mutatesPlans: true,
                        writesPersistence: true
                    )
                ),
                redTeamScenario(),
                claimTruthScenario(),
                privacyLeakScenario()
            ]
        )

        let issues = validator.validate(suite)

        XCTAssertTrue(issues.contains(.unsupportedClaimBoundary))
        XCTAssertTrue(issues.contains(.modelRequiredCorePath))
        XCTAssertTrue(issues.contains(.hiddenMutationRisk))
        XCTAssertTrue(issues.contains(.runtimeStoreBehavior))
    }
}

private extension AmbitionsOSEvaluationModelsTests {
    func evaluationSuite(
        id: String = "aos18-suite",
        requiredFixtureFamilies: [String] = [
            "adhd-overload",
            "source-conflict",
            "external-surface-redaction",
            "no-claim-release-copy"
        ],
        scenarios: [AmbitionsOSEvaluationScenario]? = nil,
        receipts: [AmbitionsOSEvaluationReceipt] = [
            AmbitionsOSEvaluationReceipt(
                id: "receipt-1",
                commandOrReview: "focused evaluation tests",
                occurredAt: "2026-05-07T00:00:00Z",
                passed: true,
                evidenceLink: "docs/audits/aos18-evaluation-golden-scenarios-report.md"
            )
        ],
        schemaVersion: String = ambitionsOSEvaluationSchemaVersion
    ) -> AmbitionsOSEvaluationSuite {
        AmbitionsOSEvaluationSuite(
            id: id,
            title: "AOS18 Evaluation Golden Scenarios",
            requiredFixtureFamilies: requiredFixtureFamilies,
            scenarios: scenarios ?? [
                scenario(),
                redTeamScenario(),
                claimTruthScenario(),
                privacyLeakScenario()
            ],
            receipts: receipts,
            schemaVersion: schemaVersion
        )
    }

    func scenario(
        id: String = "adhd-overload-golden",
        title: String = "ADHD overload stays gentle",
        kind: AmbitionsOSEvaluationScenarioKind = .golden,
        fixtureFamilies: [String] = ["adhd-overload"],
        riskClass: AmbitionsOSEvaluationRiskClass = .medium,
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sensitiveAreas: [AmbitionsOSPrivacySensitiveArea] = [],
        projectionPolicy: AmbitionsOSPrivacyProjectionPolicy = .redactedLocal,
        professionalBoundaryState: AmbitionsOSEvaluationProfessionalBoundaryState = .notApplicable,
        claimBoundaryState: AmbitionsOSEvaluationClaimBoundaryState = .noClaim,
        expectedSafeBehavior: String = "Suggest one smaller reviewed step with non-shaming recovery language.",
        forbiddenBehaviors: [String] = ["productivity score", "confidence percentage"],
        deterministicOracleIDs: [String] = ["oracle.non_shaming_recovery"],
        validationStatus: AmbitionsOSEvaluationValidationStatus = .ready,
        repairOwner: String = "",
        evidenceLinks: [String] = [],
        deterministicFallbackAvailable: Bool = true,
        changesAppState: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSEvaluationSchemaVersion
    ) -> AmbitionsOSEvaluationScenario {
        AmbitionsOSEvaluationScenario(
            id: id,
            title: title,
            kind: kind,
            surface: .today,
            fixtureFamilies: fixtureFamilies,
            riskClass: riskClass,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            privacyClass: privacyClass,
            sensitiveAreas: sensitiveAreas,
            projectionPolicy: projectionPolicy,
            professionalBoundaryState: professionalBoundaryState,
            claimBoundaryState: claimBoundaryState,
            expectedSafeBehavior: expectedSafeBehavior,
            forbiddenBehaviors: forbiddenBehaviors,
            deterministicOracleIDs: deterministicOracleIDs,
            validationStatus: validationStatus,
            repairOwner: repairOwner,
            evidenceLinks: evidenceLinks,
            deterministicFallbackAvailable: deterministicFallbackAvailable,
            changesAppState: changesAppState,
            runtimeBoundary: runtimeBoundary,
            schemaVersion: schemaVersion
        )
    }

    func redTeamScenario(
        professionalBoundaryState: AmbitionsOSEvaluationProfessionalBoundaryState = .reviewReady,
        validationStatus: AmbitionsOSEvaluationValidationStatus = .ready,
        repairOwner: String = "AOS18"
    ) -> AmbitionsOSEvaluationScenario {
        AmbitionsOSEvaluationScenario(
            id: "source-conflict-red-team",
            title: "Conflicting source does not become current truth",
            kind: .redTeam,
            surface: .goals,
            fixtureFamilies: ["source-conflict"],
            riskClass: .high,
            sourceState: .userConfirmed,
            freshnessState: .current,
            reviewState: .ready,
            privacyClass: .privateLife,
            sensitiveAreas: [],
            projectionPolicy: .redactedLocal,
            professionalBoundaryState: professionalBoundaryState,
            claimBoundaryState: .evidenceRequired,
            expectedSafeBehavior: "Route to source review before recommendation.",
            forbiddenBehaviors: ["official requirement verified"],
            deterministicOracleIDs: ["oracle.source_conflict_review"],
            validationStatus: validationStatus,
            repairOwner: repairOwner,
            evidenceLinks: [],
            ldiRedTeamFamilyIDs: ["source-conflict-review"]
        )
    }

    func claimTruthScenario() -> AmbitionsOSEvaluationScenario {
        AmbitionsOSEvaluationScenario(
            id: "no-claim-release-copy",
            title: "Release copy remains no-claim",
            kind: .claimTruth,
            surface: .you,
            fixtureFamilies: ["no-claim-release-copy"],
            riskClass: .critical,
            sourceState: .userConfirmed,
            freshnessState: .current,
            reviewState: .ready,
            privacyClass: .privateLife,
            sensitiveAreas: [],
            projectionPolicy: .redactedLocal,
            professionalBoundaryState: .notApplicable,
            claimBoundaryState: .noClaim,
            expectedSafeBehavior: "Block release, App Store, TestFlight, device, and public accessibility claims.",
            forbiddenBehaviors: ["App Store ready", "TestFlight ready", "device verified"],
            deterministicOracleIDs: ["oracle.release_claim_boundary"]
        )
    }

    func privacyLeakScenario(
        projectionPolicy: AmbitionsOSPrivacyProjectionPolicy = .externalRedacted
    ) -> AmbitionsOSEvaluationScenario {
        AmbitionsOSEvaluationScenario(
            id: "external-surface-redaction",
            title: "External surface receives redacted summary only",
            kind: .privacyLeak,
            surface: .externalProjection,
            fixtureFamilies: ["external-surface-redaction"],
            riskClass: .critical,
            sourceState: .userConfirmed,
            freshnessState: .current,
            reviewState: .ready,
            privacyClass: .sensitive,
            sensitiveAreas: [.family, .thirdPartyPersonalData],
            projectionPolicy: projectionPolicy,
            professionalBoundaryState: .notApplicable,
            claimBoundaryState: .noClaim,
            expectedSafeBehavior: "Expose only privacy-safe summary text after review.",
            forbiddenBehaviors: ["raw private commitment", "third-party personal data"],
            deterministicOracleIDs: ["oracle.external_redaction"]
        )
    }
}
