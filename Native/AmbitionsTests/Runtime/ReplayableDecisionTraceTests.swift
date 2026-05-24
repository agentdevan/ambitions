import XCTest
@testable import Ambitions

final class ReplayableDecisionTraceTests: XCTestCase {
    func testReplayableDecisionTraceEncodesStablyAndNormalizesInputOrder() throws {
        let kernel = PrivateLifeRuntimeKernel()
        let traceContext = try makeTraceContext(
            knowledgeProviderStatuses: [
                makeKnowledgeProviderStatus(id: "provider.z", displayName: "Zeta"),
                makeKnowledgeProviderStatus(id: "provider.a", displayName: "Alpha")
            ]
        )
        let firstInput = PrivateLifeRuntimeKernelDecisionInput(
            traceContext: traceContext,
            decisionKey: "today.start-here",
            recommendationTrace: makeRecommendationTrace(
                id: "trace.local.runtime",
                recommendationID: "decision.local.runtime",
                citedSourceIDs: ["source.z", "source.a"],
                localEvidenceCategories: [.goalState, .captureState],
                uncertaintyIDs: ["uncertainty.z", "uncertainty.a", "uncertainty.z"],
                correctionActionIDs: ["correction.z", "correction.a", "correction.z"],
                controlActionIDs: ["control.z", "control.a", "control.z"],
                correctableFieldKeys: ["field.z", "field.a", "field.z"],
                receiptBehavior: .available(
                    receiptIDs: ["receipt.z", "receipt.a", "receipt.z"],
                    actionReceiptIDs: ["action.z", "action.a", "action.z"],
                    proofReferenceIDs: ["proof.z", "proof.a", "proof.z"]
                )
            )
        )
        let secondInput = PrivateLifeRuntimeKernelDecisionInput(
            traceContext: try makeTraceContext(
                knowledgeProviderStatuses: [
                    makeKnowledgeProviderStatus(id: "provider.a", displayName: "Alpha"),
                    makeKnowledgeProviderStatus(id: "provider.z", displayName: "Zeta")
                ]
            ),
            decisionKey: "today.start-here",
            recommendationTrace: makeRecommendationTrace(
                id: "trace.local.runtime",
                recommendationID: "decision.local.runtime",
                citedSourceIDs: ["source.a", "source.z"],
                localEvidenceCategories: [.captureState, .goalState],
                uncertaintyIDs: ["uncertainty.a", "uncertainty.z"],
                correctionActionIDs: ["correction.a", "correction.z"],
                controlActionIDs: ["control.a", "control.z"],
                correctableFieldKeys: ["field.a", "field.z"],
                receiptBehavior: .available(
                    receiptIDs: ["receipt.a", "receipt.z"],
                    actionReceiptIDs: ["action.a", "action.z"],
                    proofReferenceIDs: ["proof.a", "proof.z"]
                )
            )
        )

        let firstTrace = kernel.makeReplayableDecisionTrace(firstInput)
        let secondTrace = kernel.makeReplayableDecisionTrace(secondInput)

        XCTAssertEqual(firstTrace, secondTrace)
        XCTAssertEqual(firstTrace.state, .ready)
        XCTAssertTrue(firstTrace.isReplayable)
        XCTAssertTrue(firstTrace.isLocalOnly)
        XCTAssertEqual(firstTrace.runtime.knowledgeProviders.map(\.providerID), ["provider.a", "provider.z"])
        XCTAssertEqual(firstTrace.recommendation?.source.citedSourceIDs, ["source.a", "source.z"])
        XCTAssertEqual(firstTrace.recommendation?.source.sourceBlockReasons, [])
        XCTAssertEqual(firstTrace.recommendation?.fit.blockReasons, [])
        XCTAssertEqual(firstTrace.recommendation?.control.controlActionIDs, ["control.a", "control.z"])
        XCTAssertEqual(firstTrace.recommendation?.receipt.proofReferenceIDs, ["proof.a", "proof.z"])
        XCTAssertEqual(firstTrace.decisionReceipt?.state, "ready")
        XCTAssertEqual(firstTrace.decisionReceipt?.receiptBehaviorState, RecommendationTraceReceiptBehaviorState.receiptAvailable.rawValue)
        XCTAssertEqual(firstTrace.decisionReceipt?.sourceRecordIDs, ["receipt.a", "receipt.z"])
        XCTAssertTrue(firstTrace.decisionReceipt?.sourceRecordLabel.contains("Source record") ?? false)
        XCTAssertTrue(firstTrace.decisionReceipt?.replayTraceLabel.contains("Replay trace") ?? false)
        XCTAssertTrue(firstTrace.decisionReceipt?.hasProofBridge ?? false)
        XCTAssertTrue(firstTrace.decisionReceipt?.summary.contains("local receipt evidence") ?? false)

        let firstEncoded = try encodedJSON(firstTrace)
        let secondEncoded = try encodedJSON(secondTrace)

        XCTAssertEqual(firstEncoded, secondEncoded)
    }

    func testReplayableDecisionTraceCapturesLocalOnlyPrivacyBoundaryAndMemoryFacts() throws {
        let kernel = PrivateLifeRuntimeKernel()
        let traceContext = try makeTraceContext(
            memory: makeMemorySnapshot(
                goalCount: 2,
                draftCount: 1,
                evidenceCount: 3,
                feedbackCount: 4,
                captureCount: 5
            ),
            goalIntelligenceContext: try makeGoalIntelligenceContext()
        )
        let input = PrivateLifeRuntimeKernelDecisionInput(
            traceContext: traceContext,
            decisionKey: "today.start-here",
            recommendationTrace: makeRecommendationTrace(
                id: "trace.local.privacy",
                recommendationID: "decision.local.privacy"
            )
        )

        let trace = kernel.makeReplayableDecisionTrace(input)

        XCTAssertEqual(trace.runtime.boundary.isLocalOnly, true)
        XCTAssertEqual(trace.runtime.boundary.hasRemoteIntelligenceBackend, false)
        XCTAssertEqual(trace.runtime.memory.goalCount, 2)
        XCTAssertEqual(trace.runtime.memory.draftCount, 1)
        XCTAssertEqual(trace.runtime.memory.evidenceCount, 3)
        XCTAssertEqual(trace.runtime.memory.feedbackCount, 4)
        XCTAssertEqual(trace.runtime.memory.captureCount, 5)
        XCTAssertEqual(trace.goalIntelligence?.privacy.isQuarantined, false)
        XCTAssertEqual(trace.goalIntelligence?.privacy.hasSourceAudit, true)
        XCTAssertEqual(trace.goalIntelligence?.privacy.hasApplicableSignals, false)
        XCTAssertEqual(trace.goalIntelligence?.freshnessPosture, GoalFreshnessPosture.currentEnough.rawValue)
    }

    func testReplayableDecisionTraceBlocksMissingAndUnsafeTraces() throws {
        let kernel = PrivateLifeRuntimeKernel()
        let traceContext = try makeTraceContext()
        let missingInput = PrivateLifeRuntimeKernelDecisionInput(
            traceContext: traceContext,
            decisionKey: "today.missing-trace",
            recommendationTrace: nil
        )
        let unsafeInput = PrivateLifeRuntimeKernelDecisionInput(
            traceContext: traceContext,
            decisionKey: "today.unsafe-trace",
            recommendationTrace: makeRecommendationTrace(
                id: "trace.unsafe.runtime",
                recommendationID: "decision.unsafe.runtime",
                receiptBehavior: .missing()
            )
        )

        let missingTrace = kernel.makeReplayableDecisionTrace(missingInput)
        let unsafeTrace = kernel.makeReplayableDecisionTrace(unsafeInput)

        XCTAssertEqual(missingTrace.state, .missing)
        XCTAssertEqual(missingTrace.blockingReasons, [.missingRecommendationTrace])
        XCTAssertNil(missingTrace.recommendation)

        XCTAssertEqual(unsafeTrace.state, .blocked)
        XCTAssertTrue(unsafeTrace.blockingReasons.contains(.unsafeRecommendationTrace))
        XCTAssertTrue(unsafeTrace.blockingReasons.contains(.receiptMissing))
        XCTAssertEqual(unsafeTrace.recommendation?.receipt.state, RecommendationTraceReceiptBehaviorState.receiptMissing.rawValue)
        XCTAssertFalse(unsafeTrace.isReplayable)
    }

    func testReplayableDecisionTraceDoesNotLeakPrivateRawText() throws {
        let secret = "PRIVATE-RAW-TEXT-LEAK-MARKER"
        let kernel = PrivateLifeRuntimeKernel()
        let traceContext = try makeTraceContext(
            goalIntelligenceContext: try makeGoalIntelligenceContext(secretMarker: secret)
        )
        let input = PrivateLifeRuntimeKernelDecisionInput(
            traceContext: traceContext,
            decisionKey: "today.secret-trace",
            recommendationTrace: makeRecommendationTrace(
                id: "trace.secret.runtime",
                recommendationID: "decision.secret.runtime",
                uncertaintySummaries: [secret],
                reasonSummary: secret
            )
        )

        let trace = kernel.makeReplayableDecisionTrace(input)
        let encoded = try encodedJSONString(trace)

        XCTAssertFalse(encoded.contains(secret))
        XCTAssertFalse(encoded.contains("Why this matters"))
        XCTAssertFalse(encoded.contains("Source subtitle"))
        XCTAssertFalse(encoded.contains("Control subtitle"))
        XCTAssertFalse(encoded.contains("Contradiction summary"))
    }

    func testReplayableDecisionTraceProjectsPersonalRuntimeLearningSignalsFromRejectionLearningInfluence() throws {
        let kernel = PrivateLifeRuntimeKernel()
        let correction = CorrectionFoldRecord.recommendation(
            id: "correction.runtime.rejection",
            recommendationID: "recommendation.runtime.rejection",
            from: .stillUseful,
            to: .rejectedWrongTime,
            reason: "This recommendation is still too early.",
            occurredAt: "2026-05-22T18:13:20Z",
            allowsFutureLearning: true
        )
        let influence = try XCTUnwrap(
            CorrectionFoldRecommendationLearningInfluence(
                correction: correction,
                similarRecommendationSignalKeys: ["goal_state", "time_fit"]
            )
        )
        let input = PrivateLifeRuntimeKernelDecisionInput(
            traceContext: try makeTraceContext(),
            decisionKey: "today.rejection-learning",
            recommendationTrace: makeRecommendationTrace(
                id: "trace.rejection-learning",
                recommendationID: "recommendation.runtime.rejection",
                rejectionLearningInfluences: [influence]
            )
        )

        let trace = kernel.makeReplayableDecisionTrace(input)

        XCTAssertEqual(trace.personalRuntimeLearningSignals.count, 1)
        XCTAssertEqual(trace.personalRuntimeLearningSignals.first?.id, "learning.correction.runtime.rejection")
        XCTAssertEqual(trace.personalRuntimeLearningSignals.first?.correctionRecordID, "correction.runtime.rejection")
        XCTAssertEqual(trace.personalRuntimeLearningSignals.first?.recommendationID, "recommendation.runtime.rejection")
        XCTAssertEqual(trace.personalRuntimeLearningSignals.first?.rejectionReason, .rejectedWrongTime)
        XCTAssertEqual(trace.personalRuntimeLearningSignals.first?.adjustment, .downrankWrongTime)
        XCTAssertEqual(trace.personalRuntimeLearningSignals.first?.personalRuntimeInspectableSummary.contains("Reset or delete") ?? false, true)
        XCTAssertEqual(trace.personalRuntimeLearningSignals.first?.personalRuntimeResetRoute, "you://personal-runtime/recommendation.runtime.rejection/reset")
        XCTAssertEqual(trace.personalRuntimeLearningSignals.first?.personalRuntimeDeleteRoute, "you://personal-runtime/recommendation.runtime.rejection/delete")
        XCTAssertEqual(trace.personalRuntimeLearningSignals.first?.personalRuntimeInspectionLabel, "Local and source-tied")
        XCTAssertTrue(trace.personalRuntimeLearningSignals.first?.isInspectableAndControllable ?? false)
        XCTAssertFalse(trace.personalRuntimeLearningSignals.first?.permitsSilentMutation ?? true)
    }
}

private extension ReplayableDecisionTraceTests {
    func makeTraceContext(
        memory: RuntimeMemorySnapshot? = nil,
        knowledgeProviderStatuses: [KnowledgeProviderStatus]? = nil,
        goalIntelligenceContext: RuntimeGoalIntelligenceContext? = nil
    ) throws -> PrivateLifeRuntimeKernelTraceContext {
        let resolvedMemory = memory ?? makeMemorySnapshot()
        let resolvedKnowledgeProviderStatuses = knowledgeProviderStatuses ?? [
            makeKnowledgeProviderStatus(id: "provider.local", displayName: "Local knowledge")
        ]
        return PrivateLifeRuntimeKernelTraceContext(
            runtimeContext: RuntimeContextSnapshot(
                clientContext: .iphoneApp,
                capabilities: .currentLocalRuntime,
                syncStatus: SyncCapabilityStatus(
                    backendKind: .localOnly,
                    trustPosture: .localOnly,
                    availability: .unavailable,
                    detail: "Ambitions is running in explicit local-only mode."
                ),
                knowledgeProviderStatuses: resolvedKnowledgeProviderStatuses,
                memorySummary: RuntimeMemorySummary(memory: resolvedMemory),
                externalSurfaceSnapshot: nil
            ),
            goalIntelligenceContext: goalIntelligenceContext
        )
    }

    func makeMemorySnapshot(
        goalCount: Int = 0,
        draftCount: Int = 0,
        evidenceCount: Int = 0,
        feedbackCount: Int = 0,
        captureCount: Int = 0
    ) -> RuntimeMemorySnapshot {
        RuntimeMemorySnapshot(
            goals: Array(repeating: makeGoal(id: "goal.memory"), count: goalCount),
            drafts: Array(repeating: makeDraft(id: "draft.memory"), count: draftCount),
            evidence: Array(repeating: makeEvidence(id: "evidence.memory"), count: evidenceCount),
            feedback: Array(repeating: makeFeedback(id: "feedback.memory"), count: feedbackCount),
            captures: Array(repeating: makeCapture(id: "capture.memory"), count: captureCount),
            appState: .default
        )
    }

    func makeGoal(id: String) -> Goal {
        Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: id,
            revision: 1,
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z",
            state: .active,
            title: "Goal \(id)",
            summary: nil,
            mode: .project,
            relationshipKind: .independent,
            actor: GoalActor(
                actorID: "actor.local",
                displayName: "Devan",
                ownership: .self,
                roleLabel: nil,
                isPrimary: true
            ),
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: [],
            timing: GoalTiming(
                tempo: .untimed,
                timingType: .suggestedNext,
                startsOn: nil,
                dueAt: nil,
                targetBy: nil,
                windowStart: nil,
                windowEnd: nil,
                suggestedNextAt: nil,
                repeatEveryDays: nil,
                progressReviewCadenceDays: nil
            ),
            planningStrategy: PlanningStrategy(
                strategyKind: .adaptive,
                allowParallelSteps: true,
                maxActiveSteps: 1,
                preferredSectionOrder: [.activeSteps],
                defaultStepType: .actionUnit,
                autoGenerateReviewSection: false,
                preferShortSteps: true,
                revisitCadenceDays: nil
            ),
            progressStrategy: ProgressStrategy(
                metricKind: .stepCompletion,
                rollupMethod: .sum,
                targetStepCount: nil,
                targetEvidenceCount: nil,
                targetMinutes: nil,
                supportsUntimedProgress: true,
                countsChildGoals: false,
                countsSupportGoals: false
            ),
            plan: nil
        )
    }

    func makeDraft(id: String) -> PersistedGoalDraft {
        PersistedGoalDraft(
            id: id,
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z",
            draft: GoalDraft(
                schemaVersion: goalEngineSchemaVersion,
                source: .manual,
                title: "Draft \(id)",
                summary: nil,
                mode: .project,
                relationshipKind: .independent,
                actor: GoalActor(
                    actorID: "actor.local",
                    displayName: "Devan",
                    ownership: .self,
                    roleLabel: nil,
                    isPrimary: true
                ),
                parentGoalID: nil,
                tags: [],
                timing: GoalTiming(
                    tempo: .untimed,
                    timingType: .suggestedNext,
                    startsOn: nil,
                    dueAt: nil,
                    targetBy: nil,
                    windowStart: nil,
                    windowEnd: nil,
                    suggestedNextAt: nil,
                    repeatEveryDays: nil,
                    progressReviewCadenceDays: nil
                ),
                planningStrategy: PlanningStrategy(
                    strategyKind: .adaptive,
                    allowParallelSteps: true,
                    maxActiveSteps: 1,
                    preferredSectionOrder: [.activeSteps],
                    defaultStepType: .actionUnit,
                    autoGenerateReviewSection: false,
                    preferShortSteps: true,
                    revisitCadenceDays: nil
                ),
                progressStrategy: ProgressStrategy(
                    metricKind: .stepCompletion,
                    rollupMethod: .sum,
                    targetStepCount: nil,
                    targetEvidenceCount: nil,
                    targetMinutes: nil,
                    supportsUntimedProgress: true,
                    countsChildGoals: false,
                    countsSupportGoals: false
                )
            ),
            classification: nil,
            clarification: nil,
            stagedPlan: nil,
            assumptions: [],
            blockers: [],
            metadata: nil,
            plannedGoalID: nil,
            latestResultKind: nil
        )
    }

    func makeEvidence(id: String) -> ProgressEvidence {
        ProgressEvidence(
            id: id,
            goalID: "goal.memory",
            stepID: nil,
            evidenceKind: .stepCompleted,
            source: .manual,
            capturedAt: "2026-05-22T00:00:00Z",
            progressDelta: nil,
            confidenceDelta: nil,
            minutesInvested: nil,
            note: "Evidence \(id)"
        )
    }

    func makeFeedback(id: String) -> GoalFeedbackEvent {
        GoalFeedbackEvent.completed(
            base: GoalFeedbackEventBase(
                id: id,
                stepID: "step.memory",
                occurredAt: "2026-05-22T00:00:00Z",
                note: "Feedback \(id)"
            ),
            actualDuration: 10,
            effortLevel: .medium,
            confidenceDelta: 0.1
        )
    }

    func makeCapture(id: String) -> Capture {
        Capture(
            id: id,
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z",
            rawText: "Capture \(id)",
            sourceType: nil,
            status: .needsTriage,
            linkedGoalID: nil,
            kind: .raw,
            route: .captureInbox,
            triageStatus: .needsTriage,
            deadlineKind: .none
        )
    }

    func makeKnowledgeProviderStatus(id: String, displayName: String) -> KnowledgeProviderStatus {
        KnowledgeProviderStatus(
            provider: KnowledgeProviderDescriptor(
                id: id,
                type: .systemFallback,
                displayName: displayName
            ),
            availability: .localOnlyMode,
            detail: "Knowledge retrieval is unavailable while Ambitions remains local-only.",
            runtimeTrustPosture: .localOnly
        )
    }

    func makeGoalIntelligenceContext(
        secretMarker: String? = nil,
        quarantineIssues: [RuntimeIntelligenceQuarantineIssue] = [],
        canDriveRecommendation: Bool = true
    ) throws -> RuntimeGoalIntelligenceContext {
        let metadata = try makeGoalOrchestrationMetadata()
        let secret = secretMarker ?? "Goal intelligence"
        let explainability = GoalExplainabilityState(
            whisper: GoalTrustWhisperState(
                title: secret,
                subtitle: "\(secret) subtitle",
                pillLine: "\(secret) pill line",
                pills: [
                    GoalTrustWhisperPillState(
                        id: "trust-confidence",
                        title: "\(secret) confidence",
                        icon: "sparkles",
                        state: .selected
                    ),
                    GoalTrustWhisperPillState(
                        id: "trust-freshness",
                        title: "\(secret) freshness",
                        icon: "clock",
                        state: .selected
                    )
                ]
            ),
            whyThis: GoalWhyThisState(
                compactSummary: "\(secret) why-this",
                lines: ["\(secret) line one", "\(secret) line two"]
            ),
            sourceAudit: GoalSourceAuditSectionState(rows: [
                GoalSourceAuditRowState(
                    id: "source-audit-1",
                    resourceID: "source-resource-1",
                    title: "\(secret) source title",
                    subtitle: "\(secret) source subtitle",
                    detailLabels: ["\(secret) source detail"],
                    state: .selected
                )
            ]),
            freshness: GoalFreshnessState(
                posture: .currentEnough,
                postureLabel: "\(secret) fresh",
                severityLabel: "\(secret) severity",
                detailLabels: ["\(secret) freshness detail"]
            ),
            confidence: GoalConfidenceState(
                understandingConfidence: .high,
                pathConfidence: .medium,
                detailLabels: ["\(secret) confidence detail"]
            ),
            contradictions: [
                GoalContradictionSummaryState(
                    id: "contradiction-1",
                    code: .inputTimingConflict,
                    title: "\(secret) contradiction",
                    summary: "\(secret) contradiction summary",
                    severityLabel: "\(secret) severity label",
                    state: .warning
                )
            ],
            correctionControls: [],
            appliedTeachingBadges: [
                GoalAppliedTeachingBadgeState(
                    id: "badge-1",
                    signalID: "signal-1",
                    title: "\(secret) badge",
                    subtitle: "\(secret) badge subtitle",
                    state: .selected
                )
            ]
        )
        let quarantine = RuntimeIntelligenceQuarantineAssessment(
            issues: quarantineIssues,
            canDriveRecommendation: canDriveRecommendation,
            disclosureSummary: "\(secret) disclosure"
        )

        return RuntimeGoalIntelligenceContext(
            goalID: metadata.context.goalID,
            draftID: nil,
            primaryStepID: "step.primary",
            metadata: metadata,
            applicableSignals: nil,
            explainability: explainability,
            whyNow: nil,
            quarantine: quarantine
        )
    }

    func makeGoalOrchestrationMetadata() throws -> GoalOrchestrationMetadata {
        let result = GoalEngineOrchestrator().compileGoal(
            "Submit my conference talk proposal by 2026-05-15",
            context: GoalEngineOrchestrationContext(
                goalID: "goal-replayable-trace",
                referenceNow: "2026-05-22T00:00:00Z"
            )
        )

        switch result {
        case let .planned(planned):
            return planned.metadata
        case let .starterPlanned(starter):
            return starter.metadata
        case let .clarificationRequired(required):
            return required.metadata
        case let .blocked(blocked):
            return blocked.metadata
        }
    }

    func makeRecommendationTrace(
        id: String,
        recommendationID: String,
        citedSourceIDs: [String] = ["source.a", "source.b"],
        sourceBlockReasons: [String] = [],
        localEvidenceCategories: [RecommendationExplanationEvidenceCategory] = [.goalState],
        fitState: RecommendationTraceFitState = .fits,
        fitBlockReasons: [String] = [],
        uncertaintyIDs: [String] = ["uncertainty.a"],
        uncertaintySummaries: [String] = ["The recommendation can be revised if context changes."],
        correctionActionIDs: [String] = ["correction.a"],
        controlActionIDs: [String] = ["open_step"],
        correctableFieldKeys: [String] = ["goalID"],
        receiptBehavior: RecommendationTraceReceiptBehavior = .available(receiptIDs: ["receipt.a"], proofReferenceIDs: ["proof.a"]),
        reasonSummary: String = "Local runtime data supports this decision.",
        rejectionLearningInfluences: [CorrectionFoldRecommendationLearningInfluence] = []
    ) -> RecommendationTrace {
        RecommendationTrace(
            id: id,
            recommendationID: recommendationID,
            source: RecommendationTraceSource(
                citedSourceIDs: citedSourceIDs,
                sourceAtlasBlockReasons: sourceBlockReasons,
                localEvidenceCategories: localEvidenceCategories,
                canSupportRecommendation: sourceBlockReasons.isEmpty
            ),
            reason: RecommendationTraceReason(
                explanationID: "why-now.local",
                summary: reasonSummary,
                evidenceCategoryIDs: localEvidenceCategories.map(\.rawValue)
            ),
            fit: RecommendationTraceFit(
                state: fitState,
                blockReasons: fitBlockReasons,
                canDriveRecommendation: fitState == .fits
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: uncertaintyIDs,
                summaries: uncertaintySummaries
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: correctionActionIDs,
                controlActionIDs: controlActionIDs,
                correctableFieldKeys: correctableFieldKeys,
                hasRequiredControl: true
            ),
            receiptBehavior: receiptBehavior,
            rejectionLearningInfluences: rejectionLearningInfluences
        )
    }

    func encodedJSON(_ trace: ReplayableDecisionTrace) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(trace)
        return String(decoding: data, as: UTF8.self)
    }

    func encodedJSONData(_ trace: ReplayableDecisionTrace) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(trace)
    }

    func encodedJSONString(_ trace: ReplayableDecisionTrace) throws -> String {
        String(decoding: try encodedJSONData(trace), as: UTF8.self)
    }
}
