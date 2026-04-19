import XCTest
@testable import Ambitions

final class LearningAnticipationServiceTests: XCTestCase {
    func testSparseHistoryFallsBackWithoutStrongFitClaims() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T12:00:00Z"))
        let goal = makeGoal(id: "goal-sparse", domain: .career, dueAt: "2026-05-01T12:00:00Z")
        let service = LearningAnticipationService()

        let snapshot = service.buildSnapshot(
            goals: [goal],
            evidence: [
                ProgressEvidence(
                    id: "evidence-1",
                    goalID: goal.id,
                    stepID: "step-goal-sparse",
                    evidenceKind: .stepCompleted,
                    source: .manual,
                    capturedAt: "2026-04-20T09:00:00Z",
                    progressDelta: 0.2,
                    confidenceDelta: 0.05,
                    minutesInvested: 25,
                    note: "One completion only"
                )
            ],
            feedback: [],
            now: now
        )

        let summary = try XCTUnwrap(snapshot.goalSummaries[goal.id])
        XCTAssertEqual(summary.historicalFit.confidence, .low)
        XCTAssertNil(summary.focusWindowPattern.preferredWindow)
        XCTAssertNil(summary.energyFitPattern.preferredSessionLength)
        XCTAssertTrue(summary.historicalFit.summary.localizedCaseInsensitiveContains("limited"))
    }

    func testObservedCompletionAndFrictionPatternsProduceConservativeWhyNowExplanation() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T09:30:00Z"))
        let goal = makeGoal(id: "goal-fit", domain: .health, dueAt: "2026-04-28T12:00:00Z")
        let service = LearningAnticipationService()

        let evidence = [
            makeEvidence(id: "e1", goalID: goal.id, capturedAt: "2026-04-18T09:00:00Z", minutes: 20),
            makeEvidence(id: "e2", goalID: goal.id, capturedAt: "2026-04-19T09:20:00Z", minutes: 25),
            makeEvidence(id: "e3", goalID: goal.id, capturedAt: "2026-04-20T09:10:00Z", minutes: 30)
        ]
        let feedback: [GoalFeedbackEvent] = [
            .skipped(base: makeBase(id: "f1", stepID: "step-goal-fit", at: "2026-04-18T20:30:00Z"), reasonCode: .notNow),
            .delayed(base: makeBase(id: "f2", stepID: "step-goal-fit", at: "2026-04-19T21:00:00Z"), timingAdjustment: .laterToday, date: nil)
        ]

        let snapshot = service.buildSnapshot(goals: [goal], evidence: evidence, feedback: feedback, now: now)
        let summary = try XCTUnwrap(snapshot.goalSummaries[goal.id])
        let step = try XCTUnwrap(goal.plan?.sections.first?.steps.first)
        let insight = service.learnedStepInsight(goal: goal, step: step, snapshot: snapshot, now: now)

        XCTAssertEqual(summary.focusWindowPattern.preferredWindow, .morning)
        XCTAssertEqual(summary.energyFitPattern.preferredSessionLength, .short)
        XCTAssertEqual(summary.historicalFit.confidence, .high)
        XCTAssertGreaterThan(insight.fitScore, 0.7)
        XCTAssertTrue(insight.whyNow.conciseReason.localizedCaseInsensitiveContains("completion fit"))
        XCTAssertEqual(insight.whyNow.reasons.count, 2)
    }

    func testUnderrepresentedGoalAndTimelineRiskRemainEvidenceBased() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T12:00:00Z"))
        let health = makeGoal(id: "goal-health", domain: .health, dueAt: "2026-04-24T12:00:00Z")
        let career = makeGoal(id: "goal-career", domain: .career, dueAt: "2026-05-10T12:00:00Z")
        let service = LearningAnticipationService()

        let evidence = [
            makeEvidence(id: "career-1", goalID: career.id, capturedAt: "2026-04-18T09:00:00Z", minutes: 25),
            makeEvidence(id: "career-2", goalID: career.id, capturedAt: "2026-04-19T09:00:00Z", minutes: 30),
            makeEvidence(id: "career-3", goalID: career.id, capturedAt: "2026-04-20T09:00:00Z", minutes: 20)
        ]
        let feedback: [GoalFeedbackEvent] = [
            .delayed(base: makeBase(id: "health-delay-1", stepID: "step-goal-health", at: "2026-04-18T18:00:00Z"), timingAdjustment: .laterToday, date: nil),
            .delayed(base: makeBase(id: "health-delay-2", stepID: "step-goal-health", at: "2026-04-19T18:30:00Z"), timingAdjustment: .laterThisWeek, date: nil),
            .skipped(base: makeBase(id: "health-skip-1", stepID: "step-goal-health", at: "2026-04-20T19:00:00Z"), reasonCode: .avoidance)
        ]

        let snapshot = service.buildSnapshot(goals: [health, career], evidence: evidence, feedback: feedback, now: now)
        let healthSummary = try XCTUnwrap(snapshot.goalSummaries[health.id])
        let underrepresented = try XCTUnwrap(snapshot.underrepresentedGoalSignals.first(where: { $0.goalID == health.id }))

        XCTAssertGreaterThan(healthSummary.timelineRisk.riskScore, 0.6)
        XCTAssertEqual(healthSummary.timelineRisk.confidence, .high)
        XCTAssertEqual(underrepresented.domain, .health)
        XCTAssertTrue(underrepresented.summary.localizedCaseInsensitiveContains("underrepresented"))
    }

    func testSharedLifeContextCanDriveWhyNowWithoutInventingASecondPlanner() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T09:00:00Z"))
        let goal = makeGoal(
            id: "goal-shared-care",
            domain: .home,
            dueAt: "2026-04-22T12:00:00Z",
            sharedLife: SharedLifeContext(
                participants: [
                    SharedLifeParticipant(id: "partner", displayName: "Alex", relationshipKind: .partner, roleLabel: "Partner"),
                    SharedLifeParticipant(id: "child", displayName: "Maya", relationshipKind: .child, roleLabel: "Child")
                ],
                responsibilities: [
                    SharedResponsibility(id: "pickup", title: "School pickup", kind: .care, participantID: "child"),
                    SharedResponsibility(id: "appointment", title: "Dentist prep", kind: .appointment, participantID: "child", coordination: SharedCoordinationContext(kind: .appointment, title: "Dentist prep", summary: "Needs prep", preparationNote: "Bring forms"))
                ],
                householdName: "Home",
                careSummary: "Care support is active."
            )
        )
        let service = LearningAnticipationService()

        let snapshot = service.buildSnapshot(
            goals: [goal],
            evidence: [],
            feedback: [],
            now: now
        )
        let step = try XCTUnwrap(goal.plan?.sections.first?.steps.first)
        let insight = service.learnedStepInsight(goal: goal, step: step, snapshot: snapshot, now: now)

        XCTAssertTrue(insight.whyNow.conciseReason.localizedCaseInsensitiveContains("shared responsibilities"))
        XCTAssertTrue(insight.whyNow.reasons.contains(where: { $0.localizedCaseInsensitiveContains("coordination") || $0.localizedCaseInsensitiveContains("care") }))
    }
}

private extension LearningAnticipationServiceTests {
    func makeGoal(id: String, domain: LifeDomainKey, dueAt: String, sharedLife: SharedLifeContext? = nil) -> Goal {
        let actor = GoalActor(actorID: "self", displayName: "You", ownership: .self, roleLabel: "Primary owner", isPrimary: true)
        let timing = GoalTiming(tempo: .deadlineBased, timingType: .dueAt, startsOn: nil, dueAt: dueAt, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: 7)
        let strategy = PlanningStrategy(strategyKind: .sequential, allowParallelSteps: false, maxActiveSteps: 3, preferredSectionOrder: [.activeSteps], defaultStepType: .actionUnit, autoGenerateReviewSection: false, preferShortSteps: true, revisitCadenceDays: 7)
        let progress = ProgressStrategy(metricKind: .stepCompletion, rollupMethod: .ratio, targetStepCount: nil, targetEvidenceCount: nil, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        let step = Step(id: "step-\(id)", sectionID: "section-\(id)", title: "Work \(id)", summary: "Do the next visible pass.", type: .actionUnit, state: .planned, owner: actor, timing: timing, dependencyStepIDs: [], isOptional: false, isRepeatable: false, evidenceRequired: true, successSignals: ["Done"], actionability: StepActionability(action: "Do it", completionDefinition: "Done", evidenceOfCompletion: ["Done"], fallbackMicroStep: "Start", contextRequirements: []))
        let plan = GoalPlan(id: "plan-\(id)", goalID: id, version: goalEnginePlanVersion, generatedAt: "2026-04-15T12:00:00Z", summary: nil, strategy: strategy, sections: [PlanSection(id: "section-\(id)", goalID: id, title: "Active", summary: nil, kind: .activeSteps, orderIndex: 0, steps: [step])], assumptions: [], lint: PlanLintResult(goalID: id, planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: []))
        let lifeGraph = LifeGraphContext(domains: [LifeDomainAssignment(domain: domain, priority: 1)], roles: [], path: nil, stages: [], prerequisites: [], milestones: [], sharedLife: sharedLife)
        return Goal(schemaVersion: goalEngineSchemaVersion, id: id, revision: 1, createdAt: "2026-04-15T12:00:00Z", updatedAt: "2026-04-15T12:00:00Z", state: .active, title: id, summary: nil, mode: .project, relationshipKind: .independent, actor: actor, parentGoalID: nil, childGoalIDs: [], supportGoalIDs: [], tags: [], timing: timing, planningStrategy: strategy, progressStrategy: progress, plan: plan, lifeGraph: lifeGraph)
    }

    func makeEvidence(id: String, goalID: String, capturedAt: String, minutes: Int) -> ProgressEvidence {
        ProgressEvidence(
            id: id,
            goalID: goalID,
            stepID: "step-\(goalID)",
            evidenceKind: .stepCompleted,
            source: .manual,
            capturedAt: capturedAt,
            progressDelta: 0.2,
            confidenceDelta: 0.06,
            minutesInvested: minutes,
            note: nil
        )
    }

    func makeBase(id: String, stepID: String, at occurredAt: String) -> GoalFeedbackEventBase {
        GoalFeedbackEventBase(id: id, stepID: stepID, occurredAt: occurredAt, note: nil)
    }
}
