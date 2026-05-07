import XCTest
@testable import Ambitions

final class AmbitionsOSLivingDreamHandlingModelsTests: XCTestCase {
    private let router = AmbitionsOSLivingDreamHandlingRouter()
    private let validator = AmbitionsOSLivingDreamHandlingValidator()

    func testCanonicalLaneSetMatchesLivingDreamSourceTruth() {
        let lanes = Set(AmbitionsOSLivingDreamHandlingLane.allCases.map(\.rawValue))

        XCTAssertEqual(
            lanes,
            [
                "parked_thought",
                "clarification_needed",
                "quick_step",
                "project_plan",
                "dream_scaffold",
                "source_backed_plan",
                "regulated_plan",
                "professional_boundary_scaffold",
                "north_star_extraction",
                "unsafe_blocked",
                "crisis_support",
                "source_stale_review",
                "source_conflict_review",
                "impossible_timeline_review",
                "conflict_review",
                "privacy_sensitive_plan",
                "sync_recovery",
                "unsupported_domain_exploration",
                "source_check_first",
                "user_review_required",
                "local_only_private_plan"
            ]
        )
    }

    func testQuickStepRoundTripsAndRequiresReviewBeforeActivation() throws {
        let request = makeRequest(inputKind: .oneStep, seriousness: .quick)
        let outcome = router.route(request)

        let data = try JSONEncoder().encode(outcome)
        let decoded = try JSONDecoder().decode(AmbitionsOSLivingDreamHandlingOutcome.self, from: data)

        XCTAssertEqual(decoded, outcome)
        XCTAssertEqual(decoded.primaryLane, .quickStep)
        XCTAssertTrue(decoded.requiresUserReview)
        XCTAssertTrue(decoded.mayActivateAfterReview)
        XCTAssertEqual(validator.validate(request: request, outcome: decoded), [])
    }

    func testUnsafeAndCrisisInputsBlockNormalProductivityRouting() {
        let unsafe = makeRequest(signals: [.unsafeOrIllegal])
        let crisis = makeRequest(signals: [.crisisCoded])

        let unsafeOutcome = router.route(unsafe)
        let crisisOutcome = router.route(crisis)

        XCTAssertEqual(unsafeOutcome.primaryLane, .unsafeBlocked)
        XCTAssertEqual(crisisOutcome.primaryLane, .crisisSupport)
        XCTAssertTrue(unsafeOutcome.blocksNormalProductivityRouting)
        XCTAssertTrue(crisisOutcome.blocksNormalProductivityRouting)
        XCTAssertFalse(unsafeOutcome.mayActivateAfterReview)
        XCTAssertFalse(crisisOutcome.mayActivateAfterReview)
        XCTAssertEqual(validator.validate(request: unsafe, outcome: unsafeOutcome), [])
        XCTAssertEqual(validator.validate(request: crisis, outcome: crisisOutcome), [])
    }

    func testAmbiguousInputRoutesToClarification() {
        let request = makeRequest(rawInputSummary: "??", signals: [.ambiguous])
        let outcome = router.route(request)

        XCTAssertEqual(outcome.primaryLane, .clarificationNeeded)
        XCTAssertTrue(outcome.requiresUserReview)
        XCTAssertFalse(outcome.mayActivateAfterReview)
    }

    func testRegulatedSourceBackedInputKeepsProfessionalBoundary() {
        let request = makeRequest(
            inputKind: .regulatedGoal,
            signals: [.regulatedDomain],
            sourceState: .sourceBacked,
            freshnessState: .current,
            reviewState: .ready
        )

        let outcome = router.route(request)

        XCTAssertEqual(outcome.primaryLane, .regulatedPlan)
        XCTAssertTrue(outcome.professionalBoundaryRequired)
        XCTAssertTrue(outcome.requiresUserReview)
        XCTAssertTrue(outcome.mayActivateAfterReview)
        XCTAssertEqual(validator.validate(request: request, outcome: outcome), [])
    }

    func testSourceStatesRouteToCheckStaleAndConflictBeforePlan() {
        let sourceNeeded = makeRequest(inputKind: .sourceSensitive, sourceState: .sourceNeeded)
        let stale = makeRequest(signals: [.sourceStale], freshnessState: .staleCritical)
        let conflict = makeRequest(signals: [.sourceConflict], sourceState: .disputed)

        XCTAssertEqual(router.route(sourceNeeded).primaryLane, .sourceCheckFirst)
        XCTAssertEqual(router.route(stale).primaryLane, .sourceStaleReview)
        XCTAssertEqual(router.route(conflict).primaryLane, .sourceConflictReview)
    }

    func testImpossibleAndPrivacySensitiveInputsUseBoundedLanes() {
        let impossible = makeRequest(inputKind: .impossibleOrSymbolic)
        let localOnly = makeRequest(
            inputKind: .privacySensitive,
            signals: [.privacySensitive, .localOnly],
            privacyClass: .sensitive
        )

        XCTAssertEqual(router.route(impossible).primaryLane, .northStarExtraction)
        XCTAssertEqual(router.route(localOnly).primaryLane, .localOnlyPrivatePlan)
    }

    func testValidatorCatchesUnsupportedSchemaActivationAndRuntimeBoundary() {
        let request = makeRequest(schemaVersion: "old.schema")
        let outcome = AmbitionsOSLivingDreamHandlingOutcome(
            id: "bad",
            requestID: "other",
            primaryLane: .sourceBackedPlan,
            ladderStepIndex: 7,
            receiptSummary: "bad",
            requiresUserReview: false,
            mayActivateAfterReview: true,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: true,
                mutatesPlans: true,
                writesPersistence: true
            ),
            schemaVersion: "old.schema"
        )

        let issues = validator.validate(request: request, outcome: outcome)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedOutcome))
        XCTAssertTrue(issues.contains(.activationWithoutReview))
        XCTAssertTrue(issues.contains(.localFirstBoundaryBroken))
    }
}

private extension AmbitionsOSLivingDreamHandlingModelsTests {
    func makeRequest(
        id: String = "dream-1",
        rawInputSummary: String = "Become stronger and apply for a community safety role.",
        inputKind: AmbitionsOSLivingDreamInputKind = .lifeDefiningDream,
        seriousness: AmbitionsOSLivingDreamSeriousness = .lifeDefining,
        signals: [AmbitionsOSLivingDreamSignal] = [],
        sourceState: HumanProgressSourceState = .userStated,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .needsUserReview,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        schemaVersion: String = ambitionsOSLivingDreamHandlingSchemaVersion
    ) -> AmbitionsOSLivingDreamHandlingRequest {
        AmbitionsOSLivingDreamHandlingRequest(
            id: id,
            rawInputSummary: rawInputSummary,
            inputKind: inputKind,
            seriousness: seriousness,
            signals: signals,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            privacyClass: privacyClass,
            schemaVersion: schemaVersion
        )
    }
}
