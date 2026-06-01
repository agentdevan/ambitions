import XCTest
@testable import Ambitions

final class RecommendationMutationLabModelsTests: XCTestCase {
    func testMutationLabComparisonStaysStableWhenOutputAndInspectionSeamsAreBounded() throws {
        let baseline = try makeVariant(
            id: "variant.baseline.stable",
            mutationID: "mutation.capacity-open",
            contextSummary: "Capacity stays open for the same local step.",
            contextDeltaSummary: "Open capacity keeps the local recommendation stable.",
            recommendationID: "recommendation.start-here",
            traceID: "trace.start-here.baseline",
            reasonGraphID: "trace.start-here.baseline.reason-graph",
            selectedLabel: "Selected step stays local",
            alternativeLabel: "Alternative step stays local",
            deltaLabel: "Local delta stays bounded",
            planningSummary: "Selected step stays ahead by a local, inspectable margin.",
            replayDecisionKey: "today.start-here.baseline",
            sourceRecordID: "SourceRecord.start-here.baseline",
            receiptID: "Receipt.start-here.baseline",
            replayTraceID: "ReplayTrace.start-here.baseline",
            contextBoundaryIDs: ["source_record", "receipt", "replay_trace", "you_inspection"],
            sourceRecordIDs: ["source-a", "source-b"],
            receiptIDs: ["receipt-a", "receipt-b"],
            replayTraceIDs: ["replay-a"],
            runtimeSnapshotReferenceIDs: ["runtime-snapshot-a"],
            localFitLabels: ["fit-a", "fit-b"]
        )
        let mutated = try makeVariant(
            id: "variant.mutated.stable",
            mutationID: "mutation.capacity-open",
            contextSummary: "Capacity stays open after a deterministic recheck.",
            contextDeltaSummary: "The same local step remains the best inspectable fit.",
            recommendationID: "recommendation.start-here",
            traceID: "trace.start-here.baseline",
            reasonGraphID: "trace.start-here.baseline.reason-graph",
            selectedLabel: "Selected step stays local",
            alternativeLabel: "Alternative step stays local",
            deltaLabel: "Local delta stays bounded",
            planningSummary: "Selected step stays ahead by a local, inspectable margin.",
            replayDecisionKey: "today.start-here.baseline",
            sourceRecordID: "SourceRecord.start-here.baseline",
            receiptID: "Receipt.start-here.baseline",
            replayTraceID: "ReplayTrace.start-here.baseline",
            contextBoundaryIDs: ["source_record", "receipt", "replay_trace", "you_inspection"],
            sourceRecordIDs: ["source-a", "source-b"],
            receiptIDs: ["receipt-a", "receipt-b"],
            replayTraceIDs: ["replay-a"],
            runtimeSnapshotReferenceIDs: ["runtime-snapshot-a"],
            localFitLabels: ["fit-a", "fit-b"]
        )

        let comparison = RecommendationMutationLabComparison(baseline: baseline, mutated: mutated)
        let report = RecommendationMutationLabReport(
            id: "report.mutation-lab",
            batchID: "AFEP-006",
            comparisons: [comparison]
        )
        let decoded = try PersistenceCoding.decode(
            RecommendationMutationLabReport.self,
            from: PersistenceCoding.encode(report)
        )

        XCTAssertEqual(decoded, report)
        XCTAssertEqual(comparison.stabilityState, .stable)
        XCTAssertTrue(comparison.isStable)
        XCTAssertTrue(comparison.instabilityReasonIDs.isEmpty)
        XCTAssertTrue(comparison.hasRequiredInspectionSeams)
        XCTAssertFalse(comparison.hasVisibleCopyGuardrailViolation)
        XCTAssertEqual(report.stableComparisonCount, 1)
        XCTAssertEqual(report.needsReviewComparisonCount, 0)
        XCTAssertEqual(report.unstableComparisonCount, 0)
        XCTAssertTrue(report.summary.contains("1 stable"))
        XCTAssertTrue(report.summary.contains("0 unstable"))
        XCTAssertFalse(report.hasVisibleCopyGuardrailViolation)
    }

    func testMutationLabComparisonFlagsMissingDeltaNonDeterminismAndUnboundedContext() throws {
        let baseline = try makeVariant(
            id: "variant.baseline.unstable",
            mutationID: "mutation.same-input",
            contextSummary: "Baseline local context stays inspectable.",
            contextDeltaSummary: "This baseline run is a local comparison point.",
            recommendationID: "recommendation.first-choice",
            traceID: "trace.first-choice",
            reasonGraphID: "trace.first-choice.reason-graph",
            selectedLabel: "Selected step stays local",
            alternativeLabel: "Alternative step stays local",
            deltaLabel: "Local delta stays bounded",
            planningSummary: "Selected step stays ahead by a local, inspectable margin.",
            replayDecisionKey: "today.same-input",
            sourceRecordID: "SourceRecord.same-input.baseline",
            receiptID: "Receipt.same-input.baseline",
            replayTraceID: "ReplayTrace.same-input.baseline",
            contextBoundaryIDs: ["source_record", "receipt", "replay_trace"],
            sourceRecordIDs: ["source-a"],
            receiptIDs: ["receipt-a"],
            replayTraceIDs: ["replay-a"],
            runtimeSnapshotReferenceIDs: ["runtime-snapshot-a"],
            localFitLabels: ["fit-a"]
        )
        let mutated = try makeVariant(
            id: "variant.mutated.unstable",
            mutationID: "mutation.same-input",
            contextSummary: "The local context changed, but the output claim lacks a delta.",
            contextDeltaSummary: nil,
            recommendationID: "recommendation.second-choice",
            traceID: "trace.second-choice",
            reasonGraphID: nil,
            selectedLabel: "Selected step changed",
            alternativeLabel: "Alternative step changed",
            deltaLabel: "Local shift is unbounded",
            planningSummary: "Selected step no longer holds the same local rank.",
            replayDecisionKey: "today.same-input",
            sourceRecordID: "SourceRecord.same-input.mutated",
            receiptID: "Receipt.same-input.mutated",
            replayTraceID: "ReplayTrace.same-input.mutated",
            contextBoundaryIDs: [],
            sourceRecordIDs: ["source-b"],
            receiptIDs: ["receipt-b"],
            replayTraceIDs: ["replay-b"],
            runtimeSnapshotReferenceIDs: [],
            localFitLabels: ["fit-b"],
            includeCounterfactualEvidence: false
        )

        let comparison = RecommendationMutationLabComparison(baseline: baseline, mutated: mutated)
        let report = RecommendationMutationLabReport(
            id: "report.mutation-lab.unstable",
            batchID: "AFEP-006",
            comparisons: [comparison]
        )

        XCTAssertEqual(comparison.stabilityState, .unstable)
        XCTAssertTrue(comparison.isUnstable)
        XCTAssertTrue(comparison.instabilityReasonIDs.contains(.missingExplanationDelta))
        XCTAssertFalse(comparison.instabilityReasonIDs.contains(.nonDeterministicOutput))
        XCTAssertTrue(comparison.instabilityReasonIDs.contains(.notBoundedByMutationContext))
        XCTAssertTrue(comparison.instabilityReasonIDs.contains(.missingReasonGraph))
        XCTAssertTrue(comparison.instabilityReasonIDs.contains(.missingCounterfactualDiff))
        XCTAssertFalse(comparison.hasVisibleCopyGuardrailViolation)
        XCTAssertEqual(report.unstableComparisonCount, 1)
        XCTAssertTrue(report.summary.contains("1 unstable"))
    }

    func testMutationLabComparisonAllowsBoundedRecommendationShiftWithExplanationDelta() throws {
        let baseline = try makeVariant(
            id: "variant.baseline.bounded-shift",
            mutationID: "mutation.capacity-tightened",
            contextSummary: "Baseline local context has a larger capacity window.",
            contextDeltaSummary: "Capacity is open enough for the longer local step.",
            recommendationID: "recommendation.longer-step",
            traceID: "trace.longer-step",
            reasonGraphID: "trace.longer-step.reason-graph",
            selectedLabel: "Longer step fits",
            alternativeLabel: "Shorter step waits",
            deltaLabel: "Open capacity explains the longer step",
            planningSummary: "Longer step ranks first while capacity is open.",
            replayDecisionKey: "today.capacity-tightened",
            sourceRecordID: "SourceRecord.capacity.baseline",
            receiptID: "Receipt.capacity.baseline",
            replayTraceID: "ReplayTrace.capacity.baseline",
            contextBoundaryIDs: ["capacity", "source_record", "receipt", "replay_trace", "you_inspection"],
            sourceRecordIDs: ["source-capacity-open"],
            receiptIDs: ["receipt-capacity-open"],
            replayTraceIDs: ["replay-capacity-open"],
            runtimeSnapshotReferenceIDs: ["runtime-snapshot-open"],
            localFitLabels: ["capacity-open"]
        )
        let mutated = try makeVariant(
            id: "variant.mutated.bounded-shift",
            mutationID: "mutation.capacity-tightened",
            contextSummary: "Mutated local context has a tighter capacity window.",
            contextDeltaSummary: "Capacity tightened, so the shorter local step is the bounded fit.",
            recommendationID: "recommendation.shorter-step",
            traceID: "trace.shorter-step",
            reasonGraphID: "trace.shorter-step.reason-graph",
            selectedLabel: "Shorter step fits",
            alternativeLabel: "Longer step waits",
            deltaLabel: "Tighter capacity explains the shorter step",
            planningSummary: "Shorter step ranks first after the capacity mutation.",
            replayDecisionKey: "today.capacity-tightened",
            sourceRecordID: "SourceRecord.capacity.mutated",
            receiptID: "Receipt.capacity.mutated",
            replayTraceID: "ReplayTrace.capacity.mutated",
            contextBoundaryIDs: ["capacity", "source_record", "receipt", "replay_trace", "you_inspection"],
            sourceRecordIDs: ["source-capacity-tight"],
            receiptIDs: ["receipt-capacity-tight"],
            replayTraceIDs: ["replay-capacity-tight"],
            runtimeSnapshotReferenceIDs: ["runtime-snapshot-tight"],
            localFitLabels: ["capacity-tight"]
        )

        let comparison = RecommendationMutationLabComparison(baseline: baseline, mutated: mutated)

        XCTAssertEqual(comparison.stabilityState, .stable)
        XCTAssertTrue(comparison.instabilityReasonIDs.isEmpty)
        XCTAssertFalse(comparison.instabilityReasonIDs.contains(.nonDeterministicOutput))
        XCTAssertFalse(comparison.instabilityReasonIDs.contains(.notBoundedByMutationContext))
        XCTAssertFalse(comparison.instabilityReasonIDs.contains(.missingExplanationDelta))
        XCTAssertTrue(comparison.summary.contains("changes"))
    }

    func testMutationLabComparisonFlagsNonDeterministicOutputForSameMutationInput() throws {
        let baseline = try makeVariant(
            id: "variant.baseline.same-input",
            mutationID: "mutation.same-input-repeat",
            contextSummary: "The same local context is replayed.",
            contextDeltaSummary: "No local input changed between runs.",
            recommendationID: "recommendation.first-output",
            traceID: "trace.first-output",
            reasonGraphID: "trace.first-output.reason-graph",
            selectedLabel: "First output selected",
            alternativeLabel: "Second output waits",
            deltaLabel: "No input delta explains a shift",
            planningSummary: "First output ranks first.",
            replayDecisionKey: "today.same-input-repeat",
            sourceRecordID: "SourceRecord.same-repeat",
            receiptID: "Receipt.same-repeat",
            replayTraceID: "ReplayTrace.same-repeat",
            contextBoundaryIDs: ["source_record", "receipt", "replay_trace", "you_inspection"],
            sourceRecordIDs: ["source-repeat"],
            receiptIDs: ["receipt-repeat"],
            replayTraceIDs: ["replay-repeat"],
            runtimeSnapshotReferenceIDs: ["runtime-repeat"],
            localFitLabels: ["fit-repeat"]
        )
        let mutated = try makeVariant(
            id: "variant.mutated.same-input",
            mutationID: "mutation.same-input-repeat",
            contextSummary: "The same local context is replayed.",
            contextDeltaSummary: "No local input changed between runs.",
            recommendationID: "recommendation.second-output",
            traceID: "trace.second-output",
            reasonGraphID: "trace.second-output.reason-graph",
            selectedLabel: "Second output selected",
            alternativeLabel: "First output waits",
            deltaLabel: "No input delta explains a shift",
            planningSummary: "Second output ranks first without an input delta.",
            replayDecisionKey: "today.same-input-repeat",
            sourceRecordID: "SourceRecord.same-repeat",
            receiptID: "Receipt.same-repeat",
            replayTraceID: "ReplayTrace.same-repeat",
            contextBoundaryIDs: ["source_record", "receipt", "replay_trace", "you_inspection"],
            sourceRecordIDs: ["source-repeat"],
            receiptIDs: ["receipt-repeat"],
            replayTraceIDs: ["replay-repeat"],
            runtimeSnapshotReferenceIDs: ["runtime-repeat"],
            localFitLabels: ["fit-repeat"]
        )

        let comparison = RecommendationMutationLabComparison(baseline: baseline, mutated: mutated)

        XCTAssertEqual(comparison.stabilityState, .unstable)
        XCTAssertTrue(comparison.instabilityReasonIDs.contains(.nonDeterministicOutput))
        XCTAssertFalse(comparison.instabilityReasonIDs.contains(.notBoundedByMutationContext))
    }

    func testMutationVariantPreservesExplicitSourceReceiptReplayAndInspectionSeams() throws {
        let variant = try makeVariant(
            id: "variant.seam-check",
            mutationID: "mutation.seam-check",
            contextSummary: "A seam-check variant keeps the provenance labels explicit.",
            contextDeltaSummary: "Local provenance remains inspectable.",
            recommendationID: "recommendation.seam-check",
            traceID: "trace.seam-check",
            reasonGraphID: "trace.seam-check.reason-graph",
            selectedLabel: "Selected step stays local",
            alternativeLabel: "Alternative step stays local",
            deltaLabel: "Local delta stays bounded",
            planningSummary: "Selected step stays ahead by a local, inspectable margin.",
            replayDecisionKey: "today.seam-check",
            sourceRecordID: "SourceRecord.seam-check",
            receiptID: "Receipt.seam-check",
            replayTraceID: "ReplayTrace.seam-check",
            contextBoundaryIDs: ["source_record", "receipt", "replay_trace", "you_inspection"],
            sourceRecordIDs: ["source-a"],
            receiptIDs: ["receipt-a"],
            replayTraceIDs: ["replay-a"],
            runtimeSnapshotReferenceIDs: ["runtime-snapshot-a"],
            localFitLabels: ["fit-a"]
        )

        XCTAssertTrue(variant.hasInspectionSeams)
        XCTAssertTrue(variant.hasReasonGraph)
        XCTAssertTrue(variant.hasCounterfactualEvidence)
        XCTAssertTrue(variant.isBoundedByMutationContext)
        XCTAssertEqual(variant.inspectionSeam.sourceRecordID, "SourceRecord.seam-check")
        XCTAssertEqual(variant.inspectionSeam.receiptID, "Receipt.seam-check")
        XCTAssertEqual(variant.inspectionSeam.replayTraceID, "ReplayTrace.seam-check")
        XCTAssertEqual(variant.inspectionSeam.inspectionSurfaceTitle, "What Ambitions knows")
        XCTAssertEqual(variant.inspectionSeam.youInspectionLabel, "You / What Ambitions knows")
        XCTAssertFalse(variant.hasVisibleCopyGuardrailViolation)
    }
}

private extension RecommendationMutationLabModelsTests {
    func makeVariant(
        id: String,
        mutationID: String,
        contextSummary: String,
        contextDeltaSummary: String?,
        recommendationID: String,
        traceID: String,
        reasonGraphID: String?,
        selectedLabel: String,
        alternativeLabel: String,
        deltaLabel: String,
        planningSummary: String,
        replayDecisionKey: String,
        sourceRecordID: String,
        receiptID: String,
        replayTraceID: String,
        contextBoundaryIDs: [String],
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceIDs: [String],
        runtimeSnapshotReferenceIDs: [String],
        localFitLabels: [String],
        includeCounterfactualEvidence: Bool = true
    ) throws -> RecommendationMutationLabVariant {
        _ = planningSummary
        let recommendationTrace = RecommendationTrace(
            id: traceID,
            recommendationID: recommendationID,
            source: RecommendationTraceSource(
                citedSourceIDs: sourceRecordIDs,
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.goalState],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation.\(id)",
                summary: "The local recommendation remains inspectable.",
                evidenceCategoryIDs: ["goal_state"]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: [],
                summaries: []
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["correct.\(id)"],
                controlActionIDs: ["control.\(id)"],
                correctableFieldKeys: ["domain_context"],
                hasRequiredControl: true
            ),
            receiptBehavior: .available(
                receiptIDs: receiptIDs,
                actionReceiptIDs: [],
                proofReferenceIDs: replayTraceIDs
            )
        )

        let reasonGraph = reasonGraphID.map { makeReasonGraph(
            id: $0,
            recommendationID: recommendationID,
            sourceRecordIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
            localFitLabels: localFitLabels,
            selectedLabel: selectedLabel,
            alternativeLabel: alternativeLabel,
            deltaLabel: deltaLabel
        ) }

        let recommendationCounterfactualDiff = includeCounterfactualEvidence ? RecommendationTraceCounterfactualDiff(
            id: "counterfactual.\(id)",
            selectedNodeID: "node.\(id).selected",
            alternativeNodeID: "node.\(id).alternative",
            selectedLabel: selectedLabel,
            alternativeLabel: alternativeLabel,
            deltaLabel: deltaLabel,
            sourceIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
            localFitLabels: localFitLabels
        ) : nil

        let planningCounterfactualDiff = includeCounterfactualEvidence ? PlanningRuleCounterfactualDiff(
            selectedTraceID: "trace.\(id).selected",
            alternativeTraceID: "trace.\(id).alternative",
            selectedStepID: "step.\(id).selected",
            alternativeStepID: "step.\(id).alternative",
            selectedStepTitle: selectedLabel,
            alternativeStepTitle: alternativeLabel,
            selectedRank: 1,
            alternativeRank: 2,
            selectedLocalFitLabel: "fit-selected",
            alternativeLocalFitLabel: "fit-alternative",
            sourceRecordID: sourceRecordID,
            receiptID: receiptID,
            replayTraceID: replayTraceID,
            runtimeSnapshotReferenceID: runtimeSnapshotReferenceIDs.first
        ) : nil

        let replayTrace = try makeReplayTrace(
            decisionKey: replayDecisionKey,
            recommendationTrace: recommendationTrace
        )

        return RecommendationMutationLabVariant(
            id: id,
            mutationID: mutationID,
            contextSummary: contextSummary,
            contextDeltaSummary: contextDeltaSummary,
            recommendationTrace: recommendationTrace,
            reasonGraph: reasonGraph,
            recommendationCounterfactualDiff: recommendationCounterfactualDiff,
            planningCounterfactualDiff: planningCounterfactualDiff,
            replayTrace: replayTrace,
            inspectionSeam: RecommendationMutationLabInspectionSeam(
                sourceRecordID: sourceRecordID,
                receiptID: receiptID,
                replayTraceID: replayTraceID,
                sourceRecordLabel: "Source record stays local",
                replayTraceLabel: "Replay trace stays inspectable"
            ),
            contextBoundaryIDs: contextBoundaryIDs,
            sourceRecordIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
            localFitLabels: localFitLabels
        )
    }

    func makeReasonGraph(
        id: String,
        recommendationID: String,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceIDs: [String],
        runtimeSnapshotReferenceIDs: [String],
        localFitLabels: [String],
        selectedLabel: String,
        alternativeLabel: String,
        deltaLabel: String
    ) -> RecommendationTraceReasonGraph {
        let sourceNode = RecommendationTraceReasonGraphNode(
            id: "node.\(id).source",
            kind: .source,
            label: "Source record stays local",
            sourceIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
            localFitLabels: localFitLabels
        )
        let reasonNode = RecommendationTraceReasonGraphNode(
            id: "node.\(id).reason",
            kind: .reason,
            label: "Reason stays bounded",
            sourceIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
            localFitLabels: localFitLabels
        )
        let uncertaintyNode = RecommendationTraceReasonGraphNode(
            id: "node.\(id).uncertainty",
            kind: .uncertainty,
            label: "Review remains local",
            sourceIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
            localFitLabels: localFitLabels
        )
        let receiptNode = RecommendationTraceReasonGraphNode(
            id: "node.\(id).receipt",
            kind: .receipt,
            label: "Receipt stays local",
            sourceIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
            localFitLabels: localFitLabels
        )

        return RecommendationTraceReasonGraph(
            id: "graph.\(id)",
            recommendationID: recommendationID,
            selectedNodeID: reasonNode.id,
            sourceIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
            localFitLabels: localFitLabels,
            nodes: [sourceNode, reasonNode, uncertaintyNode, receiptNode],
            edges: [
                RecommendationTraceReasonGraphEdge(
                    id: "edge.\(id).source-reason",
                    fromNodeID: sourceNode.id,
                    toNodeID: reasonNode.id,
                    label: "Source explains the recommendation",
                    sourceIDs: sourceRecordIDs,
                    receiptIDs: receiptIDs,
                    replayTraceIDs: replayTraceIDs,
                    runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
                    localFitLabels: localFitLabels
                ),
                RecommendationTraceReasonGraphEdge(
                    id: "edge.\(id).reason-uncertainty",
                    fromNodeID: reasonNode.id,
                    toNodeID: uncertaintyNode.id,
                    label: "Review stays local",
                    sourceIDs: sourceRecordIDs,
                    receiptIDs: receiptIDs,
                    replayTraceIDs: replayTraceIDs,
                    runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
                    localFitLabels: localFitLabels
                ),
                RecommendationTraceReasonGraphEdge(
                    id: "edge.\(id).reason-receipt",
                    fromNodeID: reasonNode.id,
                    toNodeID: receiptNode.id,
                    label: "Receipt keeps the trace inspectable",
                    sourceIDs: sourceRecordIDs,
                    receiptIDs: receiptIDs,
                    replayTraceIDs: replayTraceIDs,
                    runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
                    localFitLabels: localFitLabels
                )
            ],
            counterfactualDiffs: [
                RecommendationTraceCounterfactualDiff(
                    id: "graph-diff.\(id)",
                    selectedNodeID: reasonNode.id,
                    alternativeNodeID: uncertaintyNode.id,
                    selectedLabel: selectedLabel,
                    alternativeLabel: alternativeLabel,
                    deltaLabel: deltaLabel,
                    sourceIDs: sourceRecordIDs,
                    receiptIDs: receiptIDs,
                    replayTraceIDs: replayTraceIDs,
                    runtimeSnapshotReferenceIDs: runtimeSnapshotReferenceIDs,
                    localFitLabels: localFitLabels
                )
            ],
            policyHook: .localOnly()
        )
    }

    func makeReplayTrace(
        decisionKey: String,
        recommendationTrace: RecommendationTrace
    ) throws -> ReplayableDecisionTrace {
        let kernel = PrivateLifeRuntimeKernel()
        let runtimeContext = RuntimeContextSnapshot(
            clientContext: .iphoneApp,
            capabilities: .currentLocalRuntime,
            syncStatus: SyncCapabilityStatus(
                backendKind: .localOnly,
                trustPosture: .localOnly,
                availability: .unavailable,
                detail: "Ambitions is running in explicit local-only mode."
            ),
            knowledgeProviderStatuses: [
                KnowledgeProviderStatus(
                    provider: KnowledgeProviderDescriptor(
                        id: "provider.local",
                        type: .systemFallback,
                        displayName: "Local provider"
                    ),
                    availability: .localOnlyMode,
                    detail: "Local provider keeps the trace bounded.",
                    runtimeTrustPosture: .localOnly
                )
            ],
            memorySummary: RuntimeMemorySummary(
                memory: RuntimeMemorySnapshot(
                    goals: [],
                    drafts: [],
                    evidence: [],
                    feedback: [],
                    captures: [],
                    appState: .default
                )
            ),
            externalSurfaceSnapshot: nil
        )
        let traceContext = PrivateLifeRuntimeKernelTraceContext(
            runtimeContext: runtimeContext
        )

        return kernel.makeReplayableDecisionTrace(
            PrivateLifeRuntimeKernelDecisionInput(
                traceContext: traceContext,
                decisionKey: decisionKey,
                recommendationTrace: recommendationTrace
            )
        )
    }
}
