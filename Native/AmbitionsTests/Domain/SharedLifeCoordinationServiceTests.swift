import XCTest
@testable import Ambitions

final class SharedLifeCoordinationServiceTests: XCTestCase {
    func testBuildSnapshotSummarizesResponsibilitiesAndCoordinationSignals() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T09:00:00Z"))
        let goal = sampleGoal()
        let service = SharedLifeCoordinationService()

        let snapshot = service.buildSnapshot(
            goals: [goal],
            evidence: [
                ProgressEvidence(
                    id: "delegated-update",
                    goalID: goal.id,
                    stepID: "step-household",
                    evidenceKind: .delegatedUpdate,
                    source: .manual,
                    capturedAt: "2026-04-20T18:00:00Z",
                    progressDelta: 0.1,
                    confidenceDelta: 0.05,
                    minutesInvested: nil,
                    note: "Checked in"
                )
            ],
            feedback: [],
            now: now
        )

        let summary = try XCTUnwrap(snapshot.goalSummaries[goal.id])
        XCTAssertEqual(summary.responsibilitySummary.totalCount, 3)
        XCTAssertEqual(summary.responsibilitySummary.careCount, 1)
        XCTAssertFalse(summary.coordinationSignals.isEmpty)
        XCTAssertGreaterThan(summary.pressureScore, 0.4)
        XCTAssertTrue(snapshot.portfolioSummary.headline.localizedCaseInsensitiveContains("shared"))
    }

    func testBuildSnapshotUsesFeedbackToRaiseGentleSharedPressure() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T09:00:00Z"))
        let goal = sampleGoal()
        let service = SharedLifeCoordinationService()

        let snapshot = service.buildSnapshot(
            goals: [goal],
            evidence: [],
            feedback: [
                .delayed(
                    base: GoalFeedbackEventBase(id: "delay-1", stepID: "step-household", occurredAt: "2026-04-20T20:00:00Z", note: nil),
                    timingAdjustment: .laterToday,
                    date: nil
                ),
                .skipped(
                    base: GoalFeedbackEventBase(id: "skip-1", stepID: "step-household", occurredAt: "2026-04-21T08:00:00Z", note: nil),
                    reasonCode: .notNow
                )
            ],
            now: now
        )

        let summary = try XCTUnwrap(snapshot.goalSummaries[goal.id])
        XCTAssertGreaterThan(summary.pressureScore, 0.55)
        XCTAssertTrue(summary.reasons.contains(where: { $0.localizedCaseInsensitiveContains("shared") || $0.localizedCaseInsensitiveContains("care") }))
    }
}

private extension SharedLifeCoordinationServiceTests {
    func sampleGoal() -> Goal {
        let actor = GoalActor(actorID: "self", displayName: "You", ownership: .support, roleLabel: "Supporter", isPrimary: true)
        let timing = GoalTiming(
            tempo: .deadlineBased,
            timingType: .dueAt,
            startsOn: "2026-04-20T09:00:00Z",
            dueAt: "2026-04-21T18:00:00Z",
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: nil,
            progressReviewCadenceDays: 7
        )
        let strategy = PlanningStrategy(strategyKind: .supportive, allowParallelSteps: true, maxActiveSteps: 3, preferredSectionOrder: [.supportingWork, .activeSteps], defaultStepType: .supportAction, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 7)
        let progress = ProgressStrategy(metricKind: .evidenceCount, rollupMethod: .latest, targetStepCount: 3, targetEvidenceCount: 4, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: true, countsSupportGoals: true)
        let step = Step(id: "step-household", sectionID: "section-household", title: "Confirm pickup plan", summary: "Coordinate the household pickup.", type: .supportAction, state: .planned, owner: actor, timing: timing, dependencyStepIDs: [], isOptional: false, isRepeatable: false, evidenceRequired: true, successSignals: ["Plan confirmed"], actionability: StepActionability(action: "Confirm pickup", completionDefinition: "Pickup plan is confirmed", evidenceOfCompletion: ["Plan confirmed"], fallbackMicroStep: "Send one calm check-in text.", contextRequirements: []))
        let plan = GoalPlan(id: "plan-household", goalID: "goal-household", version: goalEnginePlanVersion, generatedAt: "2026-04-20T09:00:00Z", summary: nil, strategy: strategy, sections: [PlanSection(id: "section-household", goalID: "goal-household", title: "Support", summary: nil, kind: .supportingWork, orderIndex: 0, steps: [step])], assumptions: [], lint: PlanLintResult(goalID: "goal-household", planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: []))
        return Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: "goal-household",
            revision: 1,
            createdAt: "2026-04-20T09:00:00Z",
            updatedAt: "2026-04-20T09:00:00Z",
            state: .active,
            title: "Support school pickup",
            summary: "Keep the pickup plan calm and visible.",
            mode: .delegatedSupport,
            relationshipKind: .support,
            actor: actor,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: [],
            timing: timing,
            planningStrategy: strategy,
            progressStrategy: progress,
            plan: plan,
            lifeGraph: LifeGraphContext(
                domains: [LifeDomainAssignment(domain: .home)],
                roles: [LifeRole(kind: .supporting, title: "Partner support")],
                path: nil,
                stages: [],
                prerequisites: [],
                milestones: [],
                sharedLife: SharedLifeContext(
                    participants: [
                        SharedLifeParticipant(id: "partner", displayName: "Alex", relationshipKind: .partner, roleLabel: "Partner"),
                        SharedLifeParticipant(id: "child", displayName: "Maya", relationshipKind: .child, roleLabel: "Child")
                    ],
                    responsibilities: [
                        SharedResponsibility(id: "pickup", title: "School pickup", summary: "Make sure the handoff stays clear.", kind: .care, participantID: "child"),
                        SharedResponsibility(id: "supplies", title: "Buy art supplies", kind: .household, participantID: "partner"),
                        SharedResponsibility(id: "dentist", title: "Dentist prep", kind: .appointment, participantID: "child", coordination: SharedCoordinationContext(kind: .appointment, title: "Dentist prep", summary: "Bring forms", preparationNote: "Pack forms before noon"))
                    ]
                )
            )
        )
    }
}
