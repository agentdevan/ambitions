import XCTest
@testable import Ambitions

final class TimeTodayCouplingTests: XCTestCase {
    func testPlaceStepUpdatesTimeAndTodayAndRuntimeRequiresCoupling() throws {
        let before = try LifeShapeEngine().project(LifeShapeStressScenarios.denseDayInput)
        let target = try XCTUnwrap(before.todayBuckets.first { $0.layer == .open })
        let command = timeCommand(kind: .placeStepInTime, timeID: target.id, stepID: "step.deep-work")

        let mutation = try TimeMutation.make(command: command, beforeProjection: before)
        let afterTarget = try XCTUnwrap(mutation.afterProjection.todayBuckets.first { $0.id == target.id })
        let runtime = PrivateLifeRuntime()

        XCTAssertEqual(mutation.actionKind, .placeStep)
        XCTAssertEqual(afterTarget.recommendedStepID, "step.deep-work")
        XCTAssertLessThan(afterTarget.end, target.end)
        XCTAssertTrue(mutation.todayRecompute.recomputedToday)
        XCTAssertTrue(mutation.todayRecompute.hasTimeCauseProof)
        XCTAssertEqual(mutation.todayRecompute.afterStartHereStepID, "step.deep-work")
        XCTAssertNil(runtime.mutation(
            for: command,
            beforeSnapshot: before.semanticSummary,
            afterSnapshot: mutation.afterProjection.semanticSummary,
            targetSurface: .time
        ))

        let runtimeMutation = runtime.mutation(
            for: command,
            beforeSnapshot: before.semanticSummary,
            afterSnapshot: mutation.afterProjection.semanticSummary,
            targetSurface: .time,
            timeMutation: mutation
        )

        XCTAssertNotNil(runtimeMutation)
        XCTAssertEqual(runtimeMutation?.stageMutation.visibleUserFacingChange, "Step placed")
        XCTAssertEqual(runtimeMutation?.timeMutation?.todayRecompute.afterStartHereStepID, "step.deep-work")
        XCTAssertTrue(runtimeMutation?.stageMutation.affectedObjectIDs.contains(target.id) == true)
    }

    func testProtectWindowUpdatesTimeAndTodayAvoidsAffectedWindow() throws {
        let before = try LifeShapeEngine().project(LifeShapeStressScenarios.calendarDeniedManualInput)
        let target = try XCTUnwrap(before.todayBuckets.first { $0.layer == .open })
        let command = timeCommand(kind: .protectTimeWindow, timeID: target.id, title: "School pickup")

        let mutation = try TimeMutation.make(command: command, beforeProjection: before)
        let afterTarget = try XCTUnwrap(mutation.afterProjection.todayBuckets.first { $0.id == target.id })

        XCTAssertEqual(afterTarget.layer, .protected)
        XCTAssertEqual(afterTarget.protectedBoundary?.title, "School pickup")
        XCTAssertTrue(mutation.todayRecompute.recomputedToday)
        XCTAssertTrue(mutation.todayRecompute.todayRecommendationAvoidsAffectedWindow)
        XCTAssertTrue(mutation.todayRecompute.afterAvoidedBucketIDs.contains(target.id))
        XCTAssertEqual(mutation.todayRecompute.actionKind, .protectWindow)
    }

    func testCorrectionsUpdateFutureFitAndTodayWhenRelevant() throws {
        let before = try LifeShapeEngine().project(LifeShapeStressScenarios.denseDayInput)
        let target = try XCTUnwrap(before.todayBuckets.first { $0.layer == .open })
        let placed = try TimeMutation.make(
            command: timeCommand(kind: .placeStepInTime, timeID: target.id, stepID: "step.needs-room"),
            beforeProjection: before
        )

        let needsMoreTime = try TimeMutation.make(
            command: timeCommand(
                kind: .correctTimeWindow,
                timeID: target.id,
                metadata: ["correctionKind": TimeMutationActionKind.needsMoreTime.rawValue]
            ),
            beforeProjection: placed.afterProjection
        )
        let notUsable = try TimeMutation.make(
            command: timeCommand(
                kind: .correctTimeWindow,
                timeID: target.id,
                metadata: ["correctionKind": TimeMutationActionKind.notUsable.rawValue]
            ),
            beforeProjection: before
        )
        let keepClear = try TimeMutation.make(
            command: timeCommand(
                kind: .correctTimeWindow,
                timeID: target.id,
                title: "Keep this clear",
                metadata: ["correctionKind": TimeMutationActionKind.keepClear.rawValue]
            ),
            beforeProjection: before
        )

        XCTAssertNil(needsMoreTime.afterProjection.todayBuckets.first { $0.id == target.id }?.recommendedStepID)
        XCTAssertNotEqual(needsMoreTime.todayRecompute.beforeStartHereStepID, needsMoreTime.todayRecompute.afterStartHereStepID)
        XCTAssertFalse(notUsable.afterProjection.todayBuckets.contains { $0.id == target.id })
        XCTAssertTrue(notUsable.todayRecompute.recomputedToday)
        XCTAssertEqual(keepClear.afterProjection.todayBuckets.first { $0.id == target.id }?.protectedBoundary?.kind, .keepClearCorrection)
        XCTAssertTrue(keepClear.todayRecompute.todayRecommendationAvoidsAffectedWindow)
    }

    private func timeCommand(
        kind: AmbitionsCommandKind,
        timeID: String,
        stepID: String? = nil,
        title: String = "Write outline",
        metadata: [String: String] = [:]
    ) -> AmbitionsCommand {
        AmbitionsCommand(
            id: "command.\(kind.rawValue).\(timeID)",
            kind: kind,
            source: .time,
            target: AmbitionsCommandTarget(goalID: "goal.book", timeID: timeID, stepID: stepID),
            payload: AmbitionsCommandPayload(title: title, metadata: metadata),
            createdAt: "2027-02-19T12:20:00Z"
        )
    }
}
