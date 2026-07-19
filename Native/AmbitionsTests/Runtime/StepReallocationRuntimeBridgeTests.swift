import XCTest
@testable import Ambitions

final class StepReallocationRuntimeBridgeTests: XCTestCase {
    func testApprovedStepReallocationDecisionProducesReplayableTraceThroughSourceAdapter() throws {
        let bridge = StepReallocationRuntimeBridge()
        let context = makeRuntimeContext()
        let proofReferenceID = "proof.step-reallocation.1"
        let sourceRecord = SourceRecord(
            id: "source.step-reallocation.runtime-1",
            providerID: "provider.local",
            entityTitle: "Source for runtime bridge",
            publisher: nil,
            locator: "local://step-reallocation/runtime/1",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let sourceStepObject = LifeGraphObjectReference(
            kind: .step,
            id: "step.source-reallocation-runtime-1",
            label: "Workout block",
            sourceDomain: .today
        )
        let destinationStepObject = LifeGraphObjectReference(
            kind: .step,
            id: "step.destination-reallocation-runtime-1",
            label: "Creative block",
            sourceDomain: .today
        )
        let receipt = Receipt(
            id: "receipt.step-reallocation.runtime-1",
            resultState: .changed,
            title: "Momentum reflow approved",
            summary: "Approved local reflow moved to a creative destination.",
            sourceDomain: .goals,
            occurredAt: "2026-05-24T10:05:00Z",
            affectedObjects: [sourceStepObject, destinationStepObject],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "receipt.step-reallocation.runtime-1.time",
                    kind: .changedField,
                    object: sourceStepObject,
                    fieldName: "timeContext",
                    previousValueSummary: "pending",
                    newValueSummary: "approved reallocation",
                    summary: "Time context changed after approval."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: LifeGraphObjectReference(
                kind: .evidence,
                id: sourceRecord.id,
                label: sourceRecord.entityTitle,
                sourceDomain: .you
            )
        )
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: proofReferenceID
        )
        let decision = StepReallocationApprovedDecision(
            id: "approval-runtime-1",
            sourceRecord: sourceRecord,
            receipt: receipt,
            replayTrace: replayTrace,
            timeContext: StepReallocationTimeContext(
                scheduledBlockLabel: "Workout block",
                timeWindowLabel: "7:00 PM to 8:00 PM",
                protectedTimeLabel: "Protected time remains visible",
                scheduleImpactSummary: "Approved runtime bridge input remains local-only and inspectable.",
                isProtectedTimeVisible: true
            ),
            momentumContext: StepReallocationMomentumContext(
                sourceStepID: sourceStepObject.id,
                sourceStepTitle: "Workout block",
                destinationStepID: destinationStepObject.id,
                destinationStepTitle: "Creative block",
                momentumSummary: "Momentum reallocation is explicit and inspectable."
            ),
            pressureImpact: StepReallocationPressureImpact(
                deadlinePolicyLabel: "Deadline impact reviewed",
                pressureSummary: "Displaced pressure remains visible.",
                reviewSummary: "No silent schedule mutation occurs."
            ),
            proofImpact: StepReallocationProofImpact(
                proofOpportunityLabel: "Proof follows the destination step",
                proofSummary: "Proof stays attached to replayable runtime input.",
                proofReferenceIDs: [proofReferenceID]
            ),
            approvedAt: "2026-05-24T10:05:00Z",
            approvalSummary: "User-approved reflow emits source adapter input.",
            isApproved: true
        )

        let trace = try XCTUnwrap(bridge.makeReplayableDecisionTrace(
            from: decision,
            runtimeContext: context,
            goalText: destinationStepObject.label ?? destinationStepObject.id
        ))
        let runtimeInput = try XCTUnwrap(bridge.makeRuntimeInput(
            from: decision,
            runtimeContext: context,
            goalText: destinationStepObject.label ?? destinationStepObject.id
        ))
        let expectedOutput = PrivateLifeRuntimeKernel().evaluate(runtimeInput.runtimeInput)

        XCTAssertTrue(trace.isReplayable)
        XCTAssertTrue(trace.isLocalOnly)
        XCTAssertEqual(trace.decisionKey, runtimeInput.runtimeInput.decisionKey)
        XCTAssertTrue(trace.id.hasPrefix("replayable-decision-trace."))
        XCTAssertEqual(trace.decisionRecordID?.hasPrefix("replayable-decision-record."), expectedOutput.recordID != nil)
        XCTAssertEqual(trace.recommendation?.source.citedSourceIDs, runtimeInput.recommendationTrace.source.citedSourceIDs)
    }

    func testReplayableDecisionTraceIsStableForUnchangedSourceStateAndChangesWhenSourceStateChanges() throws {
        let bridge = StepReallocationRuntimeBridge()
        let context = makeRuntimeContext()
        let sourceRecord = SourceRecord(
            id: "source.step-reallocation.runtime-2",
            providerID: "provider.local",
            entityTitle: "Source for replay stability",
            publisher: nil,
            locator: "local://step-reallocation/runtime/2",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let sourceStepObject = LifeGraphObjectReference(
            kind: .step,
            id: "step.source-reallocation-runtime-2",
            label: "Workout block",
            sourceDomain: .today
        )
        let destinationStepObject = LifeGraphObjectReference(
            kind: .step,
            id: "step.destination-reallocation-runtime-2",
            label: "Music block",
            sourceDomain: .today
        )
        let proofReferenceID = "proof.step-reallocation.2"
        let receipt = Receipt(
            id: "receipt.step-reallocation.runtime-2",
            resultState: .changed,
            title: "Momentum reflow replayable",
            summary: "Replayable runtime trace should preserve state unless source changes.",
            sourceDomain: .goals,
            occurredAt: "2026-05-24T15:15:00Z",
            affectedObjects: [sourceStepObject, destinationStepObject],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "receipt.step-reallocation.runtime-2.time",
                    kind: .changedField,
                    object: destinationStepObject,
                    fieldName: "timeContext",
                    previousValueSummary: "pending",
                    newValueSummary: "approved reallocation",
                    summary: "Replayability remains anchored."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: LifeGraphObjectReference(
                kind: .evidence,
                id: sourceRecord.id,
                label: sourceRecord.entityTitle,
                sourceDomain: .you
            )
        )
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: proofReferenceID
        )
        let baseDecision = StepReallocationApprovedDecision(
            id: "approval-runtime-2",
            sourceRecord: sourceRecord,
            receipt: receipt,
            replayTrace: replayTrace,
            timeContext: StepReallocationTimeContext(
                scheduledBlockLabel: "Workout block",
                timeWindowLabel: "3:00 PM to 4:00 PM",
                protectedTimeLabel: "Protected time remains visible",
                scheduleImpactSummary: "Replay should hold stable until source changes.",
                isProtectedTimeVisible: true
            ),
            momentumContext: StepReallocationMomentumContext(
                sourceStepID: sourceStepObject.id,
                sourceStepTitle: "Workout block",
                destinationStepID: destinationStepObject.id,
                destinationStepTitle: "Music block",
                momentumSummary: "Music momentum follows explicit reflow."
            ),
            pressureImpact: StepReallocationPressureImpact(
                deadlinePolicyLabel: "Reviewed",
                pressureSummary: "Displaced pressure remains visible.",
                reviewSummary: "Pressure impact still visible in replay."
            ),
            proofImpact: StepReallocationProofImpact(
                proofOpportunityLabel: "Proof opportunity follows destination",
                proofSummary: "Proof trail is still source-linked.",
                proofReferenceIDs: [proofReferenceID]
            ),
            approvedAt: "2026-05-24T15:15:00Z",
            approvalSummary: "Replayable decision is stable.",
            isApproved: true
        )

        let baselineEvent = try XCTUnwrap(baseDecision.emitStepReallocationEvent())
        let baselineTrace = bridge.makeReplayableDecisionTrace(
            from: baselineEvent,
            runtimeContext: context,
            goalText: destinationStepObject.label ?? destinationStepObject.id
        )
        let repeatTrace = bridge.makeReplayableDecisionTrace(
            from: baselineEvent,
            runtimeContext: context,
            goalText: destinationStepObject.label ?? destinationStepObject.id
        )

        XCTAssertEqual(baselineTrace, repeatTrace)
        XCTAssertTrue(baselineTrace.isReplayable)
        XCTAssertEqual(
            baselineTrace.recommendation?.source.citedSourceIDs,
            repeatTrace.recommendation?.source.citedSourceIDs
        )

        let changedReplayReference = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: "proof.step-reallocation.changed"
        )
        let changedDecision = StepReallocationApprovedDecision(
            id: "approval-runtime-2",
            sourceRecord: sourceRecord,
            receipt: receipt,
            replayTrace: changedReplayReference,
            timeContext: baseDecision.timeContext,
            momentumContext: baseDecision.momentumContext,
            pressureImpact: baseDecision.pressureImpact,
            proofImpact: StepReallocationProofImpact(
                proofOpportunityLabel: baseDecision.proofImpact.proofOpportunityLabel,
                proofSummary: baseDecision.proofImpact.proofSummary,
                proofReferenceIDs: ["proof.step-reallocation.changed"]
            ),
            approvedAt: baseDecision.approvedAt,
            approvalSummary: baseDecision.approvalSummary,
            isApproved: true
        )
        let changedEvent = try XCTUnwrap(changedDecision.emitStepReallocationEvent())
        let changedTrace = bridge.makeReplayableDecisionTrace(
            from: changedEvent,
            runtimeContext: context,
            goalText: destinationStepObject.label ?? destinationStepObject.id
        )

        XCTAssertNotEqual(baselineTrace, changedTrace)
        XCTAssertNotEqual(
            baselineTrace.recommendation?.source.citedSourceIDs,
            changedTrace.recommendation?.source.citedSourceIDs
        )
    }
}

private extension StepReallocationRuntimeBridgeTests {
    func makeRuntimeContext() -> RuntimeContextSnapshot {
        let memory = RuntimeMemorySnapshot(
            goals: [],
            drafts: [],
            evidence: [],
            feedback: [],
            captures: [],
            appState: .default
        )
        let syncStatus = SyncCapabilityStatus(
            backendKind: .localOnly,
            trustPosture: .localOnly,
            availability: .unavailable,
            detail: "Step reallocation runtime bridge tests run local-only."
        )
        return RuntimeContextSnapshot(
            clientContext: .iphoneApp,
            capabilities: .currentLocalRuntime,
            syncStatus: syncStatus,
            knowledgeProviderStatuses: [
                KnowledgeProviderStatus(
                    provider: KnowledgeProviderDescriptor(
                        id: "provider.local",
                        type: .systemFallback,
                        displayName: "Local provider"
                    ),
                    availability: .localOnlyMode,
                    detail: "Runtime bridge tests remain local-only.",
                    runtimeTrustPosture: .localOnly
                )
            ],
            memorySummary: RuntimeMemorySummary(memory: memory),
            externalSurfaceSnapshot: nil
        )
    }

    func makeReplayTrace(
        sourceRecordID: String,
        receiptID: String,
        proofReferenceID: String
    ) -> ReplayTrace {
        let traceContext = PrivateLifeRuntimeKernelTraceContext(runtimeContext: makeRuntimeContext())
        let recommendationTrace = makeRecommendationTrace(
            id: "trace.step-reallocation-runtime-bridge.\(UUID().uuidString)",
            recommendationID: "recommendation.step-reallocation-runtime-bridge.\(UUID().uuidString)",
            citedSourceIDs: [
                sourceRecordID,
                receiptID,
                proofReferenceID
            ],
            localEvidenceCategories: [.sourceTruth, .goalState, .capacity],
            receiptBehavior: .available(
                receiptIDs: [receiptID],
                proofReferenceIDs: [proofReferenceID]
            )
        )

        return PrivateLifeRuntimeKernel().makeReplayableDecisionTrace(
            PrivateLifeRuntimeKernelDecisionInput(
                traceContext: traceContext,
                decisionKey: "step-reallocation-runtime-bridge",
                goalText: "Replay for bridge test",
                recommendationTrace: recommendationTrace
            )
        )
    }

    func makeRecommendationTrace(
        id: String,
        recommendationID: String,
        citedSourceIDs: [String],
        localEvidenceCategories: [RecommendationExplanationEvidenceCategory],
        receiptBehavior: RecommendationTraceReceiptBehavior
    ) -> RecommendationTrace {
        RecommendationTrace(
            id: id,
            recommendationID: recommendationID,
            source: RecommendationTraceSource(
                citedSourceIDs: citedSourceIDs,
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: localEvidenceCategories,
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation.step-reallocation-runtime-bridge.\(UUID().uuidString)",
                summary: "Runtime bridge input is local and inspectable.",
                evidenceCategoryIDs: [RecommendationExplanationEvidenceCategory.sourceTruth.rawValue]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty-step-reallocation-runtime-bridge"],
                summaries: ["This effect is replayable until source context changes."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["change_deadline", "change_route", "explain_more"],
                controlActionIDs: ["open_step", "start_now"],
                correctableFieldKeys: ["sourceRecord", "receipt", "replayTrace", "timeContext"],
                hasRequiredControl: true
            ),
            receiptBehavior: receiptBehavior
        )
    }
}
