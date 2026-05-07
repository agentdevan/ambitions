import XCTest
@testable import Ambitions

final class AmbitionsOSRecommendationStartHereModelsTests: XCTestCase {
    private let validator = AmbitionsOSStartHereRecommendationValidator()

    func testReviewReadyStartHereRecommendationRoundTrips() throws {
        let recommendation = startHere()

        let data = try JSONEncoder().encode(recommendation)
        let decoded = try JSONDecoder().decode(AmbitionsOSStartHereRecommendation.self, from: data)

        XCTAssertEqual(decoded.schemaVersion, ambitionsOSRecommendationStartHereSchemaVersion)
        XCTAssertEqual(decoded.kind, .startHere)
        XCTAssertEqual(decoded.fitState, .fits)
        XCTAssertEqual(validator.validate(decoded), [])
    }

    func testInvalidSchemaMalformedRecommendationAndMissingSourceAreRejected() {
        let recommendation = startHere(
            id: "",
            title: "",
            recommendedObjectID: "",
            sourceLabel: "",
            sourceClaims: [],
            schemaVersion: "old.schema"
        )

        let issues = validator.validate(recommendation)

        XCTAssertTrue(issues.contains(.unsupportedSchema))
        XCTAssertTrue(issues.contains(.malformedRecommendation))
        XCTAssertTrue(issues.contains(.missingSourceLabel))
    }

    func testSourceClaimsMustBeReviewReadyAndFresh() {
        let recommendation = startHere(
            sourceClaims: [
                sourceClaim(
                    state: .sourceNeeded,
                    freshnessState: .staleCritical,
                    reviewState: .needsSourceReview
                )
            ]
        )

        let issues = validator.validate(recommendation)

        XCTAssertTrue(issues.contains(.sourceReviewRequired))
        XCTAssertTrue(issues.contains(.staleSourceReviewRequired))
    }

    func testProofTrustAndControlPlaneGatesBlockRecommendation() {
        let blocked = startHere(
            proofTrustReceipts: [proofReceipt(actionReceiptIDs: [], proofReferenceIDs: [])],
            controlClassification: controlClassification(disposition: .blocked, gates: [.safetyReview])
        )

        let issues = validator.validate(blocked)

        XCTAssertTrue(issues.contains(.proofTrustReviewRequired))
        XCTAssertTrue(issues.contains(.controlPlaneBlocksRecommendation))
    }

    func testExplanationAndUserControlsAreRequired() {
        let recommendation = startHere(
            whyNow: [],
            advances: [],
            protects: [],
            assumptions: [],
            controlActions: []
        )

        let issues = validator.validate(recommendation)

        XCTAssertTrue(issues.contains(.missingExplanation))
        XCTAssertTrue(issues.contains(.missingUserControl))
    }

    func testConfidenceScoreGenericPriorityGuaranteeAndBadLanguageAreBlocked() {
        let recommendation = startHere(
            exposesConfidenceScore: true,
            usesGenericPriorityOnly: true,
            claimsGuaranteedOutcome: true,
            surfaceLanguageSamples: [
                "AI " + "confidence 91 percent says this is the next " + "best move and guaranteed."
            ]
        )

        let issues = validator.validate(recommendation)

        XCTAssertTrue(issues.contains(.confidenceScoreExposed))
        XCTAssertTrue(issues.contains(.genericPriorityOnly))
        XCTAssertTrue(issues.contains(.guaranteedOutcomeLanguage))
        XCTAssertTrue(issues.contains(.harmfulRecommendationLanguage))
    }

    func testHiddenMutationPrivacyAndRuntimeStoreBehaviorAreBlocked() {
        let recommendation = startHere(
            mutatesPlansAutomatically: true,
            privacyClass: .sensitive,
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: true,
                mutatesPlans: true,
                writesPersistence: true
            )
        )

        let issues = validator.validate(recommendation)

        XCTAssertTrue(issues.contains(.hiddenMutationRisk))
        XCTAssertTrue(issues.contains(.privateExternalProjectionRisk))
        XCTAssertTrue(issues.contains(.runtimeStoreBehavior))
    }
}

private extension AmbitionsOSRecommendationStartHereModelsTests {
    func startHere(
        id: String = "start-here-1",
        title: String = "Review the next concrete step",
        recommendedObjectID: String = "step-1",
        sourceLabel: String = "Based on your plan",
        sourceClaims: [AmbitionsOSSourceTruthClaim]? = nil,
        proofTrustReceipts: [AmbitionsOSProofTrustReceipt]? = nil,
        controlClassification: AmbitionsOSControlPlaneClassification? = nil,
        whyNow: [String] = ["You have a ready step."],
        advances: [String] = ["Moves the goal forward."],
        protects: [String] = ["Keeps protected time intact."],
        assumptions: [String] = ["Duration still needs your review if it feels off."],
        controlActions: [AmbitionsOSStartHereControlAction] = [.start, .open, .adjust],
        exposesConfidenceScore: Bool = false,
        usesGenericPriorityOnly: Bool = false,
        claimsGuaranteedOutcome: Bool = false,
        mutatesPlansAutomatically: Bool = false,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        surfaceLanguageSamples: [String] = ["Start here"],
        schemaVersion: String = ambitionsOSRecommendationStartHereSchemaVersion
    ) -> AmbitionsOSStartHereRecommendation {
        AmbitionsOSStartHereRecommendation(
            id: id,
            title: title,
            kind: .startHere,
            surface: .today,
            recommendedObjectID: recommendedObjectID,
            sourceLabel: sourceLabel,
            sourceClaims: sourceClaims ?? [sourceClaim()],
            proofTrustReceipts: proofTrustReceipts ?? [proofReceipt()],
            controlClassification: controlClassification ?? self.controlClassification(),
            fitState: .fits,
            whyNow: whyNow,
            advances: advances,
            protects: protects,
            assumptions: assumptions,
            controlActions: controlActions,
            exposesConfidenceScore: exposesConfidenceScore,
            usesGenericPriorityOnly: usesGenericPriorityOnly,
            claimsGuaranteedOutcome: claimsGuaranteedOutcome,
            mutatesPlansAutomatically: mutatesPlansAutomatically,
            privacyClass: privacyClass,
            runtimeBoundary: runtimeBoundary,
            surfaceLanguageSamples: surfaceLanguageSamples,
            schemaVersion: schemaVersion
        )
    }

    func sourceClaim(
        state: AmbitionsOSSourceTruthClaimState = .officialSourceBacked,
        freshnessState: HumanProgressFreshnessState = .current,
        reviewState: HumanProgressReviewState = .ready
    ) -> AmbitionsOSSourceTruthClaim {
        AmbitionsOSSourceTruthClaim(
            id: "claim-1",
            text: "The step is grounded in the user's plan.",
            scopeID: "goal-1",
            state: state,
            sourceQualityState: .official,
            freshnessState: freshnessState,
            riskClass: .careerContext,
            sourceIDs: ["source-1"],
            sourcePackIDs: ["pack-1"],
            reviewState: reviewState,
            lastReviewedAt: "2026-05-06T23:45:00Z"
        )
    }

    func proofReceipt(
        actionReceiptIDs: [String] = ["action-receipt-1"],
        proofReferenceIDs: [String] = ["proof-1"]
    ) -> AmbitionsOSProofTrustReceipt {
        AmbitionsOSProofTrustReceipt(
            id: "proof-1",
            kind: .proof,
            surface: .today,
            occurredAt: "2026-05-06T23:45:00Z",
            affectedObjectIDs: ["step-1"],
            actionReceiptIDs: actionReceiptIDs,
            proofReferenceIDs: proofReferenceIDs,
            sourceClaimIDs: ["claim-1"],
            sourcePackIDs: ["pack-1"],
            closureOutcome: .needsReview,
            sourceState: .sourceBacked,
            freshnessState: .current,
            reviewState: .ready
        )
    }

    func controlClassification(
        disposition: AmbitionsOSControlPlaneDisposition = .allowLocalWork,
        gates: [AmbitionsOSControlPlaneGate] = []
    ) -> AmbitionsOSControlPlaneClassification {
        AmbitionsOSControlPlaneClassification(
            id: "classification-1",
            requestID: "request-1",
            workClass: .interactive,
            disposition: disposition,
            requiredGates: gates,
            allowedOutputs: [.recommendation, .reviewRequest],
            rationaleIDs: ["ready_start_here"]
        )
    }
}
