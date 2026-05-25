import XCTest
@testable import Ambitions

final class ProjectStepOperationModelsTests: XCTestCase {
    func testBulkOperationKindTaxonomyCoversTheReplacementFloor() {
        XCTAssertEqual(
            Set(ProjectStepOperationKind.allCases),
            [
                .move,
                .shorten,
                .hold,
                .markNotNeededToday,
                .markNeedsRecovery,
                .keepDeadline,
                .adjustTimeline,
                .schedule,
                .unschedule,
                .markWaiting,
                .markBlocked,
                .attachProof,
                .bulkDownstreamContract,
                .receipt
            ]
        )

        XCTAssertEqual(ProjectStepOperationKind.move.displayName, "Move step")
        XCTAssertEqual(ProjectStepOperationKind.shorten.receiptTitle, "Step shortened")
        XCTAssertEqual(ProjectStepOperationKind.hold.receiptTitle, "Step held")
        XCTAssertEqual(ProjectStepOperationKind.keepDeadline.displayName, "Keep deadline")
        XCTAssertEqual(ProjectStepOperationKind.attachProof.displayName, "Attach proof")
    }

    func testMomentumReflowClosureProofReplayKeepsDispositionContinuationGoalThreadImpactAndProofOpportunityExplicit() throws {
        let sourceRecord = SourceRecord(
            id: "source.project-step.reflow.1",
            providerID: "provider.local",
            entityTitle: "Momentum reflow closure replay contract",
            publisher: nil,
            locator: "local://project-step/reflow",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .evidence,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let displacedStepObject = LifeGraphObjectReference(
            kind: .step,
            id: "step.project-step.reflow.source",
            label: "Rescope the release checklist",
            sourceDomain: .today
        )
        let continuedStepObject = LifeGraphObjectReference(
            kind: .step,
            id: "step.project-step.reflow.destination",
            label: "Continue the release checklist",
            sourceDomain: .today
        )
        let proofReferenceObject = LifeGraphObjectReference(
            kind: .proof,
            id: "proof.project-step.reflow",
            label: "Proof opportunity",
            sourceDomain: .proof
        )
        let receipt = Receipt(
            id: "receipt.project-step.reflow.1",
            resultState: .changed,
            title: "Momentum reflow recorded",
            summary: "The displaced step stays coherent while the continued step carries the proof opportunity forward.",
            sourceDomain: .goals,
            occurredAt: "2026-05-25T11:12:00Z",
            affectedObjects: [displacedStepObject, continuedStepObject],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "receipt.project-step.reflow.1.disposition",
                    kind: .changedField,
                    object: displacedStepObject,
                    fieldName: "originalStepDisposition",
                    previousValueSummary: "planned",
                    newValueSummary: ProjectStepDisposition.move.rawValue,
                    summary: "The original step disposition is explicit."
                ),
                ActionReceiptChangedFact(
                    id: "receipt.project-step.reflow.1.continuation",
                    kind: .changedField,
                    object: continuedStepObject,
                    fieldName: "destinationStepContinuation",
                    previousValueSummary: "not linked",
                    newValueSummary: "linked to the prior active session",
                    summary: "The destination continuation stays linked to the prior active or recent session context."
                ),
                ActionReceiptChangedFact(
                    id: "receipt.project-step.reflow.1.goal-thread",
                    kind: .changedField,
                    object: proofReferenceObject,
                    fieldName: "goalThreadImpact",
                    previousValueSummary: "untracked",
                    newValueSummary: "both goal threads updated",
                    summary: "Both affected goal threads receive state updates and impact explanations."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: sourceObject
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(
            receipt: receipt,
            proofRelevance: .countsAsProof
        )
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: try XCTUnwrap(proofLedgerEntry.proofReference?.id)
        )

        let sourceGoalThreadUpdate = ProjectStepGoalThreadUpdate(
            id: "goal-thread-update.source",
            goalThreadID: "goal-thread.source",
            goalThreadName: "Launch work",
            previousState: .active,
            newState: .reflowed,
            impactExplanation: "The source thread records that the original step moved into a different slot without losing proof.",
            affectedStepIDs: [displacedStepObject.id],
            proofReferenceIDs: [try XCTUnwrap(proofLedgerEntry.proofReference?.id)],
            receiptID: receipt.id
        )
        let destinationGoalThreadUpdate = ProjectStepGoalThreadUpdate(
            id: "goal-thread-update.destination",
            goalThreadID: "goal-thread.destination",
            goalThreadName: "Delivery work",
            previousState: .active,
            newState: .continued,
            impactExplanation: "The destination thread receives the continued step and keeps the proof opportunity attached to the new continuation.",
            affectedStepIDs: [continuedStepObject.id],
            proofReferenceIDs: [try XCTUnwrap(proofLedgerEntry.proofReference?.id)],
            receiptID: receipt.id
        )
        let continuationContext = ProjectStepContinuationContext(
            id: "continuation-context.project-step.reflow.1",
            priorSessionID: "session.project-step.reflow.0",
            priorSessionLabel: "Prior active session",
            destinationStepID: continuedStepObject.id,
            destinationStepTitle: continuedStepObject.label,
            linkageSummary: "The continued step stays linked to the prior active or recent session context.",
            receiptID: receipt.id
        )
        let proofOpportunity = ProjectStepProofOpportunity(
            id: "proof-opportunity.project-step.reflow.1",
            goalThreadID: destinationGoalThreadUpdate.goalThreadID,
            followsStepID: continuedStepObject.id,
            title: "Proof opportunity follows the continued step",
            summary: "The proof opportunity stays attached after the reflowed step is continued.",
            proofReferenceIDs: [try XCTUnwrap(proofLedgerEntry.proofReference?.id)]
        )
        let displacedStep = ProjectStepDisplacedStepRecord(
            id: displacedStepObject.id,
            title: displacedStepObject.label,
            originalDisposition: .move,
            coherenceSummary: "The displaced step remains coherent, is not deleted, and is not stale-carried."
        )
        let replay = ProjectStepClosureProofReplay(
            id: "project-step.closure-proof-replay.1",
            sourceRecord: sourceRecord,
            receipt: receipt,
            replayTrace: replayTrace,
            originalStep: displacedStep,
            continuationContext: continuationContext,
            sourceGoalThreadUpdate: sourceGoalThreadUpdate,
            destinationGoalThreadUpdate: destinationGoalThreadUpdate,
            proofOpportunity: proofOpportunity
        )

        XCTAssertEqual(replay.sourceRecordLabel, "Momentum reflow closure replay contract")
        XCTAssertEqual(replay.receiptLabel, "Momentum reflow recorded")
        XCTAssertEqual(replay.replayTraceLabel, "Replay trace stays local and inspectable")
        XCTAssertTrue(replay.isInspectableBoundary)
        XCTAssertTrue(replay.isWellFormed)
        XCTAssertEqual(replay.originalDispositionLabel, "Move")
        XCTAssertEqual(replay.originalStep.originalDisposition, .move)
        XCTAssertEqual(replay.continuationContext.destinationStepID, continuedStepObject.id)
        XCTAssertEqual(replay.continuationContext.priorSessionLabel, "Prior active session")
        XCTAssertTrue(replay.continuationContext.isWellFormed)
        XCTAssertEqual(replay.continuationContext.linkageSummary, "The continued step stays linked to the prior active or recent session context.")
        XCTAssertEqual(replay.sourceGoalThreadUpdate.goalThreadID, "goal-thread.source")
        XCTAssertEqual(replay.sourceGoalThreadUpdate.previousState, .active)
        XCTAssertEqual(replay.sourceGoalThreadUpdate.newState, .reflowed)
        XCTAssertEqual(replay.destinationGoalThreadUpdate.goalThreadID, "goal-thread.destination")
        XCTAssertEqual(replay.destinationGoalThreadUpdate.previousState, .active)
        XCTAssertEqual(replay.destinationGoalThreadUpdate.newState, .continued)
        XCTAssertEqual(replay.sourceGoalThreadUpdate.impactExplanation, "The source thread records that the original step moved into a different slot without losing proof.")
        XCTAssertEqual(replay.destinationGoalThreadUpdate.impactExplanation, "The destination thread receives the continued step and keeps the proof opportunity attached to the new continuation.")
        XCTAssertTrue(replay.proofOpportunity.isWellFormed)
        XCTAssertEqual(replay.proofOpportunity.followsStepID, continuedStepObject.id)
        XCTAssertEqual(replay.proofOpportunity.proofReferenceIDs, [try XCTUnwrap(proofLedgerEntry.proofReference?.id)])
        XCTAssertTrue(replay.originalStep.remainsCoherent)
        XCTAssertFalse(replay.originalStep.isDeleted)
        XCTAssertFalse(replay.originalStep.isStaleCarried)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let decoder = JSONDecoder()
        let encodedReplay = try encoder.encode(replay)
        let decodedReplay = try decoder.decode(ProjectStepClosureProofReplay.self, from: encodedReplay)
        XCTAssertEqual(decodedReplay, replay)
        XCTAssertEqual(decodedReplay.schemaVersion, projectStepClosureProofReplaySchemaVersion)
    }

    func testMomentumReflowDispositionAndThreadStateTaxonomiesStayExplicit() {
        XCTAssertEqual(
            Set(ProjectStepDisposition.allCases),
            [
                .move,
                .shorten,
                .hold,
                .markNotNeededToday,
                .markNeedsRecovery,
                .keepDeadline,
                .adjustTimeline
            ]
        )
        XCTAssertEqual(ProjectStepDisposition.move.displayName, "Move")
        XCTAssertEqual(ProjectStepDisposition.markNotNeededToday.receiptTitle, "Step marked not needed today")
        XCTAssertEqual(ProjectStepGoalThreadState.continued.displayName, "Continued")
        XCTAssertEqual(ProjectStepGoalThreadState.needsRecovery.displayName, "Needs recovery")
    }

    func testBulkDownstreamContractStaysLocalAndInspectableThroughSourceReceiptReplayAndYouSeams() throws {
        let sourceRecord = SourceRecord(
            id: "source.project-step.bulk.1",
            providerID: "provider.local",
            entityTitle: "Project step bulk operations contract",
            publisher: nil,
            locator: "local://project-step/bulk",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .evidence,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let stepObject = LifeGraphObjectReference(
            kind: .step,
            id: "step.project-step.bulk.1",
            label: "Draft launch checklist",
            sourceDomain: .today
        )
        let receipt = Receipt(
            id: "receipt.project-step.bulk.1",
            resultState: .completed,
            title: "Project step bulk operations recorded",
            summary: "Move, hold, schedule, unschedule, waiting, blocked, proof, and receipts stay local.",
            sourceDomain: .goals,
            occurredAt: "2026-05-24T12:15:00Z",
            affectedObjects: [stepObject],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "receipt.project-step.bulk.1.changed",
                    kind: .changedField,
                    object: stepObject,
                    fieldName: "bulkOperationCount",
                    previousValueSummary: "0",
                    newValueSummary: "8",
                    summary: "Bulk project-step operations were recorded locally."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: sourceObject
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(
            receipt: receipt,
            proofRelevance: .countsAsProof
        )
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: try XCTUnwrap(proofLedgerEntry.proofReference?.id)
        )
        let operationReceipts = [
            makeOperationReceipt(
                id: "receipt.project-step.move",
                kind: .move,
                title: "Step moved",
                summary: "Move one step into a better local slot.",
                stepObject: stepObject,
                sourceRecord: sourceRecord,
                proofReferenceID: try XCTUnwrap(proofLedgerEntry.proofReference?.id)
            ),
            makeOperationReceipt(
                id: "receipt.project-step.hold",
                kind: .hold,
                title: "Step held",
                summary: "Hold one step without silent mutation.",
                stepObject: stepObject,
                sourceRecord: sourceRecord,
                proofReferenceID: try XCTUnwrap(proofLedgerEntry.proofReference?.id)
            ),
            makeOperationReceipt(
                id: "receipt.project-step.schedule",
                kind: .schedule,
                title: "Step scheduled",
                summary: "Schedule one step into the current window.",
                stepObject: stepObject,
                sourceRecord: sourceRecord,
                proofReferenceID: try XCTUnwrap(proofLedgerEntry.proofReference?.id)
            ),
            makeOperationReceipt(
                id: "receipt.project-step.unschedule",
                kind: .unschedule,
                title: "Step unscheduled",
                summary: "Unschedule one step without losing the receipt trail.",
                stepObject: stepObject,
                sourceRecord: sourceRecord,
                proofReferenceID: try XCTUnwrap(proofLedgerEntry.proofReference?.id)
            ),
            makeOperationReceipt(
                id: "receipt.project-step.waiting",
                kind: .markWaiting,
                title: "Step marked waiting",
                summary: "Mark one step waiting on a dependency.",
                stepObject: stepObject,
                sourceRecord: sourceRecord,
                proofReferenceID: try XCTUnwrap(proofLedgerEntry.proofReference?.id)
            ),
            makeOperationReceipt(
                id: "receipt.project-step.blocked",
                kind: .markBlocked,
                title: "Step marked blocked",
                summary: "Mark one step blocked until the blocker changes.",
                stepObject: stepObject,
                sourceRecord: sourceRecord,
                proofReferenceID: try XCTUnwrap(proofLedgerEntry.proofReference?.id)
            ),
            makeOperationReceipt(
                id: "receipt.project-step.proof",
                kind: .attachProof,
                title: "Proof attached",
                summary: "Attach proof to the step without leaving the local boundary.",
                stepObject: stepObject,
                sourceRecord: sourceRecord,
                proofReferenceID: try XCTUnwrap(proofLedgerEntry.proofReference?.id)
            ),
            makeOperationReceipt(
                id: "receipt.project-step.receipt",
                kind: .receipt,
                title: "Receipt recorded",
                summary: "Keep the receipt trail visible for the bulk contract.",
                stepObject: stepObject,
                sourceRecord: sourceRecord,
                proofReferenceID: try XCTUnwrap(proofLedgerEntry.proofReference?.id)
            )
        ]

        let contract = ProjectStepBulkDownstreamContract(
            id: "project-step.bulk.contract.1",
            title: "Move life commitments quickly",
            summary: "Bulk project-step operations stay local, inspectable, and replayable.",
            sourceRecord: sourceRecord,
            receipt: receipt,
            replayTrace: replayTrace,
            operationKinds: [
                .move,
                .hold,
                .schedule,
                .unschedule,
                .markWaiting,
                .markBlocked,
                .attachProof,
                .receipt
            ],
            operationReceipts: operationReceipts,
            downstreamContractIDs: ["downstream.contract.todoist", "downstream.contract.things"],
            proofReferenceIDs: [try XCTUnwrap(proofLedgerEntry.proofReference?.id)]
        )

        XCTAssertEqual(contract.bulkOperationCount, 8)
        XCTAssertTrue(contract.isBulk)
        XCTAssertEqual(contract.operationKinds, [
            .move,
            .hold,
            .schedule,
            .unschedule,
            .markWaiting,
            .markBlocked,
            .attachProof,
            .receipt
        ])
        XCTAssertEqual(
            contract.operationReceiptTitles,
            [
                "Step moved",
                "Step held",
                "Step scheduled",
                "Step unscheduled",
                "Step marked waiting",
                "Step marked blocked",
                "Proof attached",
                "Receipt recorded"
            ]
        )
        XCTAssertEqual(contract.sourceRecordLabel, "Project step bulk operations contract")
        XCTAssertEqual(contract.receiptLabel, "Project step bulk operations recorded")
        XCTAssertEqual(contract.replayTraceLabel, "Replay trace stays local and inspectable")
        XCTAssertEqual(contract.inspectionLabel, "What Ambitions knows")
        XCTAssertTrue(contract.isInspectableBoundary)
        XCTAssertTrue(contract.isWellFormed)
        XCTAssertEqual(contract.downstreamContractIDs, ["downstream.contract.todoist", "downstream.contract.things"])
        XCTAssertEqual(contract.proofReferenceIDs, [try XCTUnwrap(proofLedgerEntry.proofReference?.id)])
        XCTAssertEqual(contract.receipt.sourceObject?.id, sourceRecord.id)
        XCTAssertEqual(contract.replayTrace.decisionReceipt?.sourceRecordIDs, [receipt.id])
        XCTAssertEqual(contract.replayTrace.decisionReceipt?.replayTraceLabel, "Replay trace stays local and inspectable")
        XCTAssertTrue(contract.replayTrace.isLocalOnly)
        XCTAssertTrue(contract.replayTrace.isReplayable)
    }

    func testHarnessBlocksBroadReplacementClaimsWhileSourceReceiptReplayAndBulkEvidenceIsMissing() {
        let harness = ProjectStepBulkReplacementClaimHarnessFixture(
            moveEvidence: false,
            holdEvidence: false,
            scheduleEvidence: false,
            unscheduleEvidence: false,
            waitingEvidence: false,
            blockedEvidence: false,
            attachProofEvidence: false,
            bulkDownstreamContractEvidence: false,
            sourceRecordEvidence: false,
            receiptEvidence: false,
            replayTraceEvidence: false,
            youInspectionBoundaryEvidence: false,
            unsupportedClaims: ProjectStepBulkReplacementClaimHarnessFixture.forbiddenBroadClaims
        )

        XCTAssertEqual(
            harness.missingEvidence,
            [
                "move",
                "hold",
                "schedule",
                "unschedule",
                "mark waiting",
                "mark blocked",
                "attach proof",
                "bulk downstream contract",
                "source record",
                "receipt",
                "replay trace",
                "You inspection boundary",
            ]
        )
        XCTAssertTrue(harness.blocksBroadReplacementClaims)
        XCTAssertFalse(harness.allEvidencePresent)
        XCTAssertEqual(Set(harness.blockedClaims), Set(ProjectStepBulkReplacementClaimHarnessFixture.forbiddenBroadClaims))
    }
}

private extension ProjectStepOperationModelsTests {
    func makeOperationReceipt(
        id: String,
        kind: ProjectStepOperationKind,
        title: String,
        summary: String,
        stepObject: LifeGraphObjectReference,
        sourceRecord: SourceRecord,
        proofReferenceID: String
    ) -> Receipt {
        Receipt(
            id: id,
            resultState: kind == .receipt ? .completed : .changed,
            title: title,
            summary: summary,
            sourceDomain: .goals,
            occurredAt: "2026-05-24T12:15:00Z",
            affectedObjects: [stepObject],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "\(id).\(kind.rawValue)",
                    kind: .changedField,
                    object: stepObject,
                    fieldName: "proofReferenceID",
                    previousValueSummary: "untracked",
                    newValueSummary: proofReferenceID,
                    summary: summary
                ),
                ActionReceiptChangedFact(
                    id: "\(id).\(kind.rawValue).operation",
                    kind: .changedField,
                    object: stepObject,
                    fieldName: "projectStepOperation",
                    previousValueSummary: "unchanged",
                    newValueSummary: kind.rawValue,
                    summary: summary
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
    }

    func makeReplayTrace(
        sourceRecordID: String,
        receiptID: String,
        proofReferenceID: String
    ) -> ReplayTrace {
        let runtimeContext = RuntimeContextSnapshot(
            clientContext: .iphoneApp,
            capabilities: .currentLocalRuntime,
            syncStatus: SyncCapabilityStatus(
                backendKind: .localOnly,
                trustPosture: .localOnly,
                availability: .unavailable,
                detail: "Project-step bulk evidence remains local-only."
            ),
            knowledgeProviderStatuses: [
                KnowledgeProviderStatus(
                    provider: KnowledgeProviderDescriptor(
                        id: "provider.local",
                        type: .systemFallback,
                        displayName: "Local provider"
                    ),
                    availability: .localOnlyMode,
                    detail: "Project-step evidence stays on device.",
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
        let traceContext = PrivateLifeRuntimeKernelTraceContext(runtimeContext: runtimeContext)
        let recommendationTrace = RecommendationTrace(
            id: "trace.project-step.bulk.1",
            recommendationID: "recommendation.project-step.bulk.1",
            source: RecommendationTraceSource(
                citedSourceIDs: [sourceRecordID],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.sourceTruth, .memoryEvent],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation.project-step.bulk.1",
                summary: "Project-step bulk operations stay local, receipt-backed, and inspectable.",
                evidenceCategoryIDs: ["memory_event", "source_truth"]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty.project-step.bulk.1"],
                summaries: ["What Ambitions knows inspects the receipt and replay trail."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["correct.project-step.bulk.1"],
                controlActionIDs: ["move", "hold", "schedule", "unschedule", "mark waiting", "mark blocked", "attach proof"],
                correctableFieldKeys: ["receipt", "replayTrace", "sourceRecord"],
                hasRequiredControl: true
            ),
            receiptBehavior: RecommendationTraceReceiptBehavior.available(
                receiptIDs: [receiptID],
                actionReceiptIDs: [receiptID],
                proofReferenceIDs: [proofReferenceID]
            )
        )

        return PrivateLifeRuntimeKernel().makeReplayableDecisionTrace(
            PrivateLifeRuntimeKernelDecisionInput(
                traceContext: traceContext,
                decisionKey: "project.step.bulk.contract",
                goalText: "Move life commitments quickly without drifting from local proof.",
                recommendationTrace: recommendationTrace
            )
        )
    }

    func testMomentumReflowHarnessBlocksBroadReplacementClaimsWhileDispositionContinuationGoalThreadProofAndReplayEvidenceIsMissing() {
        let harness = ProjectStepClosureReplayClaimHarnessFixture(
            moveEvidence: false,
            shortenEvidence: false,
            holdEvidence: false,
            notNeededTodayEvidence: false,
            needsRecoveryEvidence: false,
            keepDeadlineEvidence: false,
            adjustTimelineEvidence: false,
            destinationContinuationEvidence: false,
            sourceGoalThreadEvidence: false,
            destinationGoalThreadEvidence: false,
            proofOpportunityEvidence: false,
            displacedStepCoherenceEvidence: false,
            sourceRecordEvidence: false,
            receiptEvidence: false,
            replayTraceEvidence: false,
            youInspectionBoundaryEvidence: false,
            unsupportedClaims: ProjectStepClosureReplayClaimHarnessFixture.forbiddenBroadClaims
        )

        XCTAssertEqual(
            harness.missingEvidence,
            [
                "move",
                "shorten",
                "hold",
                "mark not needed today",
                "mark needs recovery",
                "keep deadline",
                "adjust timeline",
                "destination step continuation",
                "source goal thread update",
                "destination goal thread update",
                "proof opportunity",
                "displaced step coherence",
                "source record",
                "receipt",
                "replay trace",
                "You inspection boundary",
            ]
        )
        XCTAssertTrue(harness.blocksBroadReplacementClaims)
        XCTAssertFalse(harness.allEvidencePresent)
        XCTAssertEqual(Set(harness.blockedClaims), Set(ProjectStepClosureReplayClaimHarnessFixture.forbiddenBroadClaims))
    }
}

private struct ProjectStepBulkReplacementClaimHarnessFixture: Sendable, Equatable {
    static let forbiddenBroadClaims = [
        "forbidden claim fixture: release-ready",
        "forbidden claim fixture: App Store-ready",
        "forbidden claim fixture: TestFlight-ready",
        "forbidden claim fixture: fully accessible",
        "forbidden claim fixture: performance validated",
        "forbidden claim fixture: privacy approved",
        "forbidden claim fixture: bulk project-step planning is complete",
        "forbidden claim fixture: Todoist / Things are fully replaced",
    ]

    let moveEvidence: Bool
    let holdEvidence: Bool
    let scheduleEvidence: Bool
    let unscheduleEvidence: Bool
    let waitingEvidence: Bool
    let blockedEvidence: Bool
    let attachProofEvidence: Bool
    let bulkDownstreamContractEvidence: Bool
    let sourceRecordEvidence: Bool
    let receiptEvidence: Bool
    let replayTraceEvidence: Bool
    let youInspectionBoundaryEvidence: Bool
    let unsupportedClaims: [String]

    var missingEvidence: [String] {
        var items: [String] = []
        if moveEvidence == false { items.append("move") }
        if holdEvidence == false { items.append("hold") }
        if scheduleEvidence == false { items.append("schedule") }
        if unscheduleEvidence == false { items.append("unschedule") }
        if waitingEvidence == false { items.append("mark waiting") }
        if blockedEvidence == false { items.append("mark blocked") }
        if attachProofEvidence == false { items.append("attach proof") }
        if bulkDownstreamContractEvidence == false { items.append("bulk downstream contract") }
        if sourceRecordEvidence == false { items.append("source record") }
        if receiptEvidence == false { items.append("receipt") }
        if replayTraceEvidence == false { items.append("replay trace") }
        if youInspectionBoundaryEvidence == false { items.append("You inspection boundary") }
        return items
    }

    var allEvidencePresent: Bool {
        missingEvidence.isEmpty
    }

    var blocksBroadReplacementClaims: Bool {
        allEvidencePresent == false || unsupportedClaims.isEmpty == false
    }

    var blockedClaims: [String] {
        Array(Set(unsupportedClaims)).sorted()
    }
}

private struct ProjectStepClosureReplayClaimHarnessFixture: Sendable, Equatable {
    static let forbiddenBroadClaims = [
        "forbidden claim fixture: release-ready",
        "forbidden claim fixture: App Store-ready",
        "forbidden claim fixture: TestFlight-ready",
        "forbidden claim fixture: fully accessible",
        "forbidden claim fixture: performance validated",
        "forbidden claim fixture: privacy approved",
        "forbidden claim fixture: project-step closure replay is complete",
        "forbidden claim fixture: Todoist / Things replacement is complete",
    ]

    let moveEvidence: Bool
    let shortenEvidence: Bool
    let holdEvidence: Bool
    let notNeededTodayEvidence: Bool
    let needsRecoveryEvidence: Bool
    let keepDeadlineEvidence: Bool
    let adjustTimelineEvidence: Bool
    let destinationContinuationEvidence: Bool
    let sourceGoalThreadEvidence: Bool
    let destinationGoalThreadEvidence: Bool
    let proofOpportunityEvidence: Bool
    let displacedStepCoherenceEvidence: Bool
    let sourceRecordEvidence: Bool
    let receiptEvidence: Bool
    let replayTraceEvidence: Bool
    let youInspectionBoundaryEvidence: Bool
    let unsupportedClaims: [String]

    var missingEvidence: [String] {
        var items: [String] = []
        if moveEvidence == false { items.append("move") }
        if shortenEvidence == false { items.append("shorten") }
        if holdEvidence == false { items.append("hold") }
        if notNeededTodayEvidence == false { items.append("mark not needed today") }
        if needsRecoveryEvidence == false { items.append("mark needs recovery") }
        if keepDeadlineEvidence == false { items.append("keep deadline") }
        if adjustTimelineEvidence == false { items.append("adjust timeline") }
        if destinationContinuationEvidence == false { items.append("destination step continuation") }
        if sourceGoalThreadEvidence == false { items.append("source goal thread update") }
        if destinationGoalThreadEvidence == false { items.append("destination goal thread update") }
        if proofOpportunityEvidence == false { items.append("proof opportunity") }
        if displacedStepCoherenceEvidence == false { items.append("displaced step coherence") }
        if sourceRecordEvidence == false { items.append("source record") }
        if receiptEvidence == false { items.append("receipt") }
        if replayTraceEvidence == false { items.append("replay trace") }
        if youInspectionBoundaryEvidence == false { items.append("You inspection boundary") }
        return items
    }

    var allEvidencePresent: Bool {
        missingEvidence.isEmpty
    }

    var blocksBroadReplacementClaims: Bool {
        allEvidencePresent == false || unsupportedClaims.isEmpty == false
    }

    var blockedClaims: [String] {
        Array(Set(unsupportedClaims)).sorted()
    }
}
