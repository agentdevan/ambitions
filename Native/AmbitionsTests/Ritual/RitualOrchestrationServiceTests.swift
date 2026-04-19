import XCTest
@testable import Ambitions

final class RitualOrchestrationServiceTests: XCTestCase {
    func testMorningSetupUsesSharedNextStepAndOpenCaptureSignals() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T08:00:00Z"))
        let goal = makeGoal(goalID: "goal-morning", stepID: "step-morning", dueAt: "2026-04-21T16:00:00Z")
        let capture = Capture(
            id: "capture-1",
            createdAt: "2026-04-21T07:00:00Z",
            updatedAt: "2026-04-21T07:00:00Z",
            rawText: "Private capture text",
            sourceType: .todayQuickCapture,
            status: .seed,
            linkedGoalID: nil
        )

        let plan = RitualOrchestrationService().makePlan(
            input: RitualOrchestrationInput(
                goals: [goal],
                captures: [capture],
                evidence: [],
                feedback: [],
                now: now
            )
        )

        XCTAssertEqual(plan.activeRecommendation.kind, .morningSetup)
        XCTAssertEqual(plan.activeRecommendation.progressState, .ready)
        XCTAssertEqual(plan.activeRecommendation.primaryAction?.goalID, "goal-morning")
        XCTAssertEqual(plan.activeRecommendation.primaryAction?.stepID, "step-morning")
        XCTAssertEqual(plan.signalSummary.openCaptureCount, 1)
        XCTAssertTrue(plan.dayThesis.contains("one next move"))
    }

    func testMiddayResetUsesFrictionAndNoProgressForSmallerStepAction() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T13:00:00Z"))
        let goal = makeGoal(goalID: "goal-reset", stepID: "step-reset", dueAt: "2026-04-21T16:00:00Z")
        let feedback: [GoalFeedbackEvent] = [
            .delayed(
                base: GoalFeedbackEventBase(
                    id: "delay-1",
                    stepID: "step-reset",
                    occurredAt: "2026-04-21T10:00:00Z",
                    note: "Delayed from Today."
                ),
                timingAdjustment: .laterToday,
                date: nil
            )
        ]

        let plan = RitualOrchestrationService().makePlan(
            input: RitualOrchestrationInput(
                goals: [goal],
                captures: [],
                evidence: [],
                feedback: feedback,
                now: now
            )
        )

        XCTAssertEqual(plan.activeRecommendation.kind, .middayReset)
        XCTAssertEqual(plan.activeRecommendation.progressState, .needsReset)
        XCTAssertEqual(plan.activeRecommendation.primaryAction?.kind, .askForSmallerStep)
        XCTAssertEqual(plan.signalSummary.frictionTodayCount, 1)
    }

    func testEveningCloseUsesCompletionsAndFrictionForReflection() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T19:00:00Z"))
        let goal = makeGoal(goalID: "goal-close", stepID: "step-close", dueAt: "2026-04-22T16:00:00Z")
        let evidence = [
            ProgressEvidence(
                id: "evidence-1",
                goalID: "goal-close",
                stepID: "step-close",
                evidenceKind: .stepCompleted,
                source: .manual,
                capturedAt: "2026-04-21T17:00:00Z",
                progressDelta: 0.2,
                confidenceDelta: 0.1,
                minutesInvested: 25,
                note: "Private completion note"
            )
        ]

        let plan = RitualOrchestrationService().makePlan(
            input: RitualOrchestrationInput(
                goals: [goal],
                captures: [],
                evidence: evidence,
                feedback: [],
                now: now
            )
        )

        XCTAssertEqual(plan.activeRecommendation.kind, .eveningClose)
        XCTAssertEqual(plan.activeRecommendation.progressState, .complete)
        XCTAssertEqual(plan.activeRecommendation.primaryAction?.kind, .quickLog)
        XCTAssertEqual(plan.signalSummary.completedTodayCount, 1)
    }

    func testWeeklyResetWinsOnMondayMorningAndIsDeterministic() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-20T09:00:00Z"))
        let goals = [
            makeGoal(goalID: "goal-b", stepID: "step-b", dueAt: "2026-04-22T16:00:00Z"),
            makeGoal(goalID: "goal-a", stepID: "step-a", dueAt: "2026-04-21T16:00:00Z")
        ]
        let service = RitualOrchestrationService()
        let input = RitualOrchestrationInput(goals: goals, captures: [], evidence: [], feedback: [], now: now)

        let first = service.makePlan(input: input)
        let second = service.makePlan(input: input)

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.activeRecommendation.kind, .weeklyReset)
        XCTAssertEqual(first.activeRecommendation.primaryAction?.goalID, "goal-a")
        XCTAssertTrue(first.weekThesis.contains("2 active goals"))
    }

    func testEmptyStateDoesNotEmitGenericChecklistAction() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-20T08:00:00Z"))

        let plan = RitualOrchestrationService().makePlan(
            input: RitualOrchestrationInput(
                goals: [],
                captures: [],
                evidence: [],
                feedback: [],
                now: now
            )
        )

        XCTAssertEqual(plan.activeRecommendation.progressState, .unavailable)
        XCTAssertNil(plan.activeRecommendation.primaryAction)
        XCTAssertFalse(plan.activeRecommendation.body.localizedCaseInsensitiveContains("checklist"))
    }

    func testWeeklyResetCanSurfaceUnderrepresentedDomainPressureFromLearningSnapshot() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-20T09:00:00Z"))
        let goal = makeGoal(goalID: "goal-health", stepID: "step-health", dueAt: "2026-04-25T16:00:00Z")

        let plan = RitualOrchestrationService().makePlan(
            input: RitualOrchestrationInput(
                goals: [goal],
                captures: [],
                evidence: [],
                feedback: [],
                learningSnapshot: LearningAnticipationSnapshot(
                    goalSummaries: [
                        "goal-health": GoalLearningSummary(
                            goalID: "goal-health",
                            energyFitPattern: EnergyFitPattern(preferredSessionLength: nil, supportingEvidenceCount: 1, frictionEventCount: 0, confidence: .low, summary: "Observed history is still limited."),
                            focusWindowPattern: FocusWindowPattern(preferredWindow: nil, supportingEvidenceCount: 1, frictionEventCount: 0, confidence: .low, summary: "Observed history is still limited."),
                            historicalFit: HistoricalFitSignal(score: 0.42, confidence: .low, supportingEvidenceCount: 1, frictionEventCount: 0, summary: "Observed history is still limited."),
                            driftTriggers: [],
                            timelineRisk: TimelineRiskForecast(riskScore: 0.32, confidence: .medium, reasons: ["The path is still manageable."]),
                            whyNow: nil
                        )
                    ],
                    underrepresentedGoalSignals: [
                        UnderrepresentedGoalSignal(goalID: "goal-health", domain: .health, pressureScore: 0.78, summary: "Health work is underrepresented against the active portfolio.")
                    ]
                ),
                now: now
            )
        )

        XCTAssertTrue(plan.weekThesis.localizedCaseInsensitiveContains("underrepresented"))
    }
}

private extension RitualOrchestrationServiceTests {
    func makeGoal(goalID: String, stepID: String, dueAt: String) -> Goal {
        let actor = GoalActor(actorID: "self", displayName: "You", ownership: .self, roleLabel: "Primary owner", isPrimary: true)
        let timing = GoalTiming(tempo: .deadlineBased, timingType: .dueAt, startsOn: nil, dueAt: dueAt, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: 7)
        let strategy = PlanningStrategy(strategyKind: .sequential, allowParallelSteps: false, maxActiveSteps: 3, preferredSectionOrder: [.activeSteps], defaultStepType: .actionUnit, autoGenerateReviewSection: false, preferShortSteps: true, revisitCadenceDays: 7)
        let progress = ProgressStrategy(metricKind: .stepCompletion, rollupMethod: .ratio, targetStepCount: nil, targetEvidenceCount: nil, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        let step = Step(id: stepID, sectionID: "section-\(goalID)", title: "Private step title", summary: "Private step summary", type: .actionUnit, state: .planned, owner: actor, timing: timing, dependencyStepIDs: [], isOptional: false, isRepeatable: false, evidenceRequired: true, successSignals: ["Done"], actionability: StepActionability(action: "Do it", completionDefinition: "Done", evidenceOfCompletion: ["Done"], fallbackMicroStep: "Start", contextRequirements: []))
        let plan = GoalPlan(id: "plan-\(goalID)", goalID: goalID, version: goalEnginePlanVersion, generatedAt: "2026-04-20T08:00:00Z", summary: nil, strategy: strategy, sections: [PlanSection(id: "section-\(goalID)", goalID: goalID, title: "Active", summary: nil, kind: .activeSteps, orderIndex: 0, steps: [step])], assumptions: [], lint: PlanLintResult(goalID: goalID, planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: []))
        return Goal(schemaVersion: goalEngineSchemaVersion, id: goalID, revision: 1, createdAt: "2026-04-20T08:00:00Z", updatedAt: "2026-04-20T08:00:00Z", state: .active, title: "Private goal title", summary: "Private goal summary", mode: .project, relationshipKind: .independent, actor: actor, parentGoalID: nil, childGoalIDs: [], supportGoalIDs: [], tags: [], timing: timing, planningStrategy: strategy, progressStrategy: progress, plan: plan)
    }
}
