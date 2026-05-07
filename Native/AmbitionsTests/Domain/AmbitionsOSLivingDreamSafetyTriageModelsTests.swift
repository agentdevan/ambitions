import XCTest
@testable import Ambitions

final class AmbitionsOSLivingDreamSafetyTriageModelsTests: XCTestCase {
    private let engine = AmbitionsOSLivingDreamSafetyTriageEngine()
    private let validator = AmbitionsOSLivingDreamSafetyTriageValidator()

    func testHardSafetyConcernsBlockNormalProductivityRouting() {
        for concern in hardBlockConcerns {
            let request = makeRequest(concerns: [concern])
            let outcome = engine.triage(request)

            XCTAssertTrue(outcome.blocksNormalProductivityRouting, concern.rawValue)
            XCTAssertFalse(outcome.permitsPlanCandidate, concern.rawValue)
            XCTAssertTrue([.unsafeBlocked, .crisisSupport].contains(outcome.primaryLane), concern.rawValue)
            XCTAssertEqual(validator.validate(request: request, outcome: outcome), [], concern.rawValue)
        }
    }

    func testCrisisInputUsesCrisisSupportLaneOnly() {
        let request = makeRequest(concerns: [.crisisOrSelfHarm])
        let outcome = engine.triage(request)

        XCTAssertEqual(outcome.primaryLane, .crisisSupport)
        XCTAssertEqual(outcome.disposition, .crisisSupport)
        XCTAssertTrue(outcome.blocksNormalProductivityRouting)
        XCTAssertFalse(outcome.permitsPlanCandidate)
        XCTAssertEqual(validator.validate(request: request, outcome: outcome), [])
    }

    func testRegulatedMinorAndDangerousDomainsRequireBoundaryReview() {
        let concerns: [AmbitionsOSLivingDreamSafetyConcern] = [
            .regulatedProfessionalDomain,
            .minorAgeSensitive,
            .dangerousHealthFitness
        ]

        for concern in concerns {
            let request = makeRequest(concerns: [concern], sourceState: .sourceNeeded)
            let outcome = engine.triage(request)

            XCTAssertTrue(outcome.professionalBoundaryRequired, concern.rawValue)
            XCTAssertTrue(outcome.sourceReviewRequired, concern.rawValue)
            XCTAssertTrue(outcome.requiresUserReview, concern.rawValue)
            XCTAssertEqual(validator.validate(request: request, outcome: outcome), [], concern.rawValue)
        }
    }

    func testImpossibleFantasyAndTimelineConcernsAvoidLiteralPlanClaims() {
        let fantasy = engine.triage(makeRequest(concerns: [.fantasyImpossible]))
        let timeline = engine.triage(makeRequest(concerns: [.impossibleTimeline]))

        XCTAssertEqual(fantasy.primaryLane, .northStarExtraction)
        XCTAssertEqual(fantasy.disposition, .northStarExtraction)
        XCTAssertTrue(fantasy.permitsPlanCandidate)
        XCTAssertEqual(timeline.primaryLane, .impossibleTimelineReview)
        XCTAssertEqual(timeline.disposition, .realityCheck)
        XCTAssertFalse(timeline.permitsPlanCandidate)
    }

    func testPrivacyAndSourceSensitiveInputsRequirePrePlanReviews() {
        let privateRequest = makeRequest(concerns: [.privacySensitive], privacyClass: .sensitive)
        let staleSourceRequest = makeRequest(
            concerns: [.sourceSensitive],
            sourceState: .sourceNeeded,
            freshnessState: .staleCritical
        )

        let privateOutcome = engine.triage(privateRequest)
        let sourceOutcome = engine.triage(staleSourceRequest)

        XCTAssertEqual(privateOutcome.primaryLane, .privacySensitivePlan)
        XCTAssertTrue(privateOutcome.privacyReviewRequired)
        XCTAssertEqual(sourceOutcome.primaryLane, .sourceStaleReview)
        XCTAssertTrue(sourceOutcome.sourceReviewRequired)
        XCTAssertFalse(sourceOutcome.permitsPlanCandidate)
    }

    func testValidatorCatchesUnsafeActivationAndBoundaryBreaks() {
        let request = makeRequest(concerns: [.illegalOrHarmful, .privacySensitive])
        let outcome = AmbitionsOSLivingDreamSafetyTriageOutcome(
            id: "bad",
            requestID: "other",
            primaryLane: .dreamScaffold,
            disposition: .safePlanningCandidate,
            receiptSummary: "bad",
            blocksNormalProductivityRouting: false,
            permitsPlanCandidate: true,
            requiresUserReview: false,
            professionalBoundaryRequired: false,
            sourceReviewRequired: false,
            privacyReviewRequired: false,
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
        XCTAssertTrue(issues.contains(.unsafeOperationalized))
        XCTAssertTrue(issues.contains(.privacyReviewMissing))
        XCTAssertTrue(issues.contains(.localFirstBoundaryBroken))
    }

    func testRedTeamFixturesCoverSafetyConcernMappings() {
        let fixtures = AmbitionsOSLivingDreamSafetyRedTeamCatalog.fixtures
        let concerns = Set(fixtures.map(\.concern))

        XCTAssertGreaterThanOrEqual(fixtures.count, 15)
        XCTAssertTrue(concerns.isSuperset(of: Set(AmbitionsOSLivingDreamSafetyConcern.allCases)))

        for fixture in fixtures {
            let request = makeRequest(
                id: fixture.id,
                concerns: [fixture.concern],
                sourceState: fixture.concern == .sourceSensitive ? .sourceNeeded : .userStated,
                freshnessState: fixture.concern == .sourceSensitive ? .staleCritical : .notApplicable,
                privacyClass: fixture.concern == .privacySensitive ? .sensitive : .privateLife
            )
            let outcome = engine.triage(request)

            XCTAssertEqual(outcome.primaryLane, fixture.expectedLane, fixture.id)
            XCTAssertEqual(outcome.disposition, fixture.expectedDisposition, fixture.id)
        }
    }
}

private extension AmbitionsOSLivingDreamSafetyTriageModelsTests {
    var hardBlockConcerns: [AmbitionsOSLivingDreamSafetyConcern] {
        [
            .illegalOrHarmful,
            .crisisOrSelfHarm,
            .harmToOthers,
            .stalkingHarassment,
            .fraudOrEvasion,
            .exploitationOrCoercion,
            .academicOrWorkplaceDishonesty,
            .delusionParanoiaCoded
        ]
    }

    func makeRequest(
        id: String = "safety-triage-1",
        inputSummary: String = "A dream that needs safety triage.",
        concerns: [AmbitionsOSLivingDreamSafetyConcern],
        sourceState: HumanProgressSourceState = .userStated,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        schemaVersion: String = ambitionsOSLivingDreamSafetyTriageSchemaVersion
    ) -> AmbitionsOSLivingDreamSafetyTriageRequest {
        AmbitionsOSLivingDreamSafetyTriageRequest(
            id: id,
            inputSummary: inputSummary,
            concerns: concerns,
            sourceState: sourceState,
            freshnessState: freshnessState,
            privacyClass: privacyClass,
            schemaVersion: schemaVersion
        )
    }
}
