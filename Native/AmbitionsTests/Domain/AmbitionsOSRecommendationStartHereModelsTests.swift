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

    func testStartHereRecommendationCanCreateStructuredRejectCorrectionWithoutMutation() throws {
        let recommendation = startHere(
            controlActions: [.adjust, .explainMore, .reject, .start],
            surfaceLanguageSamples: ["Start here", "Not this"]
        )

        let correction = recommendation.rejectionCorrection(
            id: "start-here-rejection-1",
            reason: .rejectedTooLarge,
            note: "This is too large for the available time.",
            occurredAt: "2026-05-13T10:30:43Z"
        )
        let influence = try XCTUnwrap(
            CorrectionFoldRecommendationLearningInfluence(
                correction: correction,
                similarRecommendationSignalKeys: ["capacity", "scope"]
            )
        )

        XCTAssertTrue(recommendation.controlActions.contains(.reject))
        XCTAssertEqual(validator.validate(recommendation), [])
        XCTAssertTrue(correction.isWellFormed)
        XCTAssertEqual(correction.sourceObjectID, recommendation.id)
        XCTAssertEqual(correction.correctedRecommendation, .rejectedTooLarge)
        XCTAssertEqual(correction.effect, .suppressRecommendation)
        XCTAssertTrue(correction.allowsFutureLearning)
        XCTAssertFalse(correction.permitsSilentMutation)
        XCTAssertTrue(influence.isInspectableAndControllable)
        XCTAssertEqual(influence.adjustment, .downrankTooLarge)
        XCTAssertEqual(influence.similarRecommendationSignalKeys, ["capacity", "scope"])
    }

    func testReceiptBehaviorIsRequiredForTraceableRecommendation() {
        let recommendation = startHere(proofTrustReceipts: [])

        let issues = validator.validate(recommendation)

        XCTAssertTrue(issues.contains(.missingReceiptBehavior))
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

    func testSourceAtlasCurrentResultCanBridgeIntoStartHereSourceClaim() {
        let result = Self.sourceAtlasResult(
            sourceState: .officialCurrent,
            freshnessState: .current,
            riskState: .low,
            reviewState: .approved,
            provenanceSourceIDs: ["source-official"],
            fallbackReason: .none
        )
        let claim = AmbitionsOSStartHereRecommendation.sourceClaim(
            from: result,
            text: "The recommended step is grounded in an approved current source.",
            lastReviewedAt: "2026-05-13T06:32:00Z"
        )
        let recommendation = startHere(
            sourceLabel: "Source Atlas current source",
            sourceClaims: [claim],
            fitState: AmbitionsOSStartHereRecommendation.fitState(for: result)
        )

        XCTAssertEqual(claim.state, .officialSourceBacked)
        XCTAssertEqual(claim.freshnessState, .current)
        XCTAssertEqual(claim.reviewState, .ready)
        XCTAssertTrue(claim.canDriveSourceSensitiveRecommendation)
        XCTAssertEqual(recommendation.fitState, .fits)
        XCTAssertEqual(validator.validate(recommendation), [])
    }

    func testSourceAtlasBlockedResultsBridgeToReviewOrBlockedStartHereEvidence() {
        let cases: [(SourceAtlasQueryResult, AmbitionsOSRecommendationFitState)] = [
            (
                Self.sourceAtlasResult(sourceState: .sourceNeeded, freshnessState: .unknown, provenanceSourceIDs: [], fallbackReason: .sourceNeeded),
                .sourceNeeded
            ),
            (
                Self.sourceAtlasResult(sourceState: .stale, freshnessState: .stale, fallbackReason: .stale),
                .reviewable
            ),
            (
                Self.sourceAtlasResult(sourceState: .contradicted, fallbackReason: .contradicted),
                .blocked
            ),
            (
                Self.sourceAtlasResult(sourceState: .revoked, freshnessState: .stale, fallbackReason: .revoked),
                .blocked
            ),
            (
                Self.sourceAtlasResult(sourceState: .officialCurrent, riskState: .high, reviewState: .required, fallbackReason: .reviewRequired),
                .reviewable
            )
        ]

        for (result, expectedFitState) in cases {
            let claim = AmbitionsOSStartHereRecommendation.sourceClaim(
                from: result,
                text: "The source needs review before recommendation support."
            )
            let recommendation = startHere(
                sourceClaims: [claim],
                fitState: AmbitionsOSStartHereRecommendation.fitState(for: result)
            )
            let issues = validator.validate(recommendation)

            XCTAssertEqual(recommendation.fitState, expectedFitState)
            XCTAssertFalse(claim.canDriveSourceSensitiveRecommendation)
            XCTAssertTrue(issues.contains(.sourceReviewRequired))
            if result.freshnessState != .current {
                XCTAssertTrue(issues.contains(.staleSourceReviewRequired))
            }
        }
    }

    func testStartHereRecommendationProducesCompleteTrace() {
        let result = Self.sourceAtlasResult(
            sourceState: .officialCurrent,
            freshnessState: .current,
            riskState: .low,
            reviewState: .approved,
            provenanceSourceIDs: ["source-official"],
            fallbackReason: .none
        )
        let claim = AmbitionsOSStartHereRecommendation.sourceClaim(
            from: result,
            text: "The recommended step is grounded in an approved current source."
        )
        let explanation = traceExplanation(
            evidence: [.fromSourceAtlasQueryResult(result)]
        )
        let recommendation = startHere(
            sourceLabel: "Source Atlas current source",
            sourceClaims: [claim],
            fitState: .fits,
            controlActions: [.adjust, .explainMore, .start]
        )

        let trace = RecommendationTrace(startHere: recommendation, explanation: explanation)

        XCTAssertTrue(trace.isComplete)
        XCTAssertTrue(trace.canDriveRecommendationBehavior)
        XCTAssertEqual(trace.source.citedSourceIDs, ["source-atlas.result-none-official_current", "source-official", "source-pack-1"])
        XCTAssertEqual(trace.fit.state, .fits)
        XCTAssertEqual(trace.control.controlActionIDs, ["adjust", "explain_more", "start"])
        XCTAssertEqual(trace.receiptBehavior.state, .receiptAvailable)
        XCTAssertEqual(trace.receiptBehavior.actionReceiptIDs, ["action-receipt-1"])
        XCTAssertEqual(trace.receiptBehavior.proofReferenceIDs, ["proof-1"])
    }

    func testSourceBlockedStartHereTraceCannotDriveRecommendationBehavior() {
        let result = Self.sourceAtlasResult(
            sourceState: .sourceNeeded,
            freshnessState: .unknown,
            provenanceSourceIDs: [],
            fallbackReason: .sourceNeeded
        )
        let claim = AmbitionsOSStartHereRecommendation.sourceClaim(
            from: result,
            text: "A source is needed before this recommendation can drive behavior."
        )
        let explanation = traceExplanation(
            evidence: [.fromSourceAtlasQueryResult(result)]
        )
        let recommendation = startHere(
            sourceClaims: [claim],
            proofTrustReceipts: [],
            fitState: AmbitionsOSStartHereRecommendation.fitState(for: result)
        )

        let trace = RecommendationTrace(startHere: recommendation, explanation: explanation)

        XCTAssertFalse(trace.canDriveRecommendationBehavior)
        XCTAssertEqual(trace.fit.state, .sourceNeeded)
        XCTAssertEqual(trace.source.sourceAtlasBlockReasons, ["needs_source_review", "source_needed", "unknown"])
        XCTAssertEqual(trace.receiptBehavior.state, .receiptMissing)
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
        fitState: AmbitionsOSRecommendationFitState = .fits,
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
            fitState: fitState,
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

    func traceExplanation(
        evidence: [RecommendationExplanationEvidence]
    ) -> RecommendationExplanation {
        RecommendationExplanation(
            id: "explanation-trace-start-here",
            type: .whyThis,
            title: "Why this",
            summary: "Current source evidence and local controls explain this recommendation.",
            recommendationTitle: "Review the sourced step",
            evidence: evidence,
            uncertainty: [
                RecommendationExplanationUncertainty(
                    id: "uncertainty-duration",
                    summary: "The exact duration still needs review."
                )
            ],
            userCorrectableFields: ["duration"],
            correctionActions: [
                RecommendationExplanationCorrectionAction(
                    id: "correct-duration",
                    kind: .changeUrgency,
                    title: "Adjust duration",
                    targetFieldKey: "duration"
                )
            ],
            lastUpdatedAt: "2026-05-13T06:45:00Z",
            source: .recommendation
        )
    }

    static func sourceAtlasResult(
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState = .current,
        riskState: SourceAtlasRequirementRiskState = .low,
        reviewState: SourceAtlasRequirementReviewState = .approved,
        provenanceSourceIDs: [String] = ["source-official"],
        fallbackReason: SourceAtlasQueryFallbackReason
    ) -> SourceAtlasQueryResult {
        SourceAtlasQueryResult(
            id: "result-\(fallbackReason.rawValue)-\(sourceState.rawValue)",
            packID: "source-pack-1",
            domainID: "career",
            goalIntent: "starter_goal",
            claimID: "claim-1",
            requirementID: "requirement-1",
            sourceState: sourceState,
            freshnessState: freshnessState,
            riskState: riskState,
            riskClass: .careerContext,
            reviewState: reviewState,
            provenanceSourceIDs: provenanceSourceIDs,
            proofEntryIDs: ["proof-1"],
            fallbackReason: fallbackReason,
            sourceNeededDetail: nil
        )
    }
}
