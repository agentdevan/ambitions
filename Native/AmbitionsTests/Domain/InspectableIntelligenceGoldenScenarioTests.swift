import XCTest
@testable import Ambitions

final class InspectableIntelligenceGoldenScenarioTests: XCTestCase {
    private let validator = AmbitionsOSStartHereRecommendationValidator()

    func testSourceBackedRecommendationCanDriveTraceWhileBlockedSourceStatesCannot() throws {
        let pack = Self.pack(
            claims: [
                Self.claim(id: "claim-current", state: .official, freshness: .current, sourceIDs: ["source-current"], reviewRequired: false),
                Self.claim(id: "claim-stale", state: .stale, freshness: .stale, sourceIDs: ["source-current"], reviewRequired: false),
                Self.claim(id: "claim-needed", state: .sourceNeeded, freshness: .unknown),
                Self.claim(id: "claim-wrong", state: .revoked, freshness: .revoked, sourceIDs: ["source-current"], reviewRequired: false)
            ],
            requirements: [
                Self.requirement(id: "requirement-current", claimID: "claim-current", sourceState: .officialCurrent, freshnessState: .current, reviewState: .approved),
                Self.requirement(id: "requirement-stale", claimID: "claim-stale", sourceState: .stale, freshnessState: .stale, reviewState: .approved),
                Self.requirement(id: "requirement-needed", claimID: "claim-needed", sourceState: .sourceNeeded, freshnessState: .unknown, reviewState: .required),
                Self.requirement(id: "requirement-wrong", claimID: "claim-wrong", sourceState: .revoked, freshnessState: .stale, reviewState: .blocked)
            ]
        )
        let engine = SourceAtlasQueryEngine(packs: [pack])

        let current = engine.query(SourceAtlasQuery(requirementID: "requirement-current")).selectedResult
        let currentTrace = trace(for: current)

        XCTAssertTrue(current.canSupportCurrentUse)
        XCTAssertTrue(currentTrace.isComplete)
        XCTAssertTrue(currentTrace.canDriveRecommendationBehavior)
        XCTAssertEqual(currentTrace.fit.state, .fits)
        XCTAssertTrue(currentTrace.source.citedSourceIDs.contains("source-current"))
        XCTAssertEqual(validator.validate(startHere(for: current)), [])

        let blockedRequirementIDs = ["requirement-stale", "requirement-needed", "requirement-wrong"]
        for requirementID in blockedRequirementIDs {
            let result = engine.query(SourceAtlasQuery(requirementID: requirementID)).selectedResult
            let recommendation = startHere(for: result)
            let trace = trace(for: result)
            let issues = validator.validate(recommendation)

            XCTAssertFalse(result.canSupportCurrentUse)
            XCTAssertFalse(trace.canDriveRecommendationBehavior)
            XCTAssertFalse(trace.source.sourceAtlasBlockReasons.isEmpty)
            XCTAssertTrue(issues.contains(.sourceReviewRequired))
        }
    }

    func testWhyThisTraceIncludesSourceReasonFitUncertaintyControlsAndReceiptBehavior() throws {
        let result = Self.sourceAtlasResult(
            sourceState: .officialCurrent,
            freshnessState: .current,
            riskState: .low,
            reviewState: .approved,
            provenanceSourceIDs: ["source-current"],
            fallbackReason: .none
        )
        let trace = trace(for: result)
        let trustSeam = RecommendationTrustSeamState(trace: trace)

        XCTAssertTrue(trace.isComplete)
        XCTAssertTrue(trace.canDriveRecommendationBehavior)
        XCTAssertEqual(trace.source.citedSourceIDs, ["source-atlas.result-none-official_current", "source-current", "source-pack-1"])
        XCTAssertEqual(trace.reason.evidenceCategoryIDs, ["source_truth"])
        XCTAssertEqual(trace.fit.state, .fits)
        XCTAssertEqual(trace.uncertainty.uncertaintyIDs, ["uncertainty-duration"])
        XCTAssertEqual(trace.control.controlActionIDs, ["adjust", "explain_more", "reject", "start"])
        XCTAssertEqual(trace.control.correctableFieldKeys, ["duration"])
        XCTAssertEqual(trace.receiptBehavior.state, .receiptAvailable)
        XCTAssertEqual(trace.receiptBehavior.actionReceiptIDs, ["action-receipt-1"])
        XCTAssertEqual(trace.receiptBehavior.proofReferenceIDs, ["proof-1"])
        XCTAssertEqual(trustSeam.sectionKinds, [.source, .reason, .fit, .uncertainty, .controls, .receiptBehavior])
        XCTAssertTrue(trustSeam.canProceed)
        XCTAssertFalse(trustSeam.needsReview)
        XCTAssertFalse(trustSeam.hasVisibleCopyGuardrailViolation)
    }

    func testRejectedRecommendationCreatesStructuredLocalCorrectionAndInspectableLearningInfluence() throws {
        let recommendation = startHere(
            id: "recommendation-low-energy",
            sourceClaims: [sourceClaim()],
            fitState: .fits
        )

        let correction = recommendation.rejectionCorrection(
            id: "correction-low-energy",
            reason: .rejectedLowEnergyContext,
            note: "This kind of step does not fit low-energy context.",
            occurredAt: "2026-05-13T11:35:35Z"
        )
        let influence = try XCTUnwrap(
            CorrectionFoldRecommendationLearningInfluence(
                correction: correction,
                similarRecommendationSignalKeys: ["capacity", "energy_fit", "capacity"]
            )
        )
        let futureTrace = RecommendationTrace(
            id: "trace-future-low-energy",
            recommendationID: "recommendation-future",
            source: RecommendationTraceSource(
                citedSourceIDs: ["source-current"],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.capacity],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation-future-low-energy",
                summary: "Local source context supports reviewing this step.",
                evidenceCategoryIDs: ["capacity"]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty-energy"],
                summaries: ["Energy fit may need review."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["correct-energy"],
                controlActionIDs: ["reject"],
                correctableFieldKeys: ["energy_fit"],
                hasRequiredControl: true
            ),
            receiptBehavior: .available(actionReceiptIDs: ["action-receipt-1"]),
            rejectionLearningInfluences: [influence]
        )

        XCTAssertTrue(correction.isWellFormed)
        XCTAssertEqual(correction.target, .recommendation)
        XCTAssertEqual(correction.effect, .suppressRecommendation)
        XCTAssertTrue(correction.requiresUserVisibleReceipt)
        XCTAssertFalse(correction.permitsSilentMutation)
        XCTAssertTrue(influence.isInspectableAndControllable)
        XCTAssertTrue(influence.localOnly)
        XCTAssertTrue(influence.resetDeleteCompatible)
        XCTAssertEqual(influence.adjustment, .downrankLowEnergyContext)
        XCTAssertEqual(influence.similarRecommendationSignalKeys, ["capacity", "energy_fit"])
        XCTAssertEqual(futureTrace.rejectionLearningRankAdjustment, CorrectionFoldRecommendationLearningAdjustment.downrankLowEnergyContext.baseRankAdjustment)
        XCTAssertFalse(futureTrace.isSuppressedByRejectionLearning)
        XCTAssertTrue(futureTrace.canDriveRecommendationBehavior)
    }

    func testSameIntentProducesDifferentPlansAcrossBusyProtectedAndOpenCapacityContexts() {
        let goalID = "goal-same-intent"

        let busyExplanation = makePrivateLifeExplanation(
            id: "explanation.private-life.busy",
            type: .whyPrioritized,
            title: "Why this gets protected",
            summary: "Same intent, but the protected window is small so the next step stays smaller and safer.",
            recommendationTitle: "Take the smallest safe next step",
            recommendationSummary: "Protect the window and keep the change local.",
            goalID: goalID,
            contextID: "context-busy",
            evidence: [
                RecommendationExplanationEvidence(
                    id: "evidence.intent.busy",
                    category: .sourceTruth,
                    title: "Same intent",
                    summary: "The same goal still matters.",
                    sourceID: goalID
                ),
                RecommendationExplanationEvidence(
                    id: "evidence.capacity.busy",
                    category: .capacity,
                    title: "Busy capacity",
                    summary: "Only a small protected window is open.",
                    sourceID: "reality-busy"
                ),
                RecommendationExplanationEvidence(
                    id: "evidence.context.busy",
                    category: .contextLens,
                    title: "Protected context",
                    summary: "The local context is busy and protected.",
                    sourceID: "context-busy"
                ),
                RecommendationExplanationEvidence(
                    id: "evidence.recovery.busy",
                    category: .recovery,
                    title: "Safer path",
                    summary: "The next step should stay smaller.",
                    sourceID: "recovery-busy"
                )
            ],
            uncertaintySummary: "The exact duration still needs review.",
            correctableFieldKeys: ["capacity", "context", "urgency"],
            correctionActions: [
                RecommendationExplanationCorrectionAction(
                    id: "correct-busy-context",
                    kind: .changeDomainContext,
                    title: "Adjust context",
                    targetFieldKey: "context"
                ),
                RecommendationExplanationCorrectionAction(
                    id: "correct-busy-urgency",
                    kind: .changeUrgency,
                    title: "Adjust urgency",
                    targetFieldKey: "urgency"
                )
            ]
        )
        let busyTrace = makePrivateLifeTrace(
            explanation: busyExplanation,
            receiptIDs: ["receipt-busy"],
            actionReceiptIDs: ["action-receipt-busy"],
            proofReferenceIDs: ["proof-busy"]
        )

        let openExplanation = makePrivateLifeExplanation(
            id: "explanation.private-life.open",
            type: .whyScheduled,
            title: "Why this goes deeper",
            summary: "Same intent, and the open window supports a fuller follow-through step.",
            recommendationTitle: "Do the deeper follow-through step",
            recommendationSummary: "Use the open window to move farther into the same goal instead of shrinking it.",
            goalID: goalID,
            contextID: "context-open",
            evidence: [
                RecommendationExplanationEvidence(
                    id: "evidence.intent.open",
                    category: .sourceTruth,
                    title: "Same intent",
                    summary: "The same goal still matters.",
                    sourceID: goalID
                ),
                RecommendationExplanationEvidence(
                    id: "evidence.capacity.open",
                    category: .capacity,
                    title: "Open capacity",
                    summary: "A longer useful work window is open.",
                    sourceID: "reality-open"
                ),
                RecommendationExplanationEvidence(
                    id: "evidence.goal.open",
                    category: .goalState,
                    title: "Goal state",
                    summary: "The goal can absorb more follow-through now.",
                    sourceID: goalID
                ),
                RecommendationExplanationEvidence(
                    id: "evidence.priority.open",
                    category: .priority,
                    title: "Priority fit",
                    summary: "The larger step still fits the current priority picture.",
                    sourceID: "priority-open"
                )
            ],
            uncertaintySummary: "The exact ordering still benefits from review.",
            correctableFieldKeys: ["importance", "scope", "timing"],
            correctionActions: [
                RecommendationExplanationCorrectionAction(
                    id: "correct-open-importance",
                    kind: .changeImportance,
                    title: "Adjust importance",
                    targetFieldKey: "importance"
                ),
                RecommendationExplanationCorrectionAction(
                    id: "correct-open-support",
                    kind: .markGoalSupporting,
                    title: "Mark goal-supporting",
                    targetFieldKey: "goalRelationship"
                )
            ]
        )
        let openTrace = makePrivateLifeTrace(
            explanation: openExplanation,
            receiptIDs: ["receipt-open"],
            actionReceiptIDs: ["action-receipt-open"],
            proofReferenceIDs: ["proof-open"]
        )

        XCTAssertEqual(busyExplanation.relations.goalIDs, [goalID])
        XCTAssertEqual(openExplanation.relations.goalIDs, [goalID])
        XCTAssertEqual(busyExplanation.recommendationTitle, "Take the smallest safe next step")
        XCTAssertEqual(openExplanation.recommendationTitle, "Do the deeper follow-through step")

        XCTAssertEqual(busyTrace.source.localEvidenceCategories, [.capacity, .contextLens, .recovery, .sourceTruth])
        XCTAssertEqual(openTrace.source.localEvidenceCategories, [.capacity, .goalState, .priority, .sourceTruth])
        XCTAssertEqual(busyTrace.source.citedSourceIDs, ["context-busy", "goal-same-intent", "reality-busy", "recovery-busy"])
        XCTAssertEqual(openTrace.source.citedSourceIDs, ["goal-same-intent", "priority-open", "reality-open"])
        XCTAssertEqual(busyTrace.reason.evidenceCategoryIDs, ["capacity", "context_lens", "recovery", "source_truth"])
        XCTAssertEqual(openTrace.reason.evidenceCategoryIDs, ["capacity", "goal_state", "priority", "source_truth"])
        XCTAssertEqual(busyTrace.source.sourceAtlasBlockReasons, [])
        XCTAssertEqual(busyTrace.fit.blockReasons, [])
        XCTAssertEqual(openTrace.source.sourceAtlasBlockReasons, [])
        XCTAssertEqual(openTrace.fit.blockReasons, [])
        XCTAssertTrue(busyTrace.isComplete)
        XCTAssertTrue(openTrace.isComplete)
        XCTAssertTrue(busyTrace.canDriveRecommendationBehavior)
        XCTAssertTrue(openTrace.canDriveRecommendationBehavior)
        XCTAssertNotEqual(busyTrace.id, openTrace.id)
        XCTAssertNotEqual(busyTrace.recommendationID, openTrace.recommendationID)
    }

    func testReplayBoundaryKeepsDeterministicTraceIdentityAndReceiptReferencesWithoutPersistenceOverclaim() {
        let explanation = makePrivateLifeExplanation(
            id: "explanation.private-life.replay",
            type: .whyScheduled,
            title: "Why this stays stable",
            summary: "The same local inputs should rebuild the same recommendation trace.",
            recommendationTitle: "Keep the same local plan",
            recommendationSummary: "This only proves deterministic reconstruction, not persistence storage.",
            goalID: "goal-replay",
            contextID: "context-replay",
            evidence: [
                RecommendationExplanationEvidence(
                    id: "evidence.intent.replay",
                    category: .sourceTruth,
                    title: "Same intent",
                    summary: "The intent remains the same across relaunch.",
                    sourceID: "goal-replay"
                ),
                RecommendationExplanationEvidence(
                    id: "evidence.capacity.replay",
                    category: .capacity,
                    title: "Replay capacity",
                    summary: "The same local capacity facts rebuild the same step.",
                    sourceID: "reality-replay"
                )
            ],
            uncertaintySummary: "The trace remains inspectable after replay.",
            correctableFieldKeys: ["capacity"],
            correctionActions: [
                RecommendationExplanationCorrectionAction(
                    id: "correct-replay-capacity",
                    kind: .changeUrgency,
                    title: "Adjust urgency",
                    targetFieldKey: "capacity"
                )
            ]
        )

        let replayA = makePrivateLifeTrace(
            explanation: explanation,
            receiptIDs: ["receipt-replay"],
            actionReceiptIDs: ["action-receipt-replay"],
            proofReferenceIDs: ["proof-replay"]
        )
        let replayB = makePrivateLifeTrace(
            explanation: explanation,
            receiptIDs: ["receipt-replay"],
            actionReceiptIDs: ["action-receipt-replay"],
            proofReferenceIDs: ["proof-replay"]
        )

        XCTAssertEqual(replayA, replayB)
        XCTAssertEqual(replayA.id, "trace.\(explanation.id)")
        XCTAssertEqual(replayA.receiptBehavior.receiptIDs, ["receipt-replay"])
        XCTAssertEqual(replayA.receiptBehavior.actionReceiptIDs, ["action-receipt-replay"])
        XCTAssertEqual(replayA.receiptBehavior.proofReferenceIDs, ["proof-replay"])
        XCTAssertTrue(replayA.canDriveRecommendationBehavior)
    }

    func testCorrectionInfluenceStaysLocalInspectableAndResetDeleteCompatible() throws {
        let correction = CorrectionFoldRecord.recommendation(
            id: "recommendation-correction-private-life",
            recommendationID: "recommendation.private-life.future",
            from: .stillUseful,
            to: .rejectedLowEnergyContext,
            reason: "This should stay smaller when the same low-energy context appears again.",
            occurredAt: "2026-05-17T05:12:17Z"
        )
        let influence = try XCTUnwrap(
            CorrectionFoldRecommendationLearningInfluence(
                correction: correction,
                similarRecommendationSignalKeys: ["capacity", "context", "capacity"]
            )
        )
        let futureExplanation = makePrivateLifeExplanation(
            id: "explanation.private-life.future",
            type: .whyThis,
            title: "Why this remains reviewable",
            summary: "Future recommendations should stay inspectable and local after correction.",
            recommendationTitle: "Keep the future recommendation local",
            recommendationSummary: "The correction should influence later behavior without mutating plans silently.",
            goalID: "goal-future",
            contextID: "context-future",
            evidence: [
                RecommendationExplanationEvidence(
                    id: "evidence.intent.future",
                    category: .sourceTruth,
                    title: "Same intent",
                    summary: "The same goal remains the anchor.",
                    sourceID: "goal-future"
                ),
                RecommendationExplanationEvidence(
                    id: "evidence.capacity.future",
                    category: .capacity,
                    title: "Corrected capacity",
                    summary: "The local correction keeps this grounded in the same capacity pattern.",
                    sourceID: "reality-future"
                )
            ],
            uncertaintySummary: "The correction can still be reviewed or reset.",
            correctableFieldKeys: ["capacity"],
            correctionActions: [
                RecommendationExplanationCorrectionAction(
                    id: "correct-future-capacity",
                    kind: .changeUrgency,
                    title: "Adjust urgency",
                    targetFieldKey: "capacity"
                )
            ]
        )
        let futureTrace = RecommendationTrace(
            id: "trace.\(futureExplanation.id)",
            recommendationID: futureExplanation.id,
            source: RecommendationTraceSource(
                citedSourceIDs: futureExplanation.recommendationEvidenceModel.citedSourceIDs,
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: futureExplanation.recommendationEvidenceModel.categories,
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: futureExplanation.id,
                summary: futureExplanation.summary,
                evidenceCategoryIDs: futureExplanation.recommendationEvidenceModel.categories.map(\.rawValue)
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: futureExplanation.uncertainty.map(\.id).sorted(),
                summaries: futureExplanation.uncertainty.map(\.summary).sorted()
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: futureExplanation.correctionActions.map(\.id).sorted(),
                controlActionIDs: [],
                correctableFieldKeys: futureExplanation.userCorrectableFields,
                hasRequiredControl: true
            ),
            receiptBehavior: .available(
                receiptIDs: ["receipt-future"],
                actionReceiptIDs: ["action-receipt-future"],
                proofReferenceIDs: ["proof-future"]
            ),
            rejectionLearningInfluences: [influence]
        )

        XCTAssertTrue(influence.isInspectableAndControllable)
        XCTAssertTrue(influence.localOnly)
        XCTAssertTrue(influence.resetDeleteCompatible)
        XCTAssertFalse(influence.permitsSilentMutation)
        XCTAssertEqual(influence.adjustment, .downrankLowEnergyContext)
        XCTAssertEqual(influence.similarRecommendationSignalKeys, ["capacity", "context"])
        XCTAssertEqual(futureTrace.rejectionLearningRankAdjustment, influence.adjustment.baseRankAdjustment)
        XCTAssertFalse(futureTrace.isSuppressedByRejectionLearning)
        XCTAssertTrue(futureTrace.canDriveRecommendationBehavior)
    }

    func testResetDeleteAndDisableLearningInputsRemoveFutureLearningUseAndCreateLocalReceipts() {
        let reset = learningInputCorrection(id: "learning-reset", learningInputID: "input-reset", to: .reset)
        let delete = learningInputCorrection(id: "learning-delete", learningInputID: "input-delete", to: .delete)
        let disable = learningInputCorrection(id: "learning-disable", learningInputID: "input-disable", to: .disableSignal)

        for correction in [reset, delete, disable] {
            XCTAssertTrue(correction.isWellFormed)
            XCTAssertEqual(correction.target, .learningInput)
            XCTAssertEqual(correction.effect, .removeLearningInput)
            XCTAssertTrue(correction.correctedLearningInput?.removesLearningUse == true)
            XCTAssertFalse(correction.allowsFutureLearning)
            XCTAssertTrue(correction.receipt.localOnly)
            XCTAssertTrue(correction.receipt.isWellFormed)
            XCTAssertEqual(correction.receipt.action, .reset)
            XCTAssertFalse(correction.permitsSilentMutation)
        }
    }
}

private extension InspectableIntelligenceGoldenScenarioTests {
    func trace(for result: SourceAtlasQueryResult) -> RecommendationTrace {
        RecommendationTrace(
            startHere: startHere(for: result),
            explanation: explanation(for: result)
        )
    }

    func startHere(
        for result: SourceAtlasQueryResult
    ) -> AmbitionsOSStartHereRecommendation {
        startHere(
            sourceClaims: [
                AmbitionsOSStartHereRecommendation.sourceClaim(
                    from: result,
                    text: "The recommended step is grounded in a reviewed local source.",
                    lastReviewedAt: "2026-05-13T11:35:35Z"
                )
            ],
            fitState: AmbitionsOSStartHereRecommendation.fitState(for: result)
        )
    }

    func startHere(
        id: String = "start-here-golden",
        sourceClaims: [AmbitionsOSSourceTruthClaim],
        fitState: AmbitionsOSRecommendationFitState,
        proofTrustReceipts: [AmbitionsOSProofTrustReceipt]? = nil
    ) -> AmbitionsOSStartHereRecommendation {
        AmbitionsOSStartHereRecommendation(
            id: id,
            title: "Review the sourced step",
            kind: .startHere,
            surface: .today,
            recommendedObjectID: "step-current",
            sourceLabel: "Reviewed local source",
            sourceClaims: sourceClaims,
            proofTrustReceipts: proofTrustReceipts ?? [proofReceipt()],
            controlClassification: AmbitionsOSControlPlaneClassification(
                id: "classification-golden",
                requestID: "request-golden",
                workClass: .interactive,
                disposition: .allowLocalWork,
                requiredGates: [],
                allowedOutputs: [.recommendation, .reviewRequest],
                rationaleIDs: ["source_backed_start_here"]
            ),
            fitState: fitState,
            whyNow: ["A reviewed local source supports this step."],
            advances: ["Moves the goal forward."],
            protects: ["Keeps protected time intact."],
            assumptions: ["Duration still needs review if it feels off."],
            controlActions: [.adjust, .explainMore, .reject, .start],
            privacyClass: .privateLife,
            runtimeBoundary: .valueModelOnly,
            surfaceLanguageSamples: ["Start here", "Why this?", "Not this"]
        )
    }

    func explanation(for result: SourceAtlasQueryResult) -> RecommendationExplanation {
        RecommendationExplanation(
            id: "explanation-\(result.requirementID ?? result.id)",
            type: .whyThis,
            title: "Why this",
            summary: result.canSupportCurrentUse
                ? "A current source and local controls support this recommendation."
                : "Source review is needed before this recommendation can guide behavior.",
            recommendationTitle: "Review the sourced step",
            evidence: [
                RecommendationExplanationEvidence.fromSourceAtlasQueryResult(
                    result,
                    title: "Current source"
                )
            ],
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
            lastUpdatedAt: "2026-05-13T11:35:35Z",
            source: .recommendation
        )
    }

    func sourceClaim(
        state: AmbitionsOSSourceTruthClaimState = .officialSourceBacked,
        freshnessState: HumanProgressFreshnessState = .current,
        reviewState: HumanProgressReviewState = .ready
    ) -> AmbitionsOSSourceTruthClaim {
        AmbitionsOSSourceTruthClaim(
            id: "claim-golden",
            text: "The step is grounded in the user's reviewed local source.",
            scopeID: "goal-current",
            state: state,
            sourceQualityState: .official,
            freshnessState: freshnessState,
            riskClass: .careerContext,
            sourceIDs: ["source-current"],
            sourcePackIDs: ["source-pack-1"],
            reviewState: reviewState,
            lastReviewedAt: "2026-05-13T11:35:35Z"
        )
    }

    func proofReceipt() -> AmbitionsOSProofTrustReceipt {
        AmbitionsOSProofTrustReceipt(
            id: "proof-1",
            kind: .proof,
            surface: .today,
            occurredAt: "2026-05-13T11:35:35Z",
            affectedObjectIDs: ["step-current"],
            actionReceiptIDs: ["action-receipt-1"],
            proofReferenceIDs: ["proof-1"],
            sourceClaimIDs: ["claim-golden"],
            sourcePackIDs: ["source-pack-1"],
            closureOutcome: .needsReview,
            sourceState: .sourceBacked,
            freshnessState: .current,
            reviewState: .ready
        )
    }

    func learningInputCorrection(
        id: String,
        learningInputID: String,
        to corrected: CorrectionFoldLearningInputValue
    ) -> CorrectionFoldRecord {
        CorrectionFoldRecord.learningInput(
            id: id,
            learningInputID: learningInputID,
            from: .use,
            to: corrected,
            reason: "This learning input should not be used for future recommendations.",
            occurredAt: "2026-05-13T11:35:35Z"
        )
    }

    func makePrivateLifeExplanation(
        id: String,
        type: RecommendationExplanationType,
        title: String,
        summary: String,
        recommendationTitle: String,
        recommendationSummary: String? = nil,
        goalID: String,
        contextID: String,
        evidence: [RecommendationExplanationEvidence],
        uncertaintySummary: String,
        correctableFieldKeys: [String],
        correctionActions: [RecommendationExplanationCorrectionAction],
        lastUpdatedAt: String = "2026-05-17T05:12:17Z"
    ) -> RecommendationExplanation {
        RecommendationExplanation(
            id: id,
            type: type,
            title: title,
            summary: summary,
            recommendationTitle: recommendationTitle,
            recommendationSummary: recommendationSummary,
            evidence: evidence,
            assumptions: [
                RecommendationExplanationAssumption(
                    id: "\(id).assumption",
                    summary: "The same intent stays grounded in local context.",
                    fieldKey: "context"
                )
            ],
            uncertainty: [
                RecommendationExplanationUncertainty(
                    id: "\(id).uncertainty",
                    summary: uncertaintySummary
                )
            ],
            userCorrectableFields: correctableFieldKeys,
            correctionActions: correctionActions,
            lastUpdatedAt: lastUpdatedAt,
            source: .recommendation,
            relations: RecommendationExplanationRelations(goalIDs: [goalID]),
            privacy: .standard,
            localOnly: true,
            metadata: [
                "goalID": goalID,
                "contextID": contextID
            ]
        )
    }

    func makePrivateLifeTrace(
        explanation: RecommendationExplanation,
        receiptIDs: [String],
        actionReceiptIDs: [String],
        proofReferenceIDs: [String],
        rejectionLearningInfluences: [CorrectionFoldRecommendationLearningInfluence] = []
    ) -> RecommendationTrace {
        let evidenceModel = explanation.recommendationEvidenceModel
        return RecommendationTrace(
            id: "trace.\(explanation.id)",
            recommendationID: explanation.id,
            source: RecommendationTraceSource(
                citedSourceIDs: evidenceModel.citedSourceIDs,
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: evidenceModel.categories,
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: explanation.id,
                summary: explanation.summary,
                evidenceCategoryIDs: evidenceModel.categories.map(\.rawValue)
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: explanation.uncertainty.map(\.id).sorted(),
                summaries: explanation.uncertainty.map(\.summary).sorted()
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: explanation.correctionActions.map(\.id).sorted(),
                controlActionIDs: [],
                correctableFieldKeys: explanation.userCorrectableFields,
                hasRequiredControl: explanation.correctionActions.isEmpty == false || explanation.userCorrectableFields.isEmpty == false
            ),
            receiptBehavior: .available(
                receiptIDs: receiptIDs,
                actionReceiptIDs: actionReceiptIDs,
                proofReferenceIDs: proofReferenceIDs
            ),
            rejectionLearningInfluences: rejectionLearningInfluences
        )
    }

}

private extension InspectableIntelligenceGoldenScenarioTests {
    static func pack(
        sources: [SourceAtlasSourceRecord] = [
            SourceAtlasSourceRecord(
                id: "source-current",
                title: "Current source",
                kind: .official,
                locator: "https://example.test/current",
                retrievedAt: "2026-05-13T11:35:35Z",
                contentHash: "hash-current",
                approvedForOfficialClaims: true
            )
        ],
        claims: [SourceAtlasClaim],
        requirements: [SourceAtlasRequirement]
    ) -> SourceAtlasPack {
        SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: "source-pack-1",
                title: "Golden Source Pack",
                kind: .domainPack,
                version: "1.0.0",
                domainID: "career"
            ),
            sources: sources,
            claims: claims,
            requirements: requirements,
            starterItems: [
                SourceAtlasStarterItem(
                    id: "starter",
                    title: "Start",
                    stepCandidateSeed: "Review the sourced step.",
                    storesFinalSchedule: false
                )
            ],
            proofMap: requirements.map { requirement in
                SourceAtlasProofMapEntry(
                    id: "proof-\(requirement.id)",
                    requirementID: requirement.id,
                    proofDescription: "Requirement source proof.",
                    proofCandidate: .sourceEvidence,
                    proofStrength: .officialCertified,
                    sourceRecordIDs: sourceIDs(for: requirement.claimID, claims: claims),
                    sourceClaimIDs: [requirement.claimID]
                )
            },
            projections: [
                SourceAtlasGoalProjection(
                    id: "projection-golden",
                    goalIntent: "starter_goal",
                    requiredPackIDs: ["source-pack-1"],
                    projectionProfiles: []
                )
            ],
            freshnessPolicy: SourceAtlasFreshnessPolicy(
                reviewIntervalDays: 90,
                staleBlocksHighRiskUse: true
            ),
            riskPolicy: SourceAtlasRiskPolicy(
                strictReviewRiskClasses: SourceAtlasRiskClass.allCases.filter(\.requiresStrictReview)
            ),
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "Source needed.",
                reviewRequired: "Review required.",
                notProfessionalAdvice: "Planning support only."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: ["node-golden"],
                overlayDependencyIDs: [],
                projectionRecipeIDs: ["projection-golden"],
                ownsIndividualGoalPhrase: false
            )
        )
    }

    static func claim(
        id: String,
        state: SourceAtlasClaimState,
        freshness: SourceAtlasFreshnessState,
        riskClass: SourceAtlasRiskClass = .careerContext,
        sourceIDs: [String] = [],
        reviewRequired: Bool = true
    ) -> SourceAtlasClaim {
        SourceAtlasClaim(
            id: id,
            text: "\(id) source claim.",
            state: state,
            freshness: freshness,
            riskClass: riskClass,
            sourceIDs: sourceIDs,
            reviewRequired: reviewRequired
        )
    }

    static func requirement(
        id: String,
        claimID: String,
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState = .current,
        riskState: SourceAtlasRequirementRiskState = .low,
        reviewState: SourceAtlasRequirementReviewState = .approved
    ) -> SourceAtlasRequirement {
        SourceAtlasRequirement(
            id: id,
            claimID: claimID,
            title: "\(id) requirement",
            kind: .hard,
            required: true,
            sourceState: sourceState,
            freshnessState: freshnessState,
            riskState: riskState,
            reviewState: reviewState
        )
    }

    static func sourceAtlasResult(
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState = .current,
        riskState: SourceAtlasRequirementRiskState = .low,
        reviewState: SourceAtlasRequirementReviewState = .approved,
        provenanceSourceIDs: [String] = ["source-current"],
        fallbackReason: SourceAtlasQueryFallbackReason
    ) -> SourceAtlasQueryResult {
        SourceAtlasQueryResult(
            id: "result-\(fallbackReason.rawValue)-\(sourceState.rawValue)",
            packID: "source-pack-1",
            domainID: "career",
            goalIntent: "starter_goal",
            claimID: "claim-current",
            requirementID: "requirement-current",
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

    static func sourceIDs(for claimID: String, claims: [SourceAtlasClaim]) -> [String] {
        claims.first(where: { $0.id == claimID })?.sourceIDs ?? []
    }
}
