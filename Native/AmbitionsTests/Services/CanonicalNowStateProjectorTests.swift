import XCTest
@testable import Ambitions

final class CanonicalNowStateProjectorTests: XCTestCase {
    func testEmptyProjectionIsConservativeUsefulAndCalendarFree() {
        let now = Date(timeIntervalSince1970: 1_776_000_000)
        let state = CanonicalNowStateProjector().project(
            input: NowStateProjectionInput(now: now)
        )

        XCTAssertEqual(state.todayPosture, .lowData)
        XCTAssertEqual(state.activeContextLens, .all)
        XCTAssertEqual(state.lensSource, .systemDefault)
        XCTAssertFalse(state.isManualLensOverrideActive)
        XCTAssertEqual(state.schedulePressure.level, .none)
        XCTAssertEqual(state.priorityPressure.overallPressure, .none)
        XCTAssertEqual(state.deadlinePressure.level, .none)
        XCTAssertEqual(state.recoveryState, .stable)
        XCTAssertEqual(state.captureUrgency.level, .none)
        XCTAssertNil(state.bestNextAction)
        XCTAssertEqual(state.nextActionConfidence, .low)
        XCTAssertEqual(state.privacy, .standard)
        XCTAssertTrue(state.localOnly)
        XCTAssertTrue(state.availableContextLenses.contains(.work))
        XCTAssertTrue(state.availableContextLenses.contains(.all))
    }

    func testProjectionDerivesBestNextActionPressureAndActivePassiveGoalState() {
        let now = Date(timeIntervalSince1970: 1_776_000_000)
        let soon = DomainTimestamp.string(from: now.addingTimeInterval(2 * 60 * 60))
        let later = DomainTimestamp.string(from: now.addingTimeInterval(5 * 24 * 60 * 60))
        let workGoal = makeGoal(
            id: "goal-work",
            title: "Create spreadsheet",
            state: .active,
            mode: .project,
            domain: .career,
            dueAt: soon,
            stepID: "step-work",
            stepTitle: "Build spreadsheet and send it to Kaylee",
            stepDueAt: soon
        )
        let passiveGoal = makeGoal(
            id: "goal-piano",
            title: "Learn piano",
            state: .paused,
            mode: .learning,
            domain: .creativity,
            dueAt: nil,
            stepID: "step-piano",
            stepTitle: "Practice left-hand pattern",
            stepDueAt: later
        )
        let capture = Capture(
            id: "capture-1",
            createdAt: DomainTimestamp.string(from: now),
            updatedAt: DomainTimestamp.string(from: now),
            rawText: "Order printer ink",
            sourceType: .todayQuickCapture,
            status: .actionable,
            linkedGoalID: nil
        )
        let ledger = EventLedgerEntry(
            id: "ledger-priority",
            kind: .priorityChanged,
            occurredAt: DomainTimestamp.string(from: now),
            source: .recommendation,
            goalID: workGoal.id,
            title: "Priority changed",
            summary: "Work deadline is urgent.",
            trust: EventLedgerTrustMetadata(confidence: 0.9)
        )
        let explanation = RecommendationExplanation(
            id: "explanation-work",
            type: .whyPrioritized,
            title: "Why this now",
            summary: "The spreadsheet has a near deadline.",
            recommendationTitle: "Build spreadsheet and send it to Kaylee",
            confidence: .high,
            evidence: [
                RecommendationExplanationEvidence.fromEventLedgerEntry(ledger),
                RecommendationExplanationEvidence(id: "deadline", category: .deadline, title: "Due soon")
            ],
            lastUpdatedAt: DomainTimestamp.string(from: now),
            source: .today,
            relations: RecommendationExplanationRelations(goalIDs: [workGoal.id], eventLedgerEntryIDs: [ledger.id]),
            metadata: ["stepID": "step-work"]
        )

        let state = CanonicalNowStateProjector().project(
            input: NowStateProjectionInput(
                now: now,
                activeContextLens: .work,
                lensSource: .manual,
                isManualLensOverrideActive: true,
                goals: [passiveGoal, workGoal],
                captures: [capture],
                eventLedgerEntries: [ledger],
                recommendationExplanations: [explanation]
            )
        )

        XCTAssertEqual(state.activeContextLens, .work)
        XCTAssertEqual(state.lensSource, .manual)
        XCTAssertTrue(state.isManualLensOverrideActive)
        XCTAssertEqual(state.bestNextAction?.reference?.goalID, workGoal.id)
        XCTAssertEqual(state.bestNextAction?.reference?.stepID, "step-work")
        XCTAssertEqual(state.bestNextAction?.contextLens, .work)
        XCTAssertEqual(state.bestNextAction?.commitmentKind, .oneTime)
        XCTAssertEqual(state.nextActionExplanationID, explanation.id)
        XCTAssertEqual(state.deadlinePressure.level, .high)
        XCTAssertNotEqual(state.schedulePressure.level, .none)
        XCTAssertNotEqual(state.priorityPressure.overallPressure, .none)
        XCTAssertEqual(state.priorityPressure.deadline, state.deadlinePressure.level)
        XCTAssertEqual(state.captureUrgency.itemCount, 1)
        XCTAssertEqual(state.activeGoalPressure.map(\.goalID), [workGoal.id])
        XCTAssertEqual(state.passiveGoalPressure.map(\.goalID), [passiveGoal.id])
        XCTAssertTrue(state.recommendationExplanationIDs.contains(explanation.id))
        XCTAssertTrue(state.eventLedgerEntryIDs.contains(ledger.id))
        XCTAssertTrue(state.evidenceSummaries.contains { $0.explanationID == explanation.id && $0.eventLedgerEntryID == ledger.id })
    }

    func testUrgentOutsideLensSummaryKeepsCrossContextCommitmentsVisible() {
        let now = Date(timeIntervalSince1970: 1_776_000_000)
        let soon = DomainTimestamp.string(from: now.addingTimeInterval(60 * 60))
        let personalGoal = makeGoal(
            id: "goal-personal",
            title: "Personal admin",
            state: .active,
            mode: .project,
            domain: .personalGrowth,
            dueAt: nil,
            stepID: "step-personal",
            stepTitle: "Clean up notes",
            stepDueAt: nil
        )
        let workGoal = makeGoal(
            id: "goal-work",
            title: "Send client sheet",
            state: .active,
            mode: .project,
            domain: .career,
            dueAt: soon,
            stepID: "step-work",
            stepTitle: "Send the client sheet",
            stepDueAt: soon
        )

        let state = CanonicalNowStateProjector().project(
            input: NowStateProjectionInput(
                now: now,
                activeContextLens: .personal,
                lensSource: .manual,
                goals: [personalGoal, workGoal]
            )
        )

        XCTAssertEqual(state.urgentOutsideLens.level, .high)
        XCTAssertEqual(state.urgentOutsideLens.count, 1)
        XCTAssertEqual(state.urgentOutsideLens.items.first?.lens, .work)
        XCTAssertEqual(state.urgentOutsideLens.items.first?.reference?.goalID, workGoal.id)
    }

    func testBlockedProjectionRepresentsRecoveryAndWaitingWithoutCalendarPermission() {
        let now = Date(timeIntervalSince1970: 1_776_000_000)
        let goal = makeGoal(
            id: "goal-blocked",
            title: "Fix blocked plan",
            state: .active,
            mode: .project,
            domain: .home,
            dueAt: nil,
            stepID: "step-blocked",
            stepTitle: "Wait for confirmation",
            stepDueAt: nil,
            stepState: .blocked
        )
        let waiting = Capture(
            id: "capture-waiting",
            createdAt: DomainTimestamp.string(from: now),
            updatedAt: DomainTimestamp.string(from: now),
            rawText: "Waiting on reply from Kaylee",
            sourceType: .todayQuickCapture,
            status: .delegated,
            linkedGoalID: nil
        )

        let state = CanonicalNowStateProjector().project(
            input: NowStateProjectionInput(
                now: now,
                activeContextLens: .admin,
                lensSource: .systemDefault,
                goals: [goal],
                captures: [waiting]
            )
        )

        XCTAssertEqual(state.recoveryState, .needsRecovery)
        XCTAssertEqual(state.blockersWaiting.blockedCount, 1)
        XCTAssertEqual(state.blockersWaiting.waitingCount, 1)
        XCTAssertEqual(state.captureUrgency.itemCount, 1)
        XCTAssertEqual(state.privacy, .standard)
        XCTAssertFalse(state.isManualLensOverrideActive)
    }

    func testProjectionIsStableAcrossEquivalentInputOrder() {
        let now = Date(timeIntervalSince1970: 1_776_000_000)
        let timing = "2026-04-22T12:00:00Z"
        let goalA = makeGoal(
            id: "goal-a",
            title: "Goal A",
            state: .active,
            mode: .project,
            domain: .career,
            dueAt: timing,
            stepID: "step-a",
            stepTitle: "Step A",
            stepDueAt: timing
        )
        let goalB = makeGoal(
            id: "goal-b",
            title: "Goal B",
            state: .active,
            mode: .project,
            domain: .career,
            dueAt: timing,
            stepID: "step-b",
            stepTitle: "Step B",
            stepDueAt: timing
        )
        let ledgerA = EventLedgerEntry(
            id: "ledger-a",
            kind: .priorityChanged,
            occurredAt: DomainTimestamp.string(from: now),
            source: .recommendation,
            goalID: goalA.id,
            title: "Priority changed A",
            summary: "Goal A priority shifted.",
            trust: EventLedgerTrustMetadata(confidence: 0.9)
        )
        let ledgerB = EventLedgerEntry(
            id: "ledger-b",
            kind: .priorityChanged,
            occurredAt: DomainTimestamp.string(from: now),
            source: .recommendation,
            goalID: goalB.id,
            title: "Priority changed B",
            summary: "Goal B priority shifted.",
            trust: EventLedgerTrustMetadata(confidence: 0.9)
        )
        let explanationA = RecommendationExplanation(
            id: "explanation-a",
            type: .whyPrioritized,
            title: "Why A",
            summary: "Goal A is the deterministic winner.",
            recommendationTitle: "Work on Goal A",
            evidence: [RecommendationExplanationEvidence.fromEventLedgerEntry(ledgerA)],
            lastUpdatedAt: DomainTimestamp.string(from: now),
            source: .today,
            relations: RecommendationExplanationRelations(goalIDs: [goalA.id], eventLedgerEntryIDs: [ledgerA.id]),
            metadata: ["stepID": "step-a"]
        )
        let explanationB = RecommendationExplanation(
            id: "explanation-b",
            type: .whyPrioritized,
            title: "Why B",
            summary: "Goal B is also visible.",
            recommendationTitle: "Work on Goal B",
            evidence: [RecommendationExplanationEvidence.fromEventLedgerEntry(ledgerB)],
            lastUpdatedAt: DomainTimestamp.string(from: now),
            source: .today,
            relations: RecommendationExplanationRelations(goalIDs: [goalB.id], eventLedgerEntryIDs: [ledgerB.id]),
            metadata: ["stepID": "step-b"]
        )

        let projector = CanonicalNowStateProjector()
        let projectedOne = projector.project(
            input: NowStateProjectionInput(
                now: now,
                activeContextLens: .work,
                lensSource: .manual,
                goals: [goalB, goalA],
                eventLedgerEntries: [ledgerB, ledgerA],
                recommendationExplanations: [explanationB, explanationA]
            )
        )
        let projectedTwo = projector.project(
            input: NowStateProjectionInput(
                now: now,
                activeContextLens: .work,
                lensSource: .manual,
                goals: [goalA, goalB],
                eventLedgerEntries: [ledgerA, ledgerB],
                recommendationExplanations: [explanationA, explanationB]
            )
        )

        XCTAssertEqual(projectedOne.bestNextAction, projectedTwo.bestNextAction)
        XCTAssertEqual(projectedOne.bestNextAction?.reference?.goalID, goalA.id)
        XCTAssertEqual(projectedOne.bestNextAction?.reference?.stepID, "step-a")
        XCTAssertEqual(projectedOne.nextActionExplanationID, explanationA.id)
        XCTAssertEqual(projectedOne.eventLedgerEntryIDs, [ledgerA.id, ledgerB.id])
        XCTAssertEqual(projectedOne.recommendationExplanationIDs, [explanationA.id, explanationB.id])
        XCTAssertEqual(projectedOne.evidenceSummaries, projectedTwo.evidenceSummaries)
        XCTAssertEqual(projectedOne.activeGoalPressure.map(\.id), [
            "now.goal-pressure.active_goal.goal-a",
            "now.goal-pressure.active_goal.goal-b"
        ])
        XCTAssertEqual(projectedOne.activeGoalPressure, projectedTwo.activeGoalPressure)
        XCTAssertEqual(projectedOne.passiveGoalPressure, projectedTwo.passiveGoalPressure)
    }

    func testPlanningNextStepSelectorBreaksEqualScoreTiesByTimingKeyGoalIDAndStepID() {
        let now = Date(timeIntervalSince1970: 1_776_000_000)
        let selector = PlanningNextStepSelector()

        let timingKeyGoal = makeGoal(
            id: "goal-timing-key",
            title: "Timing key goal",
            state: .active,
            mode: .project,
            domain: .career,
            dueAt: "2026-04-22T12:00:00Z",
            stepID: "step-timing-key",
            stepTitle: "Timing key step",
            stepDueAt: nil,
            stepTargetBy: "2026-04-22"
        )
        let timingKeyRunnerUp = makeGoal(
            id: "goal-timing-runner-up",
            title: "Timing key runner up",
            state: .active,
            mode: .project,
            domain: .career,
            dueAt: "2026-04-22T12:00:00Z",
            stepID: "step-timing-runner-up",
            stepTitle: "Timing key runner up",
            stepDueAt: "2026-04-22T12:00:00Z"
        )
        let timingRanked = selector.rankedSelections(
            goals: [timingKeyRunnerUp, timingKeyGoal],
            now: now
        )

        XCTAssertEqual(timingRanked.first?.goal.id, timingKeyGoal.id)
        XCTAssertEqual(timingRanked.first?.step.id, "step-timing-key")

        let goalTieWinner = makeGoal(
            id: "goal-a",
            title: "Goal A",
            state: .active,
            mode: .project,
            domain: .career,
            dueAt: "2026-04-22T12:00:00Z",
            stepID: "step-a",
            stepTitle: "Goal A step",
            stepDueAt: "2026-04-22T12:00:00Z"
        )
        let goalTieRunnerUp = makeGoal(
            id: "goal-b",
            title: "Goal B",
            state: .active,
            mode: .project,
            domain: .career,
            dueAt: "2026-04-22T12:00:00Z",
            stepID: "step-b",
            stepTitle: "Goal B step",
            stepDueAt: "2026-04-22T12:00:00Z"
        )
        let goalRanked = selector.rankedSelections(
            goals: [goalTieRunnerUp, goalTieWinner],
            now: now
        )

        XCTAssertEqual(goalRanked.first?.goal.id, goalTieWinner.id)
        XCTAssertEqual(goalRanked.first?.step.id, "step-a")

        let stepTieGoal = makeGoalWithSteps(
            id: "goal-step-tie",
            title: "Goal step tie",
            dueAt: "2026-04-22T12:00:00Z",
            steps: [
                ("step-b", "Step B"),
                ("step-a", "Step A")
            ]
        )
        let stepRanked = selector.rankedSelections(
            goals: [stepTieGoal],
            now: now
        )

        XCTAssertEqual(stepRanked.first?.goal.id, stepTieGoal.id)
        XCTAssertEqual(stepRanked.first?.step.id, "step-a")
    }
}

private extension CanonicalNowStateProjectorTests {
    func makeGoal(
        id: String,
        title: String,
        state: GoalLifecycleState,
        mode: GoalMode,
        domain: LifeDomainKey,
        dueAt: String?,
        stepID: String,
        stepTitle: String,
        stepDueAt: String?,
        stepTargetBy: String? = nil,
        stepState: StepLifecycleState = .planned
    ) -> Goal {
        let actor = GoalActor.localOwner
        let timing = GoalTiming(
            tempo: dueAt == nil ? .untimed : .deadlineBased,
            timingType: dueAt == nil ? .logWhenDone : .dueAt,
            startsOn: nil,
            dueAt: dueAt,
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: nil,
            progressReviewCadenceDays: 7
        )
        let stepTiming = GoalTiming(
            tempo: stepDueAt == nil && stepTargetBy == nil ? .untimed : .deadlineBased,
            timingType: stepDueAt != nil ? .dueAt : (stepTargetBy != nil ? .targetBy : .logWhenDone),
            startsOn: nil,
            dueAt: stepDueAt,
            targetBy: stepTargetBy,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: nil,
            progressReviewCadenceDays: 7
        )
        let strategy = PlanningStrategy(
            strategyKind: .sequential,
            allowParallelSteps: false,
            maxActiveSteps: 1,
            preferredSectionOrder: [.activeSteps],
            defaultStepType: .actionUnit,
            autoGenerateReviewSection: false,
            preferShortSteps: true,
            revisitCadenceDays: 7
        )
        let progress = ProgressStrategy(
            metricKind: .stepCompletion,
            rollupMethod: .ratio,
            targetStepCount: 1,
            targetEvidenceCount: nil,
            targetMinutes: nil,
            supportsUntimedProgress: true,
            countsChildGoals: false,
            countsSupportGoals: false
        )
        let step = Step(
            id: stepID,
            sectionID: "section-\(id)",
            title: stepTitle,
            summary: nil,
            type: .actionUnit,
            state: stepState,
            owner: actor,
            timing: stepTiming,
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: true,
            successSignals: ["Done"],
            actionability: StepActionability(
                action: stepTitle,
                completionDefinition: "Done",
                evidenceOfCompletion: ["Done"],
                fallbackMicroStep: "Open the first pass.",
                contextRequirements: []
            )
        )
        let section = PlanSection(
            id: "section-\(id)",
            goalID: id,
            title: "Active steps",
            summary: nil,
            kind: .activeSteps,
            orderIndex: 0,
            steps: [step]
        )
        let lint = PlanLintResult(
            goalID: id,
            planVersion: 1,
            isValid: true,
            issueCount: 0,
            issues: []
        )
        let plan = GoalPlan(
            id: "plan-\(id)",
            goalID: id,
            version: 1,
            generatedAt: "2026-04-24T12:00:00Z",
            summary: nil,
            strategy: strategy,
            sections: [section],
            assumptions: [],
            lint: lint
        )
        return Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: id,
            revision: 1,
            createdAt: "2026-04-24T12:00:00Z",
            updatedAt: "2026-04-24T12:00:00Z",
            state: state,
            title: title,
            summary: nil,
            mode: mode,
            relationshipKind: .independent,
            actor: actor,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: [],
            timing: timing,
            planningStrategy: strategy,
            progressStrategy: progress,
            plan: plan,
            lifeGraph: LifeGraphContext(domains: [LifeDomainAssignment(domain: domain)])
        )
    }

    func makeGoalWithSteps(
        id: String,
        title: String,
        dueAt: String,
        steps: [(id: String, title: String)]
    ) -> Goal {
        let actor = GoalActor.localOwner
        let timing = GoalTiming(
            tempo: .deadlineBased,
            timingType: .dueAt,
            startsOn: nil,
            dueAt: dueAt,
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: nil,
            progressReviewCadenceDays: 7
        )
        let strategy = PlanningStrategy(
            strategyKind: .sequential,
            allowParallelSteps: false,
            maxActiveSteps: 1,
            preferredSectionOrder: [.activeSteps],
            defaultStepType: .actionUnit,
            autoGenerateReviewSection: false,
            preferShortSteps: true,
            revisitCadenceDays: 7
        )
        let progress = ProgressStrategy(
            metricKind: .stepCompletion,
            rollupMethod: .ratio,
            targetStepCount: 1,
            targetEvidenceCount: nil,
            targetMinutes: nil,
            supportsUntimedProgress: true,
            countsChildGoals: false,
            countsSupportGoals: false
        )
        let sectionSteps = steps.map { stepDefinition in
            Step(
                id: stepDefinition.id,
                sectionID: "section-\(id)",
                title: stepDefinition.title,
                summary: nil,
                type: .actionUnit,
                state: .planned,
                owner: actor,
                timing: timing,
                dependencyStepIDs: [],
                isOptional: false,
                isRepeatable: false,
                evidenceRequired: true,
                successSignals: ["Done"],
                actionability: StepActionability(
                    action: stepDefinition.title,
                    completionDefinition: "Done",
                    evidenceOfCompletion: ["Done"],
                    fallbackMicroStep: "Open the first pass.",
                    contextRequirements: []
                )
            )
        }
        let section = PlanSection(
            id: "section-\(id)",
            goalID: id,
            title: "Active steps",
            summary: nil,
            kind: .activeSteps,
            orderIndex: 0,
            steps: sectionSteps
        )
        let plan = GoalPlan(
            id: "plan-\(id)",
            goalID: id,
            version: 1,
            generatedAt: "2026-04-24T12:00:00Z",
            summary: nil,
            strategy: strategy,
            sections: [section],
            assumptions: [],
            lint: PlanLintResult(goalID: id, planVersion: 1, isValid: true, issueCount: 0, issues: [])
        )
        return Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: id,
            revision: 1,
            createdAt: "2026-04-24T12:00:00Z",
            updatedAt: "2026-04-24T12:00:00Z",
            state: .active,
            title: title,
            summary: nil,
            mode: .project,
            relationshipKind: .independent,
            actor: actor,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: [],
            timing: timing,
            planningStrategy: strategy,
            progressStrategy: progress,
            plan: plan,
            lifeGraph: LifeGraphContext(domains: [LifeDomainAssignment(domain: .career)])
        )
    }
}
