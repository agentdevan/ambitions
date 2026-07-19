import XCTest
@testable import Ambitions

final class CanonicalNowStateModelsTests: XCTestCase {
    func testContextLensTaxonomyCoversBatch67Foundation() {
        XCTAssertEqual(
            Set(NowContextLens.allCases),
            [.work, .personal, .freeTime, .admin, .creative, .recovery, .deepFocus, .all]
        )
    }

    func testLensSourceTaxonomyCoversManualAndFutureInferenceSources() {
        XCTAssertEqual(
            Set(NowContextLensSource.allCases),
            [.manual, .schedule, .calendar, .domain, .deadline, .recovery, .systemDefault]
        )
    }

    func testPriorityRealityCarriesRequiredPressureDimensions() {
        let priority = NowPriorityRealitySummary(
            overallPressure: .high,
            importance: .high,
            urgency: .elevated,
            deadline: .high,
            consequence: .high,
            effort: .moderate,
            contextFit: .elevated,
            goalRelationship: .high,
            userPreference: .low,
            capacity: .moderate,
            recoveryState: .watch,
            summary: "Deadline-bound work is pressing on available capacity."
        )

        XCTAssertEqual(priority.importance, .high)
        XCTAssertEqual(priority.urgency, .elevated)
        XCTAssertEqual(priority.deadline, .high)
        XCTAssertEqual(priority.consequence, .high)
        XCTAssertEqual(priority.effort, .moderate)
        XCTAssertEqual(priority.contextFit, .elevated)
        XCTAssertEqual(priority.goalRelationship, .high)
        XCTAssertEqual(priority.userPreference, .low)
        XCTAssertEqual(priority.capacity, .moderate)
        XCTAssertEqual(priority.recoveryState, .watch)
    }

    func testNowStateRepresentsActionsPressuresReferencesAndPrivacy() {
        let explanationID = "explanation-1"
        let ledgerID = "ledger-1"
        let currentAction = NowAction(
            id: "current-action",
            kind: .focus,
            state: .active,
            title: "Create spreadsheet",
            subtitle: "Send it to Kaylee",
            contextLens: .work,
            commitmentKind: .oneTime,
            reference: NowActionReference(goalID: "goal-1", stepID: "step-1"),
            explanationID: explanationID,
            eventLedgerEntryIDs: [ledgerID]
        )
        let activeGoal = NowGoalPressureSummary(
            id: "active-goal",
            kind: .activeGoal,
            level: .high,
            goalID: "goal-1",
            title: "Launch work deliverable",
            summary: "A deadline-bound deliverable needs attention.",
            nextAction: currentAction,
            explanationID: explanationID,
            eventLedgerEntryIDs: [ledgerID]
        )
        let passiveGoal = NowGoalPressureSummary(
            id: "passive-goal",
            kind: .passiveGoal,
            level: .low,
            goalID: "goal-2",
            title: "Learn piano",
            summary: "Passive progress is preserved without crowding urgent work."
        )
        let outsideLens = NowUrgentOutsideLensSummary(
            level: .high,
            summary: "One work item is urgent outside the personal lens.",
            items: [
                NowOutsideLensItem(
                    id: "outside-1",
                    title: "Send spreadsheet",
                    lens: .work,
                    pressure: .high,
                    reference: NowActionReference(goalID: "goal-1", stepID: "step-1")
                )
            ]
        )

        let state = CanonicalNowState(
            id: "now-test",
            generatedAt: "2026-04-24T12:00:00.000Z",
            activeContextLens: .personal,
            lensSource: .manual,
            isManualLensOverrideActive: true,
            todayPosture: .tight,
            currentAction: currentAction,
            bestNextAction: currentAction,
            nextActionConfidence: .high,
            nextActionExplanationID: explanationID,
            schedulePressure: NowPressureSummary(level: .moderate, itemCount: 2, summary: "Two dated items."),
            priorityPressure: NowPriorityRealitySummary(
                overallPressure: .high,
                importance: .high,
                urgency: .high,
                deadline: .high,
                consequence: .elevated,
                effort: .moderate,
                contextFit: .elevated,
                goalRelationship: .high,
                userPreference: .low,
                capacity: .moderate,
                recoveryState: .watch,
                summary: "Priority pressure exists."
            ),
            deadlinePressure: NowPressureSummary(level: .high, itemCount: 1, summary: "One hard deadline."),
            activeFocus: NowActionReference(goalID: "goal-1", stepID: "step-1"),
            captureUrgency: NowPressureSummary(level: .low, itemCount: 1, summary: "One capture needs routing."),
            blockersWaiting: NowBlockersWaitingSummary(blockedCount: 1, waitingCount: 1, summary: "Blocked and waiting items exist."),
            recoveryState: .watch,
            urgentOutsideLens: outsideLens,
            activeGoalPressure: [activeGoal],
            passiveGoalPressure: [passiveGoal],
            eventLedgerEntryIDs: [ledgerID],
            recommendationExplanationIDs: [explanationID],
            evidenceSummaries: [
                NowEvidenceSummary(
                    id: "evidence-1",
                    title: "Hard deadline",
                    summary: "Due soon.",
                    source: .today,
                    eventLedgerEntryID: ledgerID,
                    explanationID: explanationID
                )
            ],
            privacy: .standard,
            localOnly: true
        )

        XCTAssertEqual(state.schemaVersion, canonicalNowStateSchemaVersion)
        XCTAssertEqual(state.activeContextLens, .personal)
        XCTAssertEqual(state.lensSource, .manual)
        XCTAssertTrue(state.isManualLensOverrideActive)
        XCTAssertEqual(state.bestNextAction?.commitmentKind, .oneTime)
        XCTAssertEqual(state.schedulePressure.level, .moderate)
        XCTAssertEqual(state.deadlinePressure.level, .high)
        XCTAssertEqual(state.captureUrgency.level, .low)
        XCTAssertEqual(state.blockersWaiting.blockedCount, 1)
        XCTAssertEqual(state.blockersWaiting.waitingCount, 1)
        XCTAssertEqual(state.urgentOutsideLens.count, 1)
        XCTAssertEqual(state.activeGoalPressure.first?.kind, .activeGoal)
        XCTAssertEqual(state.passiveGoalPressure.first?.kind, .passiveGoal)
        XCTAssertEqual(state.nextActionExplanationID, explanationID)
        XCTAssertEqual(state.eventLedgerEntryIDs, [ledgerID])
        XCTAssertEqual(state.recommendationExplanationIDs, [explanationID])
        XCTAssertTrue(state.localOnly)
    }
}
