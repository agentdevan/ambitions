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
        let proofReferenceID = try XCTUnwrap(proofLedgerEntry.proofReference?.id)
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: proofReferenceID
        )

        let sourceGoalThreadUpdate = ProjectStepGoalThreadUpdate(
            id: "goal-thread-update.source",
            goalThreadID: "goal-thread.source",
            goalThreadName: "Launch work",
            previousState: ProjectStepGoalThreadState.active,
            newState: ProjectStepGoalThreadState.reflowed,
            impactExplanation: "The source thread records that the original step moved into a different slot without losing proof.",
            affectedStepIDs: [displacedStepObject.id],
            proofReferenceIDs: [proofReferenceID],
            receiptID: receipt.id
        )
        let destinationGoalThreadUpdate = ProjectStepGoalThreadUpdate(
            id: "goal-thread-update.destination",
            goalThreadID: "goal-thread.destination",
            goalThreadName: "Delivery work",
            previousState: ProjectStepGoalThreadState.active,
            newState: ProjectStepGoalThreadState.continued,
            impactExplanation: "The destination thread receives the continued step and keeps the proof opportunity attached to the new continuation.",
            affectedStepIDs: [continuedStepObject.id],
            proofReferenceIDs: [proofReferenceID],
            receiptID: receipt.id
        )
        let continuationContext = ProjectStepContinuationContext(
            id: "continuation-context.project-step.reflow.1",
            priorSessionID: "session.project-step.reflow.0",
            priorSessionLabel: "Prior active session",
            destinationStepID: continuedStepObject.id,
            destinationStepTitle: continuedStepObject.label ?? continuedStepObject.id,
            linkageSummary: "The continued step stays linked to the prior active or recent session context.",
            receiptID: receipt.id
        )
        let proofOpportunity = ProjectStepProofOpportunity(
            id: "proof-opportunity.project-step.reflow.1",
            goalThreadID: destinationGoalThreadUpdate.goalThreadID,
            followsStepID: continuedStepObject.id,
            title: "Proof opportunity follows the continued step",
            summary: "The proof opportunity stays attached after the reflowed step is continued.",
            proofReferenceIDs: [proofReferenceID]
        )
        let displacedStep = ProjectStepDisplacedStepRecord(
            id: displacedStepObject.id,
            title: displacedStepObject.label ?? displacedStepObject.id,
            originalDisposition: ProjectStepDisposition.move,
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
        XCTAssertEqual(replay.originalStep.originalDisposition, ProjectStepDisposition.move)
        XCTAssertEqual(replay.continuationContext.destinationStepID, continuedStepObject.id)
        XCTAssertEqual(replay.continuationContext.priorSessionLabel, "Prior active session")
        XCTAssertTrue(replay.continuationContext.isWellFormed)
        XCTAssertEqual(replay.continuationContext.linkageSummary, "The continued step stays linked to the prior active or recent session context.")
        XCTAssertEqual(replay.sourceGoalThreadUpdate.goalThreadID, "goal-thread.source")
        XCTAssertEqual(replay.sourceGoalThreadUpdate.previousState, ProjectStepGoalThreadState.active)
        XCTAssertEqual(replay.sourceGoalThreadUpdate.newState, ProjectStepGoalThreadState.reflowed)
        XCTAssertEqual(replay.destinationGoalThreadUpdate.goalThreadID, "goal-thread.destination")
        XCTAssertEqual(replay.destinationGoalThreadUpdate.previousState, ProjectStepGoalThreadState.active)
        XCTAssertEqual(replay.destinationGoalThreadUpdate.newState, ProjectStepGoalThreadState.continued)
        XCTAssertEqual(replay.sourceGoalThreadUpdate.impactExplanation, "The source thread records that the original step moved into a different slot without losing proof.")
        XCTAssertEqual(replay.destinationGoalThreadUpdate.impactExplanation, "The destination thread receives the continued step and keeps the proof opportunity attached to the new continuation.")
        XCTAssertTrue(replay.proofOpportunity.isWellFormed)
        XCTAssertEqual(replay.proofOpportunity.followsStepID, continuedStepObject.id)
        XCTAssertEqual(replay.proofOpportunity.proofReferenceIDs, [proofReferenceID])
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

    func testStepReallocationSourceAdapterPreservesSourceRecordReplayTraceAndInspectableBoundaryWithoutRawHistoryLeakage() throws {
        let sourceRecord = SourceRecord(
            id: "source.project-step.reallocation.1",
            providerID: "provider.local",
            entityTitle: "Momentum reflow source-adapter contract",
            publisher: nil,
            locator: "local://project-step/reallocation",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .evidence,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let sourceStepObject = LifeGraphObjectReference(
            kind: .step,
            id: "step.project-step.reallocation.source",
            label: "Workout block",
            sourceDomain: .today
        )
        let destinationStepObject = LifeGraphObjectReference(
            kind: .step,
            id: "step.project-step.reallocation.destination",
            label: "Music momentum block",
            sourceDomain: .today
        )
        let proofObject = LifeGraphObjectReference(
            kind: .proof,
            id: "proof.project-step.reallocation",
            label: "Reallocation proof opportunity",
            sourceDomain: .proof
        )
        let secretMarker = "PRIVATE-STEP-RELOCATION-RAW-HISTORY"
        let receipt = Receipt(
            id: "receipt.project-step.reallocation.1",
            resultState: .changed,
            title: "Momentum reflow approved",
            summary: "The approved reflow keeps the local schedule inspectable.",
            sourceDomain: .goals,
            occurredAt: "2026-05-25T13:15:00Z",
            affectedObjects: [sourceStepObject, destinationStepObject],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "receipt.project-step.reallocation.1.time",
                    kind: .changedField,
                    object: sourceStepObject,
                    fieldName: "timeContext",
                    previousValueSummary: "planned workout",
                    newValueSummary: "music momentum",
                    summary: "The approved block moved into the local time window."
                ),
                ActionReceiptChangedFact(
                    id: "receipt.project-step.reallocation.1.proof",
                    kind: .changedField,
                    object: proofObject,
                    fieldName: "proofOpportunity",
                    previousValueSummary: "awaiting transfer",
                    newValueSummary: "attached to the destination step",
                    summary: "The proof opportunity follows the destination step."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: sourceObject
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(receipt: receipt, proofRelevance: .countsAsProof)
        let proofReferenceID = try XCTUnwrap(proofLedgerEntry.proofReference?.id)
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: proofReferenceID
        )
        let event = StepReallocationEvent(
            id: "step-reallocation.event.1",
            sourceRecord: sourceRecord,
            receipt: receipt,
            replayTrace: replayTrace,
            timeContext: StepReallocationTimeContext(
                scheduledBlockLabel: "Workout block",
                timeWindowLabel: "6:00 PM to 7:00 PM",
                protectedTimeLabel: "Protected time stays visible",
                scheduleImpactSummary: "The approved source-adapter replay keeps the local schedule inspectable.",
                isProtectedTimeVisible: true
            ),
            momentumContext: StepReallocationMomentumContext(
                sourceStepID: sourceStepObject.id,
                sourceStepTitle: sourceStepObject.label ?? sourceStepObject.id,
                destinationStepID: destinationStepObject.id,
                destinationStepTitle: destinationStepObject.label ?? destinationStepObject.id,
                momentumSummary: secretMarker
            ),
            pressureImpact: StepReallocationPressureImpact(
                deadlinePolicyLabel: "Deadline impact reviewed before approval",
                pressureSummary: "Displaced pressure stays visible before the move is accepted.",
                reviewSummary: "The approved decision remains non-silent and inspectable."
            ),
            proofImpact: StepReallocationProofImpact(
                proofOpportunityLabel: "Proof opportunity follows the destination step",
                proofSummary: "The proof opportunity stays attached to the local replay.",
                proofReferenceIDs: [proofReferenceID]
            )
        )
        let adapter = StepReallocationSourceAdapter()
        let runtimeInput = adapter.makeRuntimeInput(
            from: event,
            runtimeContext: makeStepReallocationRuntimeContext(),
            goalText: destinationStepObject.label ?? destinationStepObject.id
        )
        let trace = PrivateLifeRuntimeKernel().makeReplayableDecisionTrace(runtimeInput.runtimeInput)

        XCTAssertTrue(event.isWellFormed)
        XCTAssertTrue(event.isInspectableBoundary)
        XCTAssertEqual(event.sourceAdapterUseSummary, "Step reallocation stays local and inspectable through source adapters.")
        XCTAssertEqual(runtimeInput.sourceRecord, sourceRecord)
        XCTAssertEqual(runtimeInput.receipt, receipt)
        XCTAssertEqual(runtimeInput.replayTrace, replayTrace)
        XCTAssertTrue(runtimeInput.isInspectableBoundary)
        XCTAssertTrue(runtimeInput.inspectionSummary.contains("Search Ambitions"))
        XCTAssertFalse(runtimeInput.inspectionSummary.contains(secretMarker))
        XCTAssertFalse(runtimeInput.sourceAdapterUseSummary.contains(secretMarker))
        XCTAssertTrue(trace.isLocalOnly)
        XCTAssertTrue(trace.isReplayable)
        XCTAssertEqual(
            trace.recommendation?.source.citedSourceIDs,
            [
                sourceRecord.id,
                receipt.id,
                "step.reallocation.\(event.id)",
                replayTrace.id
            ].sorted()
        )
        XCTAssertEqual(trace.recommendation?.receipt.proofReferenceIDs, [proofReferenceID])
    }

    func testStepReallocationEventEmitsOnlyFromApprovedReflowDecision() throws {
        let sourceRecord = SourceRecord(
            id: "source.project-step.reallocation.approval",
            providerID: "provider.local",
            entityTitle: "Approved reflow decision source",
            publisher: nil,
            locator: "local://project-step/reallocation/approval",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .evidence,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let sourceStepObject = LifeGraphObjectReference(
            kind: .step,
            id: "step.project-step.reallocation.approval.source",
            label: "Protected writing block",
            sourceDomain: .today
        )
        let destinationStepObject = LifeGraphObjectReference(
            kind: .step,
            id: "step.project-step.reallocation.approval.destination",
            label: "Launch proof block",
            sourceDomain: .today
        )
        let receipt = Receipt(
            id: "receipt.project-step.reallocation.approval",
            resultState: .changed,
            title: "Reflow decision approved",
            summary: "The user-approved reflow creates a local source-adapter event.",
            sourceDomain: .goals,
            occurredAt: "2026-05-25T15:05:00Z",
            affectedObjects: [sourceStepObject, destinationStepObject],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "receipt.project-step.reallocation.approval.time",
                    kind: .changedField,
                    object: destinationStepObject,
                    fieldName: "timeContext",
                    previousValueSummary: "waiting for approval",
                    newValueSummary: "approved local reflow",
                    summary: "The event is emitted only after the reflow decision is approved."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: sourceObject
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(receipt: receipt, proofRelevance: .countsAsProof)
        let proofReferenceID = try XCTUnwrap(proofLedgerEntry.proofReference?.id)
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: proofReferenceID
        )
        let approvedDecision = StepReallocationApprovedDecision(
            id: "approval.1",
            sourceRecord: sourceRecord,
            receipt: receipt,
            replayTrace: replayTrace,
            timeContext: StepReallocationTimeContext(
                scheduledBlockLabel: sourceStepObject.label ?? sourceStepObject.id,
                timeWindowLabel: "4:00 PM to 4:45 PM",
                protectedTimeLabel: "Protected writing block remains visible",
                scheduleImpactSummary: "The approved reflow moves only after source review.",
                isProtectedTimeVisible: true
            ),
            momentumContext: StepReallocationMomentumContext(
                sourceStepID: sourceStepObject.id,
                sourceStepTitle: sourceStepObject.label ?? sourceStepObject.id,
                destinationStepID: destinationStepObject.id,
                destinationStepTitle: destinationStepObject.label ?? destinationStepObject.id,
                momentumSummary: "Launch proof momentum is preserved."
            ),
            pressureImpact: StepReallocationPressureImpact(
                deadlinePolicyLabel: "Deadline reviewed",
                pressureSummary: "Displaced pressure is visible before the event is emitted.",
                reviewSummary: "No silent schedule mutation occurs."
            ),
            proofImpact: StepReallocationProofImpact(
                proofOpportunityLabel: "Proof follows the destination step",
                proofSummary: "The approval keeps proof attached to the destination step.",
                proofReferenceIDs: [proofReferenceID]
            ),
            approvedAt: "2026-05-25T15:05:00Z",
            approvalSummary: "User approved the local reflow decision.",
            isApproved: true
        )
        let declinedDecision = StepReallocationApprovedDecision(
            id: "approval.1",
            sourceRecord: sourceRecord,
            receipt: receipt,
            replayTrace: replayTrace,
            timeContext: approvedDecision.timeContext,
            momentumContext: approvedDecision.momentumContext,
            pressureImpact: approvedDecision.pressureImpact,
            proofImpact: approvedDecision.proofImpact,
            approvedAt: "2026-05-25T15:05:00Z",
            approvalSummary: "User reviewed but did not approve the reflow decision.",
            isApproved: false
        )

        let emittedEvent: StepReallocationEvent = try XCTUnwrap(approvedDecision.emitStepReallocationEvent())

        XCTAssertTrue(approvedDecision.isWellFormed)
        XCTAssertNil(declinedDecision.emitStepReallocationEvent())
        XCTAssertEqual(emittedEvent.id, "step-reallocation.event.approval.1")
        XCTAssertEqual(emittedEvent.sourceRecord, sourceRecord)
        XCTAssertEqual(emittedEvent.receipt, receipt)
        XCTAssertEqual(emittedEvent.replayTrace, replayTrace)
        XCTAssertEqual(emittedEvent.timeContext, approvedDecision.timeContext)
        XCTAssertEqual(emittedEvent.momentumContext, approvedDecision.momentumContext)
        XCTAssertEqual(emittedEvent.pressureImpact, approvedDecision.pressureImpact)
        XCTAssertEqual(emittedEvent.proofImpact, approvedDecision.proofImpact)
        XCTAssertTrue(emittedEvent.isWellFormed)
    }

    func testStepReallocationMomentumSignalSupportsReviewDisableResetDeleteAndExportBoundaries() throws {
        let sourceRecord = SourceRecord(
            id: "source.project-step.reallocation.personal-runtime",
            providerID: "provider.local",
            entityTitle: "Momentum reflow personal system contract",
            publisher: nil,
            locator: "local://project-step/reallocation/personal-runtime",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .evidence,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let sourceStepObject = LifeGraphObjectReference(
            kind: .step,
            id: "step.project-step.reallocation.personal-runtime.source",
            label: "Sensitive protected step",
            sourceDomain: .today
        )
        let destinationStepObject = LifeGraphObjectReference(
            kind: .step,
            id: "step.project-step.reallocation.personal-runtime.destination",
            label: "Momentum reflow destination",
            sourceDomain: .today
        )
        let proofObject = LifeGraphObjectReference(
            kind: .proof,
            id: "proof.project-step.reallocation.personal-runtime",
            label: "Personal runtime proof opportunity",
            sourceDomain: .proof
        )
        let receipt = Receipt(
            id: "receipt.project-step.reallocation.personal-runtime",
            resultState: .changed,
            title: "Momentum reflow recorded",
            summary: "The local momentum preference stays inspectable and reviewable.",
            sourceDomain: .goals,
            occurredAt: "2026-05-25T16:10:00Z",
            affectedObjects: [sourceStepObject, destinationStepObject],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "receipt.project-step.reallocation.personal-runtime.time",
                    kind: .changedField,
                    object: sourceStepObject,
                    fieldName: "timeContext",
                    previousValueSummary: "protected step",
                    newValueSummary: "review required",
                    summary: "The protected step cannot infer medical advice."
                ),
                ActionReceiptChangedFact(
                    id: "receipt.project-step.reallocation.personal-runtime.proof",
                    kind: .changedField,
                    object: proofObject,
                    fieldName: "proofOpportunity",
                    previousValueSummary: "pending",
                    newValueSummary: "attached to the new destination",
                    summary: "The proof opportunity remains source-tied."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: sourceObject
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(receipt: receipt, proofRelevance: .countsAsProof)
        let proofReferenceID = try XCTUnwrap(proofLedgerEntry.proofReference?.id)
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: proofReferenceID
        )
        let event = StepReallocationEvent(
            id: "step-reallocation.event.personal-runtime",
            sourceRecord: sourceRecord,
            receipt: receipt,
            replayTrace: replayTrace,
            timeContext: StepReallocationTimeContext(
                scheduledBlockLabel: "Sensitive protected step",
                timeWindowLabel: "8:00 PM to 8:30 PM",
                protectedTimeLabel: "Protected time remains visible",
                scheduleImpactSummary: "The protected step requires review before future ranking can use it.",
                isProtectedTimeVisible: true,
                requiresSensitiveReview: true
            ),
            momentumContext: StepReallocationMomentumContext(
                sourceStepID: sourceStepObject.id,
                sourceStepTitle: sourceStepObject.label ?? sourceStepObject.id,
                destinationStepID: destinationStepObject.id,
                destinationStepTitle: destinationStepObject.label ?? destinationStepObject.id,
                momentumSummary: "Momentum reflow stays bounded and source-tied."
            ),
            pressureImpact: StepReallocationPressureImpact(
                deadlinePolicyLabel: "Deadline pressure reviewed",
                pressureSummary: "The displaced pressure remains visible before reuse.",
                reviewSummary: "Sensitive and protected contexts require review."
            ),
            proofImpact: StepReallocationProofImpact(
                proofOpportunityLabel: "Proof opportunity follows the destination step",
                proofSummary: "The proof opportunity remains inspectable in the replay.",
                proofReferenceIDs: [proofReferenceID]
            )
        )

        let signal = event.personalRuntimeLearningSignal()
        let disabled = signal.disabling(at: "2026-05-25T16:11:00Z")
        let reset = signal.resetting(at: "2026-05-25T16:12:00Z")
        let deleted = signal.deleting(at: "2026-05-25T16:13:00Z")
        let reviewed = signal.reviewing()
        let exportSelection = signal.exportSelection(includingRelatedSource: true)
        let deleteSelection = signal.deleteSelection(includingRelatedSource: false)

        XCTAssertTrue(event.isWellFormed)
        XCTAssertTrue(event.isInspectableBoundary)
        XCTAssertEqual(signal.signalType, PersonalRuntimeLearningSignalType.momentumReflow)
        XCTAssertEqual(signal.confidenceState, PersonalRuntimeLearningSignalConfidenceState.reviewRequired)
        XCTAssertTrue(signal.requiresSensitiveReview)
        XCTAssertEqual(signal.personalRuntimeInspectionLabel, "Review required")
        XCTAssertTrue(signal.personalRuntimeInspectableSummary.contains("Protected or sensitive time requires review before future ranking can use this signal."))
        XCTAssertTrue(signal.personalRuntimeInspectableSummary.contains("Momentum Reflow never infers medical advice."))
        XCTAssertTrue(signal.isInspectableBoundary)
        XCTAssertTrue(signal.isInspectableAndControllable)
        XCTAssertTrue(signal.isExcludedFromFutureRanking)
        XCTAssertEqual(signal.personalRuntimeResetRoute, "you://personal-runtime/momentum_reflow/\(signal.id)/reset")
        XCTAssertEqual(signal.personalRuntimeDisableRoute, "you://personal-runtime/momentum_reflow/\(signal.id)/disable")
        XCTAssertEqual(signal.personalRuntimeDeleteRoute, "you://personal-runtime/momentum_reflow/\(signal.id)/delete")
        XCTAssertEqual(signal.personalRuntimeExportRoute, "you://personal-runtime/momentum_reflow/\(signal.id)/export")
        XCTAssertEqual(signal.sourceRecord, sourceRecord)
        XCTAssertEqual(signal.receipt, receipt)
        XCTAssertEqual(signal.replayTrace, replayTrace)
        XCTAssertEqual(signal.reviewSummary, "Protected or sensitive time requires review before future ranking can use this signal.")
        XCTAssertEqual(signal.medicalAdviceBoundarySummary, "Momentum Reflow never infers medical advice.")
        XCTAssertEqual(exportSelection.kind, PersonalRuntimeLearningSignalDataSelectionKind.export)
        XCTAssertTrue(exportSelection.includesSignal)
        XCTAssertTrue(exportSelection.includesRelatedSource)
        XCTAssertTrue(exportSelection.summary.contains("related source"))
        XCTAssertEqual(deleteSelection.kind, PersonalRuntimeLearningSignalDataSelectionKind.delete)
        XCTAssertFalse(deleteSelection.includesRelatedSource)
        XCTAssertTrue(deleteSelection.summary.contains("leaving the related source untouched"))

        XCTAssertEqual(disabled.confidenceState, PersonalRuntimeLearningSignalConfidenceState.disabled)
        XCTAssertTrue(disabled.isExcludedFromFutureRanking)
        XCTAssertEqual(reset.confidenceState, PersonalRuntimeLearningSignalConfidenceState.reset)
        XCTAssertTrue(reset.isExcludedFromFutureRanking)
        XCTAssertEqual(deleted.confidenceState, PersonalRuntimeLearningSignalConfidenceState.deleted)
        XCTAssertTrue(deleted.isExcludedFromFutureRanking)
        XCTAssertFalse(deleted.isInspectableAndControllable)
        XCTAssertEqual(reviewed.confidenceState, PersonalRuntimeLearningSignalConfidenceState.reviewRequired)
        XCTAssertTrue(reviewed.isExcludedFromFutureRanking)
    }

    func testStepReallocationReplayStaysStableUntilSourceStateChanges() throws {
        let sourceRecord = SourceRecord(
            id: "source.project-step.reallocation.2",
            providerID: "provider.local",
            entityTitle: "Momentum reflow replay contract",
            publisher: nil,
            locator: "local://project-step/reallocation/stable",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .evidence,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let sourceStepObject = LifeGraphObjectReference(
            kind: .step,
            id: "step.project-step.reallocation.stable.source",
            label: "Workout block",
            sourceDomain: .today
        )
        let destinationStepObject = LifeGraphObjectReference(
            kind: .step,
            id: "step.project-step.reallocation.stable.destination",
            label: "Music momentum block",
            sourceDomain: .today
        )
        let proofObject = LifeGraphObjectReference(
            kind: .proof,
            id: "proof.project-step.reallocation.stable",
            label: "Reallocation proof opportunity",
            sourceDomain: .proof
        )
        let receipt = Receipt(
            id: "receipt.project-step.reallocation.2",
            resultState: .changed,
            title: "Momentum reflow approved",
            summary: "The approved reflow keeps the local schedule inspectable.",
            sourceDomain: .goals,
            occurredAt: "2026-05-25T14:20:00Z",
            affectedObjects: [sourceStepObject, destinationStepObject],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "receipt.project-step.reallocation.2.time",
                    kind: .changedField,
                    object: sourceStepObject,
                    fieldName: "timeContext",
                    previousValueSummary: "planned workout",
                    newValueSummary: "music momentum",
                    summary: "The approved block moved into the local time window."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: sourceObject
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(receipt: receipt, proofRelevance: .countsAsProof)
        let proofReferenceID = try XCTUnwrap(proofLedgerEntry.proofReference?.id)
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: proofReferenceID
        )
        let adapter = StepReallocationSourceAdapter()
        let baseEvent = StepReallocationEvent(
            id: "step-reallocation.event.2",
            sourceRecord: sourceRecord,
            receipt: receipt,
            replayTrace: replayTrace,
            timeContext: StepReallocationTimeContext(
                scheduledBlockLabel: "Workout block",
                timeWindowLabel: "6:00 PM to 7:00 PM",
                protectedTimeLabel: "Protected time stays visible",
                scheduleImpactSummary: "The approved source-adapter replay keeps the local schedule inspectable.",
                isProtectedTimeVisible: true
            ),
            momentumContext: StepReallocationMomentumContext(
                sourceStepID: sourceStepObject.id,
                sourceStepTitle: sourceStepObject.label ?? sourceStepObject.id,
                destinationStepID: destinationStepObject.id,
                destinationStepTitle: destinationStepObject.label ?? destinationStepObject.id,
                momentumSummary: "The music step wins the approved local momentum."
            ),
            pressureImpact: StepReallocationPressureImpact(
                deadlinePolicyLabel: "Deadline impact reviewed before approval",
                pressureSummary: "Displaced pressure stays visible before the move is accepted.",
                reviewSummary: "The approved decision remains non-silent and inspectable."
            ),
            proofImpact: StepReallocationProofImpact(
                proofOpportunityLabel: "Proof opportunity follows the destination step",
                proofSummary: "The proof opportunity stays attached to the local replay.",
                proofReferenceIDs: [proofReferenceID]
            )
        )
        let baseRuntimeInput = adapter.makeRuntimeInput(
            from: baseEvent,
            runtimeContext: makeStepReallocationRuntimeContext(),
            goalText: destinationStepObject.label ?? destinationStepObject.id
        )
        let baseTrace = PrivateLifeRuntimeKernel().makeReplayableDecisionTrace(baseRuntimeInput.runtimeInput)
        let changedSourceRecord = SourceRecord(
            id: "source.project-step.reallocation.2.changed",
            providerID: "provider.local",
            entityTitle: "Momentum reflow replay contract, revised source state",
            publisher: nil,
            locator: "local://project-step/reallocation/stable",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let changedSourceObject = LifeGraphObjectReference(
            kind: .evidence,
            id: changedSourceRecord.id,
            label: changedSourceRecord.entityTitle,
            sourceDomain: .you
        )
        let changedReceipt = Receipt(
            id: "receipt.project-step.reallocation.2.changed",
            resultState: .changed,
            title: "Momentum reflow approved",
            summary: "The revised source state keeps the replay local but changes the recommendation effect.",
            sourceDomain: .goals,
            occurredAt: "2026-05-25T14:25:00Z",
            affectedObjects: [sourceStepObject, destinationStepObject],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "receipt.project-step.reallocation.2.changed.time",
                    kind: .changedField,
                    object: destinationStepObject,
                    fieldName: "timeContext",
                    previousValueSummary: "music momentum",
                    newValueSummary: "music momentum, updated",
                    summary: "The source state changed enough to alter the replay effect."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: changedSourceObject
        )
        let changedProofLedgerEntry = ActionReceiptProofLedgerEntry(receipt: changedReceipt, proofRelevance: .countsAsProof)
        let changedProofReferenceID = try XCTUnwrap(changedProofLedgerEntry.proofReference?.id)
        let changedReplayTrace = makeReplayTrace(
            sourceRecordID: changedSourceRecord.id,
            receiptID: changedReceipt.id,
            proofReferenceID: changedProofReferenceID
        )
        let changedEvent = StepReallocationEvent(
            id: "step-reallocation.event.2.changed",
            sourceRecord: changedSourceRecord,
            receipt: changedReceipt,
            replayTrace: changedReplayTrace,
            timeContext: StepReallocationTimeContext(
                scheduledBlockLabel: "Workout block",
                timeWindowLabel: "6:00 PM to 7:00 PM",
                protectedTimeLabel: "Protected time stays visible",
                scheduleImpactSummary: "The revised source state changes the replayed recommendation effect.",
                isProtectedTimeVisible: true
            ),
            momentumContext: StepReallocationMomentumContext(
                sourceStepID: sourceStepObject.id,
                sourceStepTitle: sourceStepObject.label ?? sourceStepObject.id,
                destinationStepID: destinationStepObject.id,
                destinationStepTitle: "Revised music momentum block",
                momentumSummary: "The music step still wins, but the source state is different."
            ),
            pressureImpact: StepReallocationPressureImpact(
                deadlinePolicyLabel: "Deadline impact reviewed before approval",
                pressureSummary: "Displaced pressure stays visible before the move is accepted.",
                reviewSummary: "The approved decision remains non-silent and inspectable."
            ),
            proofImpact: StepReallocationProofImpact(
                proofOpportunityLabel: "Proof opportunity follows the destination step",
                proofSummary: "The proof opportunity stays attached to the local replay.",
                proofReferenceIDs: [changedProofReferenceID]
            )
        )
        let changedRuntimeInput = adapter.makeRuntimeInput(
            from: changedEvent,
            runtimeContext: makeStepReallocationRuntimeContext(),
            goalText: "Revised music momentum block"
        )
        let changedTrace = PrivateLifeRuntimeKernel().makeReplayableDecisionTrace(changedRuntimeInput.runtimeInput)

        XCTAssertEqual(baseTrace.runtime.boundary.isLocalOnly, true)
        XCTAssertEqual(changedTrace.runtime.boundary.isLocalOnly, true)
        XCTAssertEqual(baseTrace.isReplayable, true)
        XCTAssertEqual(changedTrace.isReplayable, true)
        XCTAssertNotEqual(baseTrace, changedTrace)
        XCTAssertNotEqual(baseTrace.decisionKey, changedTrace.decisionKey)
        XCTAssertNotEqual(baseTrace.recommendation?.source.citedSourceIDs, changedTrace.recommendation?.source.citedSourceIDs)
        XCTAssertNotEqual(baseTrace.recommendation?.recommendationID, changedTrace.recommendation?.recommendationID)
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
        let proofReferenceID = try XCTUnwrap(proofLedgerEntry.proofReference?.id)
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: proofReferenceID
        )
        let operationReceipts = [
            makeOperationReceipt(
                id: "receipt.project-step.move",
                kind: .move,
                title: "Step moved",
                summary: "Move one step into a better local slot.",
                stepObject: stepObject,
                sourceRecord: sourceRecord,
                proofReferenceID: proofReferenceID
            ),
            makeOperationReceipt(
                id: "receipt.project-step.hold",
                kind: .hold,
                title: "Step held",
                summary: "Hold one step without silent mutation.",
                stepObject: stepObject,
                sourceRecord: sourceRecord,
                proofReferenceID: proofReferenceID
            ),
            makeOperationReceipt(
                id: "receipt.project-step.schedule",
                kind: .schedule,
                title: "Step scheduled",
                summary: "Schedule one step into the current window.",
                stepObject: stepObject,
                sourceRecord: sourceRecord,
                proofReferenceID: proofReferenceID
            ),
            makeOperationReceipt(
                id: "receipt.project-step.unschedule",
                kind: .unschedule,
                title: "Step unscheduled",
                summary: "Unschedule one step without losing the receipt trail.",
                stepObject: stepObject,
                sourceRecord: sourceRecord,
                proofReferenceID: proofReferenceID
            ),
            makeOperationReceipt(
                id: "receipt.project-step.waiting",
                kind: .markWaiting,
                title: "Step marked waiting",
                summary: "Mark one step waiting on a dependency.",
                stepObject: stepObject,
                sourceRecord: sourceRecord,
                proofReferenceID: proofReferenceID
            ),
            makeOperationReceipt(
                id: "receipt.project-step.blocked",
                kind: .markBlocked,
                title: "Step marked blocked",
                summary: "Mark one step blocked until the blocker changes.",
                stepObject: stepObject,
                sourceRecord: sourceRecord,
                proofReferenceID: proofReferenceID
            ),
            makeOperationReceipt(
                id: "receipt.project-step.proof",
                kind: .attachProof,
                title: "Proof attached",
                summary: "Attach proof to the step without leaving the local boundary.",
                stepObject: stepObject,
                sourceRecord: sourceRecord,
                proofReferenceID: proofReferenceID
            ),
            makeOperationReceipt(
                id: "receipt.project-step.receipt",
                kind: .receipt,
                title: "Receipt recorded",
                summary: "Keep the receipt trail visible for the bulk contract.",
                stepObject: stepObject,
                sourceRecord: sourceRecord,
                proofReferenceID: proofReferenceID
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
            proofReferenceIDs: [proofReferenceID]
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
        XCTAssertEqual(contract.inspectionLabel, "Search Ambitions")
        XCTAssertTrue(contract.isInspectableBoundary)
        XCTAssertTrue(contract.isWellFormed)
        XCTAssertEqual(contract.downstreamContractIDs, ["downstream.contract.things", "downstream.contract.todoist"])
        XCTAssertEqual(contract.proofReferenceIDs, [proofReferenceID])
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
    func makeStepReallocationRuntimeContext() -> RuntimeContextSnapshot {
        RuntimeContextSnapshot(
            clientContext: .iphoneApp,
            capabilities: .currentLocalRuntime,
            syncStatus: SyncCapabilityStatus(
                backendKind: .localOnly,
                trustPosture: .localOnly,
                availability: .unavailable,
                detail: "Project-step reallocation evidence remains local-only."
            ),
            knowledgeProviderStatuses: [
                KnowledgeProviderStatus(
                    provider: KnowledgeProviderDescriptor(
                        id: "provider.local",
                        type: .systemFallback,
                        displayName: "Local provider"
                    ),
                    availability: .localOnlyMode,
                    detail: "Project-step reallocation evidence stays on device.",
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
    }

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
                citedSourceIDs: [sourceRecordID, "project.step.bulk.contract"],
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
                summaries: ["Search Ambitions inspects the receipt and replay trail."]
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
