import XCTest
@testable import Ambitions

final class AmbitionsOSLivingDreamPathPortfolioModelsTests: XCTestCase {
    private let validator = AmbitionsOSLivingDreamPathPortfolioValidator()

    func testCompletePortfolioIsReadyForCapacityBridgeWithoutActivation() throws {
        let portfolio = makePortfolio(candidates: allCandidateKinds())

        let data = try JSONEncoder().encode(portfolio)
        let decoded = try JSONDecoder().decode(AmbitionsOSLivingDreamPathPortfolio.self, from: data)
        let evaluation = validator.evaluate(portfolio: decoded)

        XCTAssertEqual(evaluation.issues, [])
        XCTAssertEqual(evaluation.readiness, .readyForCapacityBridge)
        XCTAssertEqual(evaluation.candidateIDsByKind[.primary], ["primary-path"])
        XCTAssertTrue(evaluation.reviewRequiredCandidateIDs.contains("aggressive-path"))
        XCTAssertFalse(evaluation.activatesPlans)
        XCTAssertFalse(evaluation.mutatesCommitments)
        XCTAssertFalse(evaluation.usesUserDataServer)
    }

    func testMissingConservativeAndFallbackPathsRequireUserReview() {
        let portfolio = makePortfolio(candidates: [
            candidate(id: "primary-path", kind: .primary)
        ])

        let issues = validator.validate(portfolio: portfolio)

        XCTAssertTrue(issues.contains(.missingConservativePath))
        XCTAssertTrue(issues.contains(.missingFallbackPath))
        XCTAssertEqual(validator.evaluate(portfolio: portfolio).readiness, .needsUserReview)
    }

    func testIntakeAndSourceReadinessGatePathPortfolio() {
        let intake = AmbitionsOSLivingDreamStartingPositionPrivacyIntakeEvaluation(
            packetID: "intake",
            requiredQuestionIDs: ["availability"],
            answeredQuestionIDs: [],
            blockedQuestionIDs: [],
            issues: [.eligibilityNotReady],
            storesUserData: false,
            mutatesCommitments: false,
            projectsExternally: false
        )
        let portfolio = makePortfolio(
            intakeEvaluation: intake,
            sourceClaimGraph: sourceClaimGraph(claimQualityState: .draft),
            candidates: allCandidateKinds()
        )

        let issues = validator.validate(portfolio: portfolio)

        XCTAssertTrue(issues.contains(.intakeNotReady))
        XCTAssertTrue(issues.contains(.sourceClaimGraphNotReady))
        XCTAssertTrue(issues.contains(.sourceClaimNotReady))
        XCTAssertEqual(validator.evaluate(portfolio: portfolio).readiness, .needsIntakeReview)
    }

    func testNorthStarPathRequiresSafeNorthStarOutcomeWithoutGuarantee() {
        let guaranteedNorthStar = AmbitionsOSLivingDreamNorthStarOutcome(
            id: "north-star",
            requestID: "north-star-request",
            literalHandling: .meaningOnly,
            meaningStatement: "This is a safe direction.",
            dimensions: [.impact],
            safeAlternativeSeeds: ["small proof step"],
            blockedLiteralSummary: "No literal guarantee.",
            claimsLiteralGuarantee: true
        )
        let portfolio = makePortfolio(
            northStarOutcome: guaranteedNorthStar,
            candidates: allCandidateKinds()
        )

        let issues = validator.validate(portfolio: portfolio)

        XCTAssertTrue(issues.contains(.northStarGuaranteeClaim))
        XCTAssertEqual(validator.evaluate(portfolio: portfolio).readiness, .blocked)
    }

    func testUnsafeActivationMutationServerAndRuntimeBoundariesBlockPortfolio() {
        let portfolio = makePortfolio(
            candidates: [
                candidate(
                    id: "unsafe-path",
                    kind: .primary,
                    handlingLane: .unsafeBlocked,
                    claimsGuarantee: true,
                    activatesPlan: true,
                    mutatesCommitments: true,
                    runtimeBoundary: SourceAtlasRuntimeBoundary(
                        storesUserData: true,
                        performsNetworkFetches: true,
                        mutatesPlans: true,
                        writesPersistence: true
                    )
                ),
                candidate(id: "conservative-path", kind: .conservative),
                candidate(id: "fallback-path", kind: .fallback)
            ],
            allowsActivation: true,
            mutatesCommitments: true,
            usesUserDataServer: true,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: false,
                mutatesPlans: true,
                writesPersistence: true
            )
        )

        let issues = validator.validate(portfolio: portfolio)

        XCTAssertTrue(issues.contains(.unsafeHandlingLane))
        XCTAssertTrue(issues.contains(.guaranteeClaim))
        XCTAssertTrue(issues.contains(.activationForbidden))
        XCTAssertTrue(issues.contains(.hiddenMutationRisk))
        XCTAssertTrue(issues.contains(.userDataServerBoundaryBroken))
        XCTAssertTrue(issues.contains(.runtimeBoundaryBroken))
        XCTAssertEqual(validator.evaluate(portfolio: portfolio).readiness, .blocked)
    }

    func testMalformedDuplicateAndUnsupportedSchemaAreReported() {
        let portfolio = makePortfolio(
            id: "",
            candidates: [
                candidate(id: "", kind: .primary, title: "", summary: "", firstProofStep: "", schemaVersion: "old"),
                candidate(id: "", kind: .primary)
            ],
            schemaVersion: "old"
        )

        let issues = validator.validate(portfolio: portfolio)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedPortfolio))
        XCTAssertTrue(issues.contains(.malformedCandidate))
        XCTAssertTrue(issues.contains(.duplicateCandidateID))
    }
}

private extension AmbitionsOSLivingDreamPathPortfolioModelsTests {
    func makePortfolio(
        id: String = "path-portfolio",
        intakeEvaluation: AmbitionsOSLivingDreamStartingPositionPrivacyIntakeEvaluation? = nil,
        sourceClaimGraph: AmbitionsOSLivingDreamSourceClaimGraph? = nil,
        northStarOutcome: AmbitionsOSLivingDreamNorthStarOutcome? = safeNorthStarOutcome(),
        candidates: [AmbitionsOSLivingDreamPathCandidate],
        allowsActivation: Bool = false,
        mutatesCommitments: Bool = false,
        usesUserDataServer: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSLivingDreamPathPortfolioSchemaVersion
    ) -> AmbitionsOSLivingDreamPathPortfolio {
        AmbitionsOSLivingDreamPathPortfolio(
            id: id,
            intakeEvaluation: intakeEvaluation ?? readyIntakeEvaluation(),
            sourceClaimGraph: sourceClaimGraph ?? self.sourceClaimGraph(),
            northStarOutcome: northStarOutcome,
            candidates: candidates,
            allowsActivation: allowsActivation,
            mutatesCommitments: mutatesCommitments,
            usesUserDataServer: usesUserDataServer,
            runtimeBoundary: runtimeBoundary,
            schemaVersion: schemaVersion
        )
    }

    func allCandidateKinds() -> [AmbitionsOSLivingDreamPathCandidate] {
        [
            candidate(id: "primary-path", kind: .primary),
            candidate(id: "conservative-path", kind: .conservative, riskPosture: .low),
            candidate(id: "aggressive-path", kind: .aggressive, riskPosture: .stretch),
            candidate(id: "exploration-path", kind: .exploration, handlingLane: .unsupportedDomainExploration),
            candidate(id: "fallback-path", kind: .fallback, riskPosture: .measured),
            candidate(
                id: "north-star-path",
                kind: .northStar,
                handlingLane: .northStarExtraction,
                northStarOutcomeID: "north-star"
            )
        ]
    }

    func candidate(
        id: String,
        kind: AmbitionsOSLivingDreamPathKind,
        title: String = "Candidate path",
        summary: String = "A reviewed local candidate path.",
        handlingLane: AmbitionsOSLivingDreamHandlingLane = .sourceBackedPlan,
        sourceClaimIDs: [String] = ["claim-ready"],
        requirementIDs: [String] = ["requirement-ready"],
        firstProofStep: String = "Collect one proof point before committing.",
        northStarOutcomeID: String? = nil,
        riskPosture: AmbitionsOSLivingDreamPathRiskPosture = .measured,
        requiresUserReview: Bool = true,
        sourceReviewRequired: Bool = false,
        safetyReviewRequired: Bool = false,
        professionalBoundary: Bool = false,
        claimsGuarantee: Bool = false,
        activatesPlan: Bool = false,
        mutatesCommitments: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSLivingDreamPathPortfolioSchemaVersion
    ) -> AmbitionsOSLivingDreamPathCandidate {
        AmbitionsOSLivingDreamPathCandidate(
            id: id,
            kind: kind,
            title: title,
            summary: summary,
            handlingLane: handlingLane,
            sourceClaimIDs: sourceClaimIDs,
            requirementIDs: requirementIDs,
            firstProofStep: firstProofStep,
            northStarOutcomeID: northStarOutcomeID,
            riskPosture: riskPosture,
            requiresUserReview: requiresUserReview,
            sourceReviewRequired: sourceReviewRequired,
            safetyReviewRequired: safetyReviewRequired,
            professionalBoundary: professionalBoundary,
            claimsGuarantee: claimsGuarantee,
            activatesPlan: activatesPlan,
            mutatesCommitments: mutatesCommitments,
            runtimeBoundary: runtimeBoundary,
            schemaVersion: schemaVersion
        )
    }

    func readyIntakeEvaluation() -> AmbitionsOSLivingDreamStartingPositionPrivacyIntakeEvaluation {
        AmbitionsOSLivingDreamStartingPositionPrivacyIntakeEvaluation(
            packetID: "intake",
            requiredQuestionIDs: ["availability"],
            answeredQuestionIDs: ["availability"],
            blockedQuestionIDs: [],
            issues: [],
            storesUserData: false,
            mutatesCommitments: false,
            projectsExternally: false
        )
    }

    func sourceClaimGraph(
        claimQualityState: AmbitionsOSLivingDreamClaimQualityState = .reviewed
    ) -> AmbitionsOSLivingDreamSourceClaimGraph {
        AmbitionsOSLivingDreamSourceClaimGraph(
            claims: [
                AmbitionsOSLivingDreamSourceClaim(
                    id: "claim-ready",
                    claimType: .requirement,
                    value: "One proof point should be collected before commitment.",
                    jurisdiction: "general",
                    authorityLevel: .maintainerCurated,
                    sourceRefIDs: ["source-ready"],
                    sourceState: .sourceBacked,
                    freshnessPolicy: AmbitionsOSLivingDreamFreshnessPolicy(reviewIntervalDays: 90),
                    freshnessState: .current,
                    lastVerified: "2026-05-07",
                    effectiveDate: "2026-05-07",
                    claimQualityState: claimQualityState,
                    riskClass: .lowRiskSkill,
                    reviewState: .ready
                )
            ],
            sourceRefs: [
                AmbitionsOSLivingDreamSourceClaimReference(
                    id: "source-ready",
                    title: "Reviewed local source",
                    kind: .maintainerCurated,
                    locator: "local-fixture://path-portfolio",
                    retrievedAt: "2026-05-07",
                    reviewState: .ready
                )
            ]
        )
    }

    static func safeNorthStarOutcome() -> AmbitionsOSLivingDreamNorthStarOutcome {
        AmbitionsOSLivingDreamNorthStarOutcome(
            id: "north-star",
            requestID: "north-star-request",
            literalHandling: .meaningOnly,
            meaningStatement: "Treat the dream as a safe direction.",
            dimensions: [.impact],
            safeAlternativeSeeds: ["small proof step"],
            blockedLiteralSummary: "The literal dream is not guaranteed."
        )
    }
}
