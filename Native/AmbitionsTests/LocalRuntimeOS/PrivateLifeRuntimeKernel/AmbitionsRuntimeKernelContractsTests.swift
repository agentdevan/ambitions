import XCTest
@testable import Ambitions

final class AmbitionsRuntimeKernelContractsTests: XCTestCase {
    func testKernelBoundaryIsLocalOnlyByConstruction() {
        let kernel = PrivateLifeRuntimeKernel()

        XCTAssertEqual(kernel.boundary, .localOnly)
        XCTAssertTrue(kernel.boundary.isLocalOnly)
    }

    func testKernelProducesStableDecisionRecordForDeterministicLocalTrace() throws {
        let kernel = PrivateLifeRuntimeKernel()
        let traceContext = makeTraceContext()
        let trace = makeRecommendationTrace(
            id: "trace.local.runtime",
            recommendationID: "decision.local.runtime"
        )
        let input = PrivateLifeRuntimeKernelDecisionInput(
            traceContext: traceContext,
            decisionKey: "today.start-here",
            recommendationTrace: trace
        )

        let firstRecord = try XCTUnwrap(kernel.makeDecisionRecord(input))
        let secondRecord = try XCTUnwrap(kernel.makeDecisionRecord(input))
        let output = kernel.evaluate(input)

        XCTAssertEqual(firstRecord.id, secondRecord.id)
        XCTAssertEqual(firstRecord.traceShape, secondRecord.traceShape)
        XCTAssertEqual(firstRecord.boundary, .localOnly)
        XCTAssertTrue(firstRecord.boundary.isLocalOnly)
        XCTAssertTrue(firstRecord.canDriveRecommendation)
        XCTAssertEqual(firstRecord.source, trace.source)
        XCTAssertEqual(firstRecord.reason, trace.reason)
        XCTAssertEqual(firstRecord.fit, trace.fit)
        XCTAssertEqual(firstRecord.uncertainty, trace.uncertainty)
        XCTAssertEqual(firstRecord.control, trace.control)
        XCTAssertEqual(firstRecord.receiptBehavior, trace.receiptBehavior)
        XCTAssertEqual(output.decisionID, firstRecord.id)
        XCTAssertEqual(output.recordID, firstRecord.id)
        XCTAssertEqual(output.traceShape, firstRecord.traceShape)
        XCTAssertTrue(output.isLocalOnly)
        XCTAssertTrue(output.canDriveRecommendation)
        XCTAssertTrue(output.hasRecommendationTrace)
    }

    func testMissingOrUnsafeTraceCannotDriveRecommendationBehavior() throws {
        let kernel = PrivateLifeRuntimeKernel()
        let traceContext = makeTraceContext()
        let missingInput = PrivateLifeRuntimeKernelDecisionInput(
            traceContext: traceContext,
            decisionKey: "today.missing-trace",
            recommendationTrace: nil
        )
        let unsafeTrace = makeRecommendationTrace(
            id: "trace.unsafe.runtime",
            recommendationID: "decision.unsafe.runtime",
            receiptBehavior: .missing()
        )
        let unsafeInput = PrivateLifeRuntimeKernelDecisionInput(
            traceContext: traceContext,
            decisionKey: "today.unsafe-trace",
            recommendationTrace: unsafeTrace
        )

        let missingOutput = kernel.evaluate(missingInput)
        let unsafeOutput = kernel.evaluate(unsafeInput)
        let unsafeRecord = try XCTUnwrap(kernel.makeDecisionRecord(unsafeInput))

        XCTAssertFalse(missingOutput.canDriveRecommendation)
        XCTAssertFalse(missingOutput.hasRecommendationTrace)
        XCTAssertNil(missingOutput.recordID)
        XCTAssertNil(missingOutput.traceShape)
        XCTAssertTrue(missingOutput.isLocalOnly)

        XCTAssertFalse(unsafeOutput.canDriveRecommendation)
        XCTAssertTrue(unsafeOutput.hasRecommendationTrace)
        XCTAssertEqual(unsafeOutput.recordID, unsafeRecord.id)
        XCTAssertEqual(unsafeRecord.receiptBehavior.state, .receiptMissing)
        XCTAssertFalse(unsafeRecord.canDriveRecommendation)
    }

    func testQuarantinedGoalIntelligenceContextCannotDriveRecommendationBehavior() throws {
        let kernel = PrivateLifeRuntimeKernel()
        let traceContext = PrivateLifeRuntimeKernelTraceContext(
            runtimeContext: makeRuntimeContext(),
            goalIntelligenceContext: try makeQuarantinedGoalIntelligenceContext()
        )
        let trace = makeRecommendationTrace(
            id: "trace.quarantined.runtime",
            recommendationID: "decision.quarantined.runtime"
        )
        let input = PrivateLifeRuntimeKernelDecisionInput(
            traceContext: traceContext,
            decisionKey: "today.quarantined-context",
            recommendationTrace: trace
        )

        let output = kernel.evaluate(input)
        let record = try XCTUnwrap(kernel.makeDecisionRecord(input))

        XCTAssertFalse(record.canDriveRecommendation)
        XCTAssertFalse(output.canDriveRecommendation)
        XCTAssertTrue(output.hasRecommendationTrace)
        XCTAssertTrue(output.isLocalOnly)
    }
}

private extension AmbitionsRuntimeKernelContractsTests {
    func makeTraceContext() -> PrivateLifeRuntimeKernelTraceContext {
        PrivateLifeRuntimeKernelTraceContext(
            runtimeContext: makeRuntimeContext(),
            goalIntelligenceContext: nil
        )
    }

    func makeRuntimeContext() -> RuntimeContextSnapshot {
        let memory = RuntimeMemorySnapshot(
            goals: [],
            drafts: [],
            evidence: [],
            feedback: [],
            captures: [],
            appState: AppStateSnapshot.default
        )
        let syncStatus = SyncCapabilityStatus(
            backendKind: .localOnly,
            trustPosture: .localOnly,
            availability: .unavailable,
            detail: "Ambitions is running in explicit local-only mode."
        )
        let knowledgeStatus = KnowledgeProviderStatus(
            provider: KnowledgeProviderDescriptor(
                id: "local-only",
                type: .systemFallback,
                displayName: "Local-only fallback"
            ),
            availability: .localOnlyMode,
            detail: "Knowledge retrieval is unavailable while Ambitions remains local-only.",
            runtimeTrustPosture: .localOnly
        )

        return RuntimeContextSnapshot(
            clientContext: .iphoneApp,
            capabilities: .currentLocalRuntime,
            syncStatus: syncStatus,
            knowledgeProviderStatuses: [knowledgeStatus],
            memorySummary: RuntimeMemorySummary(memory: memory),
            externalSurfaceSnapshot: nil
        )
    }

    func makeRecommendationTrace(
        id: String,
        recommendationID: String,
        receiptBehavior: RecommendationTraceReceiptBehavior = .available(receiptIDs: ["receipt.local"], proofReferenceIDs: ["proof.local"])
    ) -> RecommendationTrace {
        RecommendationTrace(
            id: id,
            recommendationID: recommendationID,
            source: RecommendationTraceSource(
                citedSourceIDs: ["source.local"],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.goalState],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "why-now.local",
                summary: "Local runtime data supports this decision.",
                evidenceCategoryIDs: [RecommendationExplanationEvidenceCategory.goalState.rawValue]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty.local"],
                summaries: ["The recommendation remains revisable if the context changes."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["control.local"],
                controlActionIDs: ["open_step"],
                correctableFieldKeys: ["goalID"],
                hasRequiredControl: true
            ),
            receiptBehavior: receiptBehavior
        )
    }

    func makeQuarantinedGoalIntelligenceContext() throws -> RuntimeGoalIntelligenceContext {
        let metadata = try makeGoalOrchestrationMetadata()
        let base = DefaultGoalExplainabilityProjector().makeState(
            metadata: metadata,
            applicableSignals: nil,
            primaryStepID: nil,
            whyNow: nil
        )
        let unsafe = GoalExplainabilityState(
            whisper: base.whisper,
            whyThis: base.whyThis,
            sourceAudit: GoalSourceAuditSectionState(rows: []),
            freshness: GoalFreshnessState(
                posture: .stale,
                postureLabel: "Needs review",
                severityLabel: "Stale",
                detailLabels: ["Source needs review"]
            ),
            confidence: GoalConfidenceState(
                understandingConfidence: .low,
                pathConfidence: .low,
                detailLabels: ["Unclear source support"]
            ),
            contradictions: [
                GoalContradictionSummaryState(
                    id: "contradiction-source",
                    code: .requiredKnowledgeClaimConflict,
                    title: "Source conflict",
                    summary: "Required knowledge is not settled.",
                    severityLabel: "Review",
                    state: .warning
                )
            ],
            correctionControls: [],
            appliedTeachingBadges: base.appliedTeachingBadges
        )
        let quarantine = RuntimeIntelligenceQuarantinePolicy().assess(explainability: unsafe)

        return RuntimeGoalIntelligenceContext(
            goalID: metadata.context.goalID,
            draftID: nil,
            primaryStepID: nil,
            metadata: metadata,
            applicableSignals: nil,
            explainability: unsafe,
            whyNow: nil,
            quarantine: quarantine
        )
    }

    func makeGoalOrchestrationMetadata() throws -> GoalOrchestrationMetadata {
        let result = GoalEngineOrchestrator().compileGoal(
            "Submit my conference talk proposal by 2026-05-15",
            context: GoalEngineOrchestrationContext(
                goalID: "goal-quarantined-runtime",
                referenceNow: GoalEngineFixtures.fixedNow
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
}
