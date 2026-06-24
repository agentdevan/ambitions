import XCTest
@testable import Ambitions

final class TimeFieldMutationCoordinatorTests: XCTestCase {
    private let now = ISO8601DateFormatter().date(from: "2027-02-19T12:20:00Z")!

    func testPlaceStepRequiresRealEligibleStep() throws {
        let state = PreviewTimeScenarios.seeded
        let mark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .freeTimeQuality })

        XCTAssertThrowsError(
            try TimeFieldMutationCoordinator().perform(
                .placeStep,
                in: state,
                selectedMark: mark,
                now: now
            )
        ) { error in
            XCTAssertEqual(error as? TimeFieldMutationError, .missingEligibleStep)
        }
    }

    func testPlaceStepWithRealCandidateRunsRuntimeMutationUpdatesTimeTodayProofAnnouncementHapticAndUndo() throws {
        let state = PreviewTimeScenarios.seeded.withPlacementCandidate(realPlacementCandidate())
        let mark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .freeTimeQuality })

        let result = try TimeFieldMutationCoordinator().perform(
            .placeStep,
            in: state,
            selectedMark: mark,
            now: now
        )

        XCTAssertEqual(result.command.kind, .placeStepInTime)
        XCTAssertEqual(result.command.target.stepID, "step.real-visible")
        XCTAssertEqual(result.command.target.goalID, "goal.real-visible")
        XCTAssertEqual(result.command.payload.metadata["placementCandidateKind"], TimePlacementCandidateKind.goalLinked.rawValue)
        XCTAssertEqual(result.timeMutation.actionKind, .placeStep)
        XCTAssertTrue(result.runtimeMutation.hasCompleteActionFlowProof)
        XCTAssertTrue(result.timeMutation.todayRecompute.recomputedToday)
        XCTAssertTrue(result.timeMutation.todayRecompute.hasTimeCauseProof)
        XCTAssertEqual(result.runtimeMutation.stageMutation.visibleUserFacingChange, "Step placed")
        XCTAssertEqual(result.runtimeMutation.stageMutation.hapticIntent, "confirmation")
        XCTAssertEqual(result.runtimeMutation.stageMutation.undoAvailability.label, "Undo")
        XCTAssertEqual(result.runtimeMutation.stageMutation.proofArtifact.beforeSnapshot?.summary, result.timeMutation.beforeProjection.semanticSummary)
        XCTAssertEqual(result.runtimeMutation.stageMutation.proofArtifact.action?.commandID, result.command.id)
        XCTAssertEqual(result.runtimeMutation.stageMutation.proofArtifact.afterSnapshot?.summary, result.timeMutation.afterProjection.semanticSummary)
        XCTAssertEqual(result.runtimeMutation.stageMutation.receipt.proofArtifactID, result.runtimeMutation.stageMutation.proofArtifact.artifactID)
        XCTAssertEqual(result.runtimeMutation.stageMutation.undoAvailability.restoresSnapshot?.summary, result.timeMutation.beforeProjection.semanticSummary)
        XCTAssertTrue(result.runtimeMutation.stageMutation.typedMotionEvent.isTypedEvent)
        XCTAssertTrue(result.runtimeMutation.stageMutation.accessibilityAnnouncement.message.contains("Step placed"))
        XCTAssertEqual(result.updatedTimeState.lifeSuite.field.renderState, .receiptAttached)
        XCTAssertFalse(result.timeMutation.afterProjection.todayBuckets.compactMap(\.recommendedStepID).contains { $0.hasPrefix("step.command") })
        XCTAssertEqual(result.updatedTimeState.lifeSuite.field.receipt.ageLabel, result.runtimeMutation.stageMutation.proofArtifact.artifactID)
        XCTAssertNotEqual(
            result.updatedTimeState.lifeSuite.field.reading(for: .week).title,
            state.lifeSuite.field.reading(for: .week).title
        )

        let undo = TimeFieldMutationCoordinator().undo(result, now: now)
        XCTAssertEqual(
            undo.restoredTimeState.lifeSuite.field.reading(for: .week).title,
            state.lifeSuite.field.reading(for: .week).title
        )
        XCTAssertEqual(undo.visibleMutation.stageMutation.visibleUserFacingChange, "Undo applied")
        XCTAssertTrue(undo.visibleMutation.stageMutation.accessibilityAnnouncement.message.contains("Time and Today"))
        XCTAssertEqual(undo.visibleMutation.stageMutation.hapticIntent, "selection")
        XCTAssertTrue(undo.visibleMutation.stageMutation.isCanonComplete)
        XCTAssertEqual(undo.visibleMutation.stageMutation.proofArtifact.beforeSnapshot?.summary, result.timeMutation.afterProjection.semanticSummary)
        XCTAssertEqual(undo.visibleMutation.stageMutation.proofArtifact.afterSnapshot?.summary, result.timeMutation.beforeProjection.semanticSummary)
        XCTAssertFalse(undo.visibleMutation.stageMutation.undoAvailability.isAvailable)
        XCTAssertEqual(undo.visibleMutation.stageMutation.undoAvailability.unavailableReason, "This mutation already restored the prior Time shape.")
    }

    func testProtectWindowAndKeepClearCreateProtectedBoundaryAndTodayAvoidanceProof() throws {
        let state = PreviewTimeScenarios.seeded
        let protectedMark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .protectedTime })
        let openMark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .executionLanes })

        let protect = try TimeFieldMutationCoordinator().perform(
            .protectWindow,
            in: state,
            selectedMark: protectedMark,
            now: now
        )
        let protectedBucket = try XCTUnwrap(protect.timeMutation.afterProjection.todayBuckets.first { $0.layer == .protected })
        XCTAssertEqual(protectedBucket.protectedBoundary?.kind, .explicit)
        XCTAssertTrue(protect.timeMutation.todayRecompute.todayRecommendationAvoidsAffectedWindow)
        XCTAssertTrue(protect.updatedTimeState.lifeSuite.field.continuityDockItems.contains("Today recomputed"))

        let keepClear = try TimeFieldMutationCoordinator().perform(
            .keepClear,
            in: state,
            selectedMark: openMark,
            now: now
        )
        let clearBucket = try XCTUnwrap(keepClear.timeMutation.afterProjection.todayBuckets.first { $0.protectedBoundary?.kind == .keepClearCorrection })
        XCTAssertEqual(clearBucket.layer, .protected)
        XCTAssertEqual(keepClear.command.payload.metadata["correctionKind"], TimeMutationActionKind.keepClear.rawValue)
        XCTAssertTrue(keepClear.timeMutation.todayRecompute.todayRecommendationAvoidsAffectedWindow)
    }

    func testNotUsableCorrectionRemovesOpenCapacityThroughRuntimeMutation() throws {
        let state = PreviewTimeScenarios.seeded
        let mark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .freeTimeQuality })

        let result = try TimeFieldMutationCoordinator().perform(
            .notUsable,
            in: state,
            selectedMark: mark,
            now: now
        )

        XCTAssertEqual(result.command.kind, .correctTimeWindow)
        XCTAssertEqual(result.command.payload.metadata["correctionKind"], TimeMutationActionKind.notUsable.rawValue)
        XCTAssertEqual(result.timeMutation.actionKind, .notUsable)
        XCTAssertFalse(result.timeMutation.afterProjection.todayBuckets.contains { result.timeMutation.affectedBucketIDs.contains($0.id) })
        XCTAssertTrue(result.runtimeMutation.hasCompleteActionFlowProof)
        XCTAssertTrue(result.updatedTimeState.lifeSuite.field.segments.contains { $0.kind == .openTime })
    }

    func testAMB1171MakeTodayLighterRunsPressureMutationTodayProofAndUndo() throws {
        let state = PreviewTimeScenarios.seeded
        let pressureMark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .pressure })

        let result = try TimeFieldMutationCoordinator().perform(
            .makeTodayLighter,
            in: state,
            selectedMark: pressureMark,
            now: now
        )

        XCTAssertEqual(result.command.kind, .correctTimeWindow)
        XCTAssertEqual(result.command.payload.metadata["correctionKind"], TimeMutationActionKind.makeTodayLighter.rawValue)
        XCTAssertEqual(result.timeMutation.actionKind, .makeTodayLighter)
        XCTAssertEqual(result.runtimeMutation.stageMutation.visibleUserFacingChange, "Today made lighter")
        XCTAssertTrue(result.runtimeMutation.hasCompleteActionFlowProof)
        XCTAssertTrue(result.timeMutation.todayRecompute.recomputedToday)
        XCTAssertTrue(result.updatedTimeState.lifeSuite.field.segments.contains { $0.kind == .pressure && $0.valueLabel == "Light" })
        XCTAssertTrue(result.updatedTimeState.lifeSuite.field.continuityDockItems.contains("Later Today updated"))

        let undo = TimeFieldMutationCoordinator().undo(result, now: now)
        XCTAssertEqual(undo.visibleMutation.stageMutation.visibleUserFacingChange, "Undo applied")
        XCTAssertTrue(undo.visibleMutation.stageMutation.accessibilityAnnouncement.message.contains("Time and Today"))
    }

    func testAMB1173AddBufferRunsScheduleRoomMutationTodayProofAndUndo() throws {
        let state = PreviewTimeScenarios.seeded
        let bufferMark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .transitionFriction })

        let result = try TimeFieldMutationCoordinator().perform(
            .addBuffer,
            in: state,
            selectedMark: bufferMark,
            now: now
        )

        XCTAssertEqual(result.command.kind, .correctTimeWindow)
        XCTAssertEqual(result.command.payload.metadata["correctionKind"], TimeMutationActionKind.addBuffer.rawValue)
        XCTAssertEqual(result.timeMutation.actionKind, .addBuffer)
        XCTAssertEqual(result.runtimeMutation.stageMutation.visibleUserFacingChange, "Buffer added")
        XCTAssertTrue(result.runtimeMutation.hasCompleteActionFlowProof)
        XCTAssertTrue(result.timeMutation.todayRecompute.recomputedToday)
        XCTAssertTrue(result.updatedTimeState.lifeSuite.field.segments.contains { $0.kind == .buffer && $0.valueLabel == "Add room" })
        XCTAssertTrue(result.updatedTimeState.lifeSuite.field.continuityDockItems.contains("Current window updated"))
        XCTAssertFalse(result.visibleMutation.stageMutation.accessibilityAnnouncement.message.localizedCaseInsensitiveContains("wellness"))
        XCTAssertFalse(result.visibleMutation.stageMutation.accessibilityAnnouncement.message.localizedCaseInsensitiveContains("diagnosis"))

        let undo = TimeFieldMutationCoordinator().undo(result, now: now)
        XCTAssertEqual(undo.visibleMutation.stageMutation.visibleUserFacingChange, "Undo applied")
        XCTAssertTrue(undo.visibleMutation.stageMutation.accessibilityAnnouncement.message.contains("Time and Today"))
    }

    func testSCG008BStringOnlyProofAndMotionCannotSatisfyMutationContract() {
        let before = MutationSnapshotReference(id: "", surface: .today, summary: "before")
        let after = MutationSnapshotReference(id: "snapshot.after.invalid", surface: .today, summary: "after")
        let action = MutationActionReference(
            commandID: "command.invalid",
            commandKind: .completeAction,
            source: .today,
            targetObjectIDs: []
        )
        let proof = MutationProof(
            artifactID: "proof.string-only",
            label: "Proof saved",
            localOnly: true,
            beforeSnapshot: before,
            action: action,
            afterSnapshot: after
        )
        let receipt = MutationReceipt(
            receiptID: "receipt.string-only",
            saved: true,
            inspectionLabel: "Receipt",
            proofArtifactID: proof.artifactID,
            action: action
        )
        let mutation = StageMutation(
            runtimeMutationID: "runtime.invalid.string-only",
            beforeSnapshot: "before",
            afterSnapshot: "after",
            targetSurface: .today,
            affectedObjectIDs: ["step-1"],
            visibleUserFacingChange: "Step completed",
            typedMotionEvent: MutationMotionEvent(
                id: "stage.motion.string-only",
                kind: .stageAction,
                sourceMutationID: "",
                affectedObjectIDs: ["step-1"]
            ),
            accessibilityAnnouncement: MutationAccessibilityAnnouncement(message: "Step completed.", reasonIfSilent: nil),
            hapticIntent: "confirmation",
            undoAvailability: .unavailable(label: "Undo unavailable", reason: "Invalid fixture has no restore snapshot."),
            proofArtifact: proof,
            receipt: receipt,
            safeFallback: "Keep the previous visible state."
        )

        XCTAssertFalse(proof.isTypedAvailable)
        XCTAssertFalse(receipt.isTypedSaved)
        XCTAssertFalse(mutation.typedMotionEvent.isTypedEvent)
        XCTAssertFalse(mutation.isCanonComplete)
    }

    func testSCG008BUnavailableProofFallbackIsTypedButDoesNotClaimMutationComplete() {
        let before = MutationSnapshotReference(id: "snapshot.before.fallback", surface: .today, summary: "before")
        let action = MutationActionReference(
            commandID: "command.fallback",
            commandKind: .completeAction,
            source: .today,
            targetObjectIDs: ["step-1"]
        )

        let proof = MutationProof.unavailable(
            label: "Proof unavailable",
            localOnly: true,
            beforeSnapshot: before,
            action: action,
            fallbackReason: "Receipt storage was unavailable."
        )
        let receipt = MutationReceipt.unavailable(
            inspectionLabel: "Receipt unavailable",
            action: action,
            fallbackReason: "Receipt storage was unavailable."
        )

        XCTAssertTrue(proof.isTypedUnavailableFallback)
        XCTAssertTrue(receipt.isTypedUnavailableFallback)
        XCTAssertFalse(proof.isTypedAvailable)
        XCTAssertFalse(receipt.isTypedSaved)
    }

    private func realPlacementCandidate() -> TimePlacementCandidate {
        TimePlacementCandidate(
            id: "time.placement.goal.real-visible.step.real-visible",
            stepID: "step.real-visible",
            goalID: "goal.real-visible",
            title: "Draft the real proposal section",
            detail: "Goal-linked Step selected before placement.",
            durationMinutes: 30,
            sourceLabel: "Visible goal",
            kind: .goalLinked
        )
    }
}

private extension TimeSurfaceState {
    func withPlacementCandidate(_ candidate: TimePlacementCandidate) -> TimeSurfaceState {
        let field = LifeShapeFieldState(
            defaultHorizon: lifeSuite.field.defaultHorizon,
            capacityFit: lifeSuite.field.capacityFit,
            segments: lifeSuite.field.segments,
            semanticMarks: lifeSuite.field.semanticMarks,
            renderState: lifeSuite.field.renderState,
            readings: lifeSuite.field.readings,
            placementCandidate: candidate,
            placementUnavailableReason: "Placement is available for \(candidate.title).",
            calendarRows: lifeSuite.field.calendarRows,
            sourceState: lifeSuite.field.sourceState,
            reflowProposal: lifeSuite.field.reflowProposal,
            receipt: lifeSuite.field.receipt,
            continuityDockItems: lifeSuite.field.continuityDockItems
        )
        let suite = TimeLifeSuiteState(
            title: lifeSuite.title,
            subtitle: lifeSuite.subtitle,
            shapes: lifeSuite.shapes,
            field: field,
            drillDown: lifeSuite.drillDown,
            calendarBoundaryLabel: lifeSuite.calendarBoundaryLabel,
            manualFallbackLabel: lifeSuite.manualFallbackLabel,
            trustLabel: lifeSuite.trustLabel
        )
        return replacing(lifeSuite: suite)
    }
}
