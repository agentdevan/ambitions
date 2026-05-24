import XCTest
@testable import Ambitions

final class CaptureRuntimeReceiptTests: XCTestCase {
    func testRuntimeReceiptKindsExposeRequiredTaxonomy() {
        let requiredKinds: Set<CaptureRuntimeReceiptKind> = [
            .captureExtracted,
            .captureNeedsClarification,
            .captureMatchedGoal,
            .captureWeakMatchRejected,
            .captureSavedAsFutureContext,
            .captureProposedForTime,
            .captureAddedToTime,
            .captureAttachedToGoal,
            .captureSavedAsProof,
            .captureRuntimeUsePaused,
            .captureCorrectionApplied,
            .captureReplayGenerated
        ]

        XCTAssertTrue(requiredKinds.isSubset(of: Set(CaptureRuntimeReceiptKind.allCases)))
    }

    func testRuntimeReplayTraceReconstructsReceiptAndRequiredKinds() throws {
        let service = DefaultSmartAttachmentService()
        let result = service.route(
            SmartAttachmentInput(rawText: "Finished first mix proof for Music Goal"),
            candidates: [
                SmartAttachmentDestinationCandidate(
                    id: "goal-music",
                    label: "Music Goal",
                    destinationKind: .existingGoal,
                    supportedRouteTypes: [.goal, .task, .proofItem]
                )
            ],
            maxCandidateCount: 5
        )

        let trace = result.captureRuntimeReplayTrace(
            timestamp: "2026-05-23T10:15:00Z",
            correction: CaptureRuntimeCorrectionInput(
                kind: .wrongGoal,
                goalID: "goal-guitar",
                note: "Music Goal was the wrong goal."
            )
        )

        XCTAssertEqual(trace.rawCapture, "Finished first mix proof for Music Goal")
        XCTAssertEqual(trace.extraction.rawText, "Finished first mix proof for Music Goal")
        XCTAssertNil(trace.ambiguity)
        XCTAssertEqual(trace.relevanceScan?.highConfidenceMatches.map(\.goalID), ["goal-music"])
        XCTAssertEqual(trace.proposedDestinations.map(\.id), [
            "proposal.smart-attachment-finished-first-mix-proof-for-music-goal.correction.goal.goal-guitar",
            "proposal.smart-attachment-finished-first-mix-proof-for-music-goal.selected.goal-music"
        ])
        XCTAssertEqual(trace.userDecision.correctionKind, .wrongGoal)
        XCTAssertEqual(trace.userDecision.correctionNote, "Music Goal was the wrong goal.")
        XCTAssertEqual(trace.runtimeUseStatus, .active)
        XCTAssertEqual(trace.receipt.kind, .captureCorrectionApplied)
        XCTAssertEqual(trace.receipt.timestamp, "2026-05-23T10:15:00Z")
        XCTAssertEqual(trace.receipt.whatWasCaptured, "[redacted]")
        XCTAssertTrue(trace.receipt.privacyRedactions.contains("raw capture text"))
        XCTAssertTrue(trace.receipt.whatWasDetected.contains("activity=Proof"))
        XCTAssertTrue(trace.receipt.whatWasDetected.contains("goal-relevance=match"))
        XCTAssertTrue(trace.receipt.whatWasDetected.contains("receipt-kind=capture_replay_generated"))
        XCTAssertTrue(trace.receipt.whatItMayAffect.contains("future routing"))
        XCTAssertTrue(trace.receipt.whatItMayAffect.contains("goal routing"))
        XCTAssertTrue(trace.receipt.whatWasNotUsed.contains("original goal guess"))
        XCTAssertTrue(trace.receipt.whyApprovalWasNeeded?.contains("explicit approval") == true)
        XCTAssertEqual(trace.receipt.undoAvailability, .requiresConfirmation)
        XCTAssertTrue(trace.futureUse.canAffectFutureRouting)
        XCTAssertEqual(trace.futureUse.preferredGoalID, "goal-guitar")
        XCTAssertTrue(trace.futureUse.routingNotes.contains("Future routing should prefer the corrected goal."))
        XCTAssertTrue(trace.receiptKinds.contains(.captureExtracted))
        XCTAssertTrue(trace.receiptKinds.contains(.captureMatchedGoal))
        XCTAssertTrue(trace.receiptKinds.contains(.captureSavedAsFutureContext))
        XCTAssertTrue(trace.receiptKinds.contains(.captureSavedAsProof))
        XCTAssertTrue(trace.receiptKinds.contains(.captureCorrectionApplied))
        XCTAssertTrue(trace.receiptKinds.contains(.captureReplayGenerated))
    }

    func testWrongTimeCorrectionChangesFutureRoutingWithoutCalendarMutation() {
        let service = DefaultSmartAttachmentService()
        let result = service.route(
            SmartAttachmentInput(rawText: "Schedule proposal tomorrow"),
            candidates: [],
            maxCandidateCount: 5
        )

        let trace = result.captureRuntimeReplayTrace(
            timestamp: "2026-05-23T10:20:00Z",
            correction: CaptureRuntimeCorrectionInput(
                kind: .wrongTime,
                timeLabel: "next Tuesday 8 AM",
                note: "The time was wrong."
            )
        )

        XCTAssertEqual(trace.runtimeUseStatus, .active)
        XCTAssertEqual(trace.receipt.kind, .captureCorrectionApplied)
        XCTAssertEqual(trace.receipt.whereItWent, "Corrected time")
        XCTAssertTrue(trace.receipt.whatWasNotUsed.contains("original time guess"))
        XCTAssertTrue(trace.receipt.whatItMayAffect.contains("time routing"))
        XCTAssertEqual(trace.futureUse.preferredTimeLabel, "next Tuesday 8 AM")
        XCTAssertTrue(trace.futureUse.canAffectFutureRouting)
        XCTAssertTrue(trace.futureUse.routingNotes.contains("Future routing should prefer the corrected time."))
        XCTAssertTrue(trace.receiptKinds.contains(.captureProposedForTime))
        XCTAssertTrue(trace.receiptKinds.contains(.captureCorrectionApplied))
        XCTAssertTrue(trace.receiptKinds.contains(.captureReplayGenerated))
    }

    func testWrongActivityCorrectionUpdatesFutureUseAndKeepsReplayLocal() {
        let service = DefaultSmartAttachmentService()
        let result = service.route(
            SmartAttachmentInput(rawText: "ankle hurt after run"),
            candidates: [],
            maxCandidateCount: 5
        )

        let trace = result.captureRuntimeReplayTrace(
            timestamp: "2026-05-23T10:25:00Z",
            correction: CaptureRuntimeCorrectionInput(
                kind: .wrongActivity,
                activityLabel: "recovery",
                note: "The activity was classified too narrowly."
            )
        )

        XCTAssertEqual(trace.receipt.kind, .captureCorrectionApplied)
        XCTAssertEqual(trace.futureUse.preferredActivityLabel, "recovery")
        XCTAssertTrue(trace.futureUse.canAffectFutureRouting)
        XCTAssertTrue(trace.receipt.whatItMayAffect.contains("activity routing"))
        XCTAssertTrue(trace.receipt.whatWasNotUsed.contains("original activity guess"))
        XCTAssertTrue(trace.receipt.privacyRedactions.contains("raw capture text"))
        XCTAssertTrue(trace.receiptKinds.contains(.captureSavedAsFutureContext))
        XCTAssertTrue(trace.receiptKinds.contains(.captureCorrectionApplied))
        XCTAssertTrue(trace.receiptKinds.contains(.captureReplayGenerated))
    }

    func testDoNotUseForPlanningAndSaveOnlyAsNotePauseFutureUse() {
        let service = DefaultSmartAttachmentService()
        let result = service.route(
            SmartAttachmentInput(rawText: "worked late again"),
            candidates: [],
            maxCandidateCount: 5
        )

        let planningPause = result.captureRuntimeReplayTrace(
            timestamp: "2026-05-23T10:30:00Z",
            correction: CaptureRuntimeCorrectionInput(
                kind: .doNotUseForPlanning,
                note: "Do not use for planning."
            )
        )
        let noteOnly = result.captureRuntimeReplayTrace(
            timestamp: "2026-05-23T10:31:00Z",
            correction: CaptureRuntimeCorrectionInput(
                kind: .saveOnlyAsNote,
                note: "Save only as note."
            )
        )

        XCTAssertEqual(planningPause.runtimeUseStatus, .paused)
        XCTAssertEqual(planningPause.receipt.whereItWent, "Planning paused")
        XCTAssertTrue(planningPause.receipt.whatWasNotUsed.contains("planning"))
        XCTAssertTrue(planningPause.receipt.whatItMayAffect.contains("planning"))
        XCTAssertFalse(planningPause.futureUse.canAffectFutureRouting)
        XCTAssertTrue(planningPause.receiptKinds.contains(.captureRuntimeUsePaused))
        XCTAssertTrue(planningPause.receiptKinds.contains(.captureCorrectionApplied))
        XCTAssertEqual(noteOnly.runtimeUseStatus, .noteOnly)
        XCTAssertEqual(noteOnly.receipt.whereItWent, "Note only")
        XCTAssertTrue(noteOnly.receipt.whatWasNotUsed.contains("planning"))
        XCTAssertTrue(noteOnly.receipt.whatItMayAffect.contains("planning"))
        XCTAssertFalse(noteOnly.futureUse.canAffectFutureRouting)
        XCTAssertTrue(noteOnly.receiptKinds.contains(.captureRuntimeUsePaused))
        XCTAssertTrue(noteOnly.receiptKinds.contains(.captureCorrectionApplied))
    }

    func testAttachToDifferentGoalAndDeleteContextChangeFutureRouting() {
        let service = DefaultSmartAttachmentService()
        let result = service.route(
            SmartAttachmentInput(rawText: "Finished launch proof for Music Goal"),
            candidates: [
                SmartAttachmentDestinationCandidate(
                    id: "goal-launch",
                    label: "Launch Goal",
                    destinationKind: .existingGoal,
                    supportedRouteTypes: [.goal, .proofItem]
                )
            ],
            maxCandidateCount: 5
        )

        let attachDifferentGoal = result.captureRuntimeReplayTrace(
            timestamp: "2026-05-23T10:35:00Z",
            correction: CaptureRuntimeCorrectionInput(
                kind: .attachToDifferentGoal,
                goalID: "goal-launch",
                note: "Attach this to the launch goal instead."
            )
        )
        let deleteContext = result.captureRuntimeReplayTrace(
            timestamp: "2026-05-23T10:36:00Z",
            correction: CaptureRuntimeCorrectionInput(
                kind: .deleteContext,
                note: "Delete this context."
            )
        )

        XCTAssertEqual(attachDifferentGoal.futureUse.preferredGoalID, "goal-launch")
        XCTAssertTrue(attachDifferentGoal.receipt.whatWasNotUsed.contains("original goal guess"))
        XCTAssertTrue(attachDifferentGoal.receipt.whatItMayAffect.contains("goal routing"))
        XCTAssertEqual(attachDifferentGoal.receipt.whereItWent, "Corrected goal")
        XCTAssertEqual(attachDifferentGoal.receipt.undoAvailability, .requiresConfirmation)
        XCTAssertTrue(attachDifferentGoal.receiptKinds.contains(.captureCorrectionApplied))

        XCTAssertEqual(deleteContext.runtimeUseStatus, .deleted)
        XCTAssertFalse(deleteContext.futureUse.canAffectFutureRouting)
        XCTAssertTrue(deleteContext.receipt.whatWasNotUsed.contains("future runtime use"))
        XCTAssertTrue(deleteContext.receipt.whatItMayAffect.contains("future use"))
        XCTAssertEqual(deleteContext.receipt.whereItWent, "Context deleted")
        XCTAssertEqual(deleteContext.receipt.undoAvailability, .availableLocal)
        XCTAssertTrue(deleteContext.receiptKinds.contains(.captureRuntimeUsePaused))
        XCTAssertTrue(deleteContext.receiptKinds.contains(.captureCorrectionApplied))
    }
}
