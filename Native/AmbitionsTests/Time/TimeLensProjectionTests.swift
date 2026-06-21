import XCTest
@testable import Ambitions

final class TimeLensProjectionTests: XCTestCase {
    func testRuntimeSnapshotProjectsThroughTimeLensIntoLifeShapeProjection() throws {
        let snapshot = runtimeSnapshot(openMinutes: 45, protectedMinutes: 30, blockedMinutes: 15)

        let projection = try TimeLens.project(snapshot)

        XCTAssertEqual(projection.currentDate, Date(timeIntervalSince1970: 1_803_039_600))
        XCTAssertEqual(projection.selectedHorizon, .day)
        XCTAssertFalse(projection.todayBuckets.isEmpty)
        XCTAssertTrue(projection.todayBuckets.allSatisfy { $0.derivation.isCompleteForVisibleMark })
        XCTAssertTrue(projection.todayBuckets.allSatisfy { $0.accessibilitySummary.isEmpty == false })
        XCTAssertEqual(projection.primaryAction?.title, "Place Step")
        XCTAssertTrue(projection.semanticSummary.contains("open window"))
        XCTAssertTrue(projection.todayBuckets.contains { $0.layer == .protected })
    }

    func testTimeLensRootProjectionCopyAvoidsForbiddenRootTerms() throws {
        let projection = try TimeLens.project(runtimeSnapshot(openMinutes: 30, protectedMinutes: 0, blockedMinutes: 0))
        let rootCopy = [
            projection.primaryCaption,
            projection.primaryAction?.title ?? "",
            projection.semanticSummary
        ].joined(separator: " ").lowercased()

        for forbidden in ["source", "receipt", "runtime", "debug", "dashboard", "next best", "begin focus"] {
            XCTAssertFalse(rootCopy.contains(forbidden), "Root Time copy leaked forbidden term: \(forbidden)")
        }
    }

    private func runtimeSnapshot(
        openMinutes: Int,
        protectedMinutes: Int,
        blockedMinutes: Int
    ) -> RuntimeSnapshot {
        let generatedAt = "2027-02-19T12:20:00Z"
        let nowAction = NowAction(
            id: "step.write-outline",
            kind: .focus,
            state: .ready,
            title: "Write outline",
            reference: NowActionReference(goalID: "goal.book", stepID: "step.write-outline", timeID: "time.open")
        )
        let nowState = CanonicalNowState(
            id: "now.time-lens",
            generatedAt: generatedAt,
            activeContextLens: .all,
            lensSource: .systemDefault,
            todayPosture: .open,
            bestNextAction: nowAction,
            nextActionConfidence: .high,
            schedulePressure: NowPressureSummary(level: .low, summary: "Time has breathing room."),
            priorityPressure: NowPriorityRealitySummary(overallPressure: .moderate, summary: "The outline matters today."),
            deadlinePressure: NowPressureSummary(level: .low, summary: "Deadline pressure is low."),
            captureUrgency: NowPressureSummary(level: .none, summary: "No captures need review."),
            blockersWaiting: NowBlockersWaitingSummary(summary: "No blockers or waiting items are visible."),
            recoveryState: .stable,
            urgentOutsideLens: NowUrgentOutsideLensSummary(level: .none, summary: "No urgent outside-lens items are visible.")
        )

        return RuntimeSnapshot(
            id: "snapshot.time-lens",
            generatedAt: generatedAt,
            nowState: nowState,
            recommendation: RuntimeRecommendation(
                id: "recommendation.time-lens",
                action: nowAction,
                title: "Start here",
                fitSummary: "Write outline fits the current local context.",
                requiresConfirmation: false,
                needsReview: false,
                proofReferenceIDs: ["proof.time-lens"]
            ),
            capacityShape: CapacityShape(
                openMinutes: openMinutes,
                protectedMinutes: protectedMinutes,
                blockedMinutes: blockedMinutes,
                flexibleMinutes: 0,
                scheduledAmbitionsMinutes: 0,
                calendarBusyMinutes: blockedMinutes,
                pressureLevel: .low,
                summary: "Time has breathing room."
            ),
            recoveryState: RecoveryState(state: .stable),
            proofLedger: ProofLedger(id: "proof.time-lens", generatedAt: generatedAt, eventLedgerEntryIDs: ["event.time-lens"]),
            privacyBoundary: PrivacyBoundary()
        )
    }
}
