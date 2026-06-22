import XCTest
@testable import Ambitions

final class TimeFieldMutationCoordinatorTests: XCTestCase {
    private let now = ISO8601DateFormatter().date(from: "2027-02-19T12:20:00Z")!

    func testPlaceStepRunsRuntimeMutationUpdatesTimeTodayProofAnnouncementHapticAndUndo() throws {
        let state = PreviewTimeScenarios.seeded
        let mark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .freeTimeQuality })

        let result = try TimeFieldMutationCoordinator().perform(
            .placeStep,
            in: state,
            selectedMark: mark,
            now: now
        )

        XCTAssertEqual(result.command.kind, .placeStepInTime)
        XCTAssertEqual(result.timeMutation.actionKind, .placeStep)
        XCTAssertTrue(result.runtimeMutation.hasCompleteActionFlowProof)
        XCTAssertTrue(result.timeMutation.todayRecompute.recomputedToday)
        XCTAssertTrue(result.timeMutation.todayRecompute.hasTimeCauseProof)
        XCTAssertEqual(result.runtimeMutation.stageMutation.visibleUserFacingChange, "Step placed")
        XCTAssertEqual(result.runtimeMutation.stageMutation.hapticIntent, "confirmation")
        XCTAssertEqual(result.runtimeMutation.stageMutation.undoAvailability.label, "Undo")
        XCTAssertTrue(result.runtimeMutation.stageMutation.accessibilityAnnouncement.message.contains("Step placed"))
        XCTAssertEqual(result.updatedTimeState.lifeSuite.field.renderState, .receiptAttached)
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
}
