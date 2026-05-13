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
