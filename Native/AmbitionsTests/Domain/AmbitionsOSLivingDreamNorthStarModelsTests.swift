import XCTest
@testable import Ambitions

final class AmbitionsOSLivingDreamNorthStarModelsTests: XCTestCase {
    private let extractor = AmbitionsOSLivingDreamNorthStarExtractor()
    private let validator = AmbitionsOSLivingDreamNorthStarValidator()

    func testFantasyImpossibleDreamBecomesMeaningOnlyNorthStar() {
        let request = makeRequest(
            dreamSummary: "Become Batman and protect my city.",
            literalPhrase: "Become Batman",
            inputKind: .fantasyImpossible
        )

        let outcome = extractor.extract(request)

        XCTAssertEqual(outcome.primaryLane, .northStarExtraction)
        XCTAssertEqual(outcome.literalHandling, .meaningOnly)
        XCTAssertTrue(outcome.dimensions.contains(.protection))
        XCTAssertTrue(outcome.dimensions.contains(.justice))
        XCTAssertTrue(outcome.safeAlternativeSeeds.contains("community safety training"))
        XCTAssertFalse(outcome.claimsLiteralGuarantee)
        XCTAssertEqual(validator.validate(request: request, outcome: outcome), [])
    }

    func testUnsafeLiteralDreamNeverOperationalizesHarmfulPlan() {
        let request = makeRequest(
            dreamSummary: "Start a cult so people obey me.",
            literalPhrase: "Start a cult",
            inputKind: .unsafeLiteral,
            safetyConcerns: [.exploitationOrCoercion],
            safetyLane: .unsafeBlocked
        )

        let outcome = extractor.extract(request)

        XCTAssertEqual(outcome.literalHandling, .neverOperationalize)
        XCTAssertTrue(outcome.safeAlternativeSeeds.contains("ethical community building"))
        XCTAssertFalse(outcome.literalHandling.allowsLiteralPlan)
        XCTAssertEqual(validator.validate(request: request, outcome: outcome), [])
    }

    func testImpossibleTimelineRequiresRealityCheckWithoutPlanGuarantee() {
        let request = makeRequest(
            dreamSummary: "Become fluent and licensed in a week.",
            literalPhrase: "Do a decade of growth in one week",
            inputKind: .impossibleTimeline,
            safetyConcerns: [.impossibleTimeline],
            safetyLane: .impossibleTimelineReview
        )

        let outcome = extractor.extract(request)

        XCTAssertEqual(outcome.literalHandling, .realityCheckRequired)
        XCTAssertTrue(outcome.safeAlternativeSeeds.contains("realistic proof step"))
        XCTAssertFalse(outcome.claimsLiteralGuarantee)
    }

    func testSourceAndPrivacyReviewsAreCarriedIntoNorthStarOutcome() {
        let request = makeRequest(
            inputKind: .symbolicIdentity,
            sourceState: .sourceNeeded,
            freshnessState: .staleCritical,
            privacyClass: .sensitive
        )

        let outcome = extractor.extract(request)

        XCTAssertTrue(outcome.sourceReviewRequired)
        XCTAssertTrue(outcome.privacyReviewRequired)
        XCTAssertEqual(validator.validate(request: request, outcome: outcome), [])
    }

    func testValidatorBlocksLiteralGuaranteesProfessionalClaimsAndRuntimeMutation() {
        let request = makeRequest(
            inputKind: .unsafeLiteral,
            safetyConcerns: [.illegalOrHarmful],
            safetyLane: .unsafeBlocked,
            sourceState: .sourceNeeded,
            privacyClass: .sensitive
        )
        let outcome = AmbitionsOSLivingDreamNorthStarOutcome(
            id: "bad",
            requestID: "other",
            primaryLane: .dreamScaffold,
            literalHandling: .safeCandidateReview,
            meaningStatement: "",
            dimensions: [],
            safeAlternativeSeeds: [],
            blockedLiteralSummary: "",
            preservesIdentityContinuity: false,
            requiresUserReview: false,
            sourceReviewRequired: false,
            privacyReviewRequired: false,
            claimsLiteralGuarantee: true,
            claimsProfessionalGuidance: true,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: true,
                mutatesPlans: true,
                writesPersistence: true
            ),
            schemaVersion: "old"
        )

        let issues = validator.validate(request: request, outcome: outcome)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedOutcome))
        XCTAssertTrue(issues.contains(.wrongHandlingLane))
        XCTAssertTrue(issues.contains(.unsafeLiteralOperationalized))
        XCTAssertTrue(issues.contains(.sourceReviewMissing))
        XCTAssertTrue(issues.contains(.privacyReviewMissing))
        XCTAssertTrue(issues.contains(.userReviewMissing))
        XCTAssertTrue(issues.contains(.literalGuaranteeClaim))
        XCTAssertTrue(issues.contains(.professionalBoundaryClaim))
        XCTAssertTrue(issues.contains(.runtimeBoundaryBroken))
    }
}

private extension AmbitionsOSLivingDreamNorthStarModelsTests {
    func makeRequest(
        id: String = "north-star-1",
        dreamSummary: String = "A symbolic direction that needs safe meaning.",
        literalPhrase: String = "Become something impossible",
        inputKind: AmbitionsOSLivingDreamNorthStarInputKind,
        safetyConcerns: [AmbitionsOSLivingDreamSafetyConcern] = [],
        safetyLane: AmbitionsOSLivingDreamHandlingLane = .northStarExtraction,
        sourceState: HumanProgressSourceState = .userStated,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .needsUserReview,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        schemaVersion: String = ambitionsOSLivingDreamNorthStarSchemaVersion
    ) -> AmbitionsOSLivingDreamNorthStarRequest {
        AmbitionsOSLivingDreamNorthStarRequest(
            id: id,
            dreamSummary: dreamSummary,
            literalPhrase: literalPhrase,
            inputKind: inputKind,
            safetyConcerns: safetyConcerns,
            safetyLane: safetyLane,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            privacyClass: privacyClass,
            schemaVersion: schemaVersion
        )
    }
}
