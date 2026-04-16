import XCTest
@testable import Ambitions

final class GoalEnginePlannerTests: XCTestCase {
    func testTimedAchievementPlannerParity() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.plannerFixture(id: "timed-achievement-goal"))
        guard case let .plan(_, plan, lint) = fixture.result else {
            return XCTFail("Expected full plan.")
        }

        XCTAssertTrue(plan.sections.contains(where: { $0.title == "Milestones" }))
        XCTAssertTrue(plan.sections.contains(where: { $0.title == "Workstreams" }))
        XCTAssertTrue(plan.sections.flatMap(\.steps).contains(where: { $0.timing.timingType == .targetBy }))
        XCTAssertTrue(plan.sections.flatMap(\.steps).allSatisfy { !$0.actionability.evidenceOfCompletion.isEmpty })
        XCTAssertTrue(lint.issues.allSatisfy { $0.code != .missingStepEvidence })
    }

    func testLearningPlannerUsesGentleUntimedStructure() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.plannerFixture(id: "untimed-learning-goal"))
        guard case let .plan(_, plan, _) = fixture.result else {
            return XCTFail("Expected full plan.")
        }

        XCTAssertTrue(plan.sections.contains(where: { $0.title == "Skill Map" }))
        XCTAssertTrue(plan.sections.contains(where: { $0.title == "Practice Sessions" }))
        XCTAssertTrue(plan.sections.contains(where: { $0.title == "Checkpoints" }))
        XCTAssertTrue(plan.sections.flatMap(\.steps).allSatisfy { $0.timing.timingType != .dueAt })
    }

    func testExplorationPlannerStaysQuestionAndExperimentDriven() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.plannerFixture(id: "exploration-goal-with-ambiguity"))
        guard case let .plan(_, plan, _) = fixture.result else {
            return XCTFail("Expected full plan.")
        }

        XCTAssertEqual(plan.sections.map(\.title), ["Key Questions", "Experiments", "Reflections"])
    }

    func testMaintenancePlannerIncludesMinimumVersion() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.plannerFixture(id: "maintenance-goal"))
        guard case let .plan(_, plan, _) = fixture.result else {
            return XCTFail("Expected full plan.")
        }

        XCTAssertEqual(plan.sections.map(\.title), ["Cue", "Routine", "Minimum Version", "Recovery Logic"])
        XCTAssertTrue(plan.sections.flatMap(\.steps).contains(where: { $0.timing.timingType == .repeatWithinWindow }))
    }

    func testRecoveryPlannerStartsWithStabilization() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.plannerFixture(id: "recovery-goal"))
        let plan: GoalPlan
        switch fixture.result {
        case let .plan(_, extractedPlan, _):
            plan = extractedPlan
        case let .starterPlan(_, extractedPlan, _, _):
            plan = extractedPlan
        default:
            return XCTFail("Expected recovery-oriented plan.")
        }

        XCTAssertEqual(plan.sections.first?.title, "Stabilization First")
        XCTAssertTrue(plan.sections.flatMap(\.steps).allSatisfy { $0.timing.timingType != .dueAt })
    }

    func testDelegatedSupportPlannerPreservesNonPunitiveTone() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.plannerFixture(id: "delegated-child-support-goal"))
        guard case let .plan(_, plan, lint) = fixture.result else {
            return XCTFail("Expected full plan.")
        }

        XCTAssertTrue(plan.sections.contains(where: { $0.title == "Support Actions" }))
        XCTAssertTrue(plan.sections.contains(where: { $0.title == "Observation Prompts" }))
        XCTAssertTrue(plan.sections.contains(where: { $0.title == "Milestone Signs" }))
        XCTAssertFalse(lint.issues.contains(where: { $0.code == .wrongSupportTone }))
    }

    func testStarterPlanCarriesAssumptionsWhenClarityIsMissing() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.plannerFixture(id: "vague-safe-starter-plan"))
        guard case let .starterPlan(_, plan, _, assumptions) = fixture.result else {
            return XCTFail("Expected starter plan.")
        }

        XCTAssertFalse(assumptions.isEmpty)
        XCTAssertTrue(plan.sections.contains(where: { $0.title == "Starter Focus" }))
    }

    func testBlockedPlanningSurfacesReclarificationState() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.plannerFixture(id: "blocked-planning-case"))
        guard case let .blocked(_, blockers, clarification) = fixture.result else {
            return XCTFail("Expected blocked planner result.")
        }

        XCTAssertFalse(blockers.isEmpty)
        XCTAssertTrue(clarification?.missingFields.contains(where: { $0.blocksPlanning }) == true)
    }

    func testVagueRewriteAndLintCases() {
        let draft = GoalDraft(
            schemaVersion: goalEngineSchemaVersion,
            source: .aiSuggested,
            title: "Learn product analytics",
            summary: nil,
            mode: .learning,
            relationshipKind: .independent,
            actor: GoalActor(actorID: "self", displayName: "You", ownership: .self, roleLabel: "Primary owner", isPrimary: true),
            parentGoalID: nil,
            tags: ["learning_path"],
            timing: GoalTiming(tempo: .untimed, timingType: .logWhenDone, startsOn: nil, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: 7),
            planningStrategy: PlanningStrategy(strategyKind: .adaptive, allowParallelSteps: true, maxActiveSteps: 4, preferredSectionOrder: [.overview, .activeSteps, .review], defaultStepType: .learningCheckpoint, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 7),
            progressStrategy: ProgressStrategy(metricKind: .evidenceCount, rollupMethod: .weightedRatio, targetStepCount: 3, targetEvidenceCount: 3, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        )

        let vagueStep = Step(
            id: "step-1",
            sectionID: "section-1",
            title: "Continue with analytics",
            summary: nil,
            type: .learningCheckpoint,
            state: .planned,
            owner: draft.actor,
            timing: GoalTiming(tempo: .untimed, timingType: .suggestedNext, startsOn: nil, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: GoalEngineFixtures.fixedNow, repeatEveryDays: nil, progressReviewCadenceDays: 7),
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: true,
            successSignals: [],
            actionability: StepActionability(action: "Continue with analytics", completionDefinition: "Make progress on analytics", evidenceOfCompletion: [], fallbackMicroStep: "Work on analytics", contextRequirements: [])
        )

        let rewritten = GoalEngineStepRewriter().rewrite(step: vagueStep, goal: draft)
        XCTAssertFalse(GoalEngineStepRewriter().isVague(step: rewritten))

        let plan = GoalPlan(id: "plan-1", goalID: "goal-1", version: goalEnginePlanVersion, generatedAt: GoalEngineFixtures.fixedNow, summary: nil, strategy: draft.planningStrategy, sections: [
            PlanSection(id: "section-1", goalID: "goal-1", title: "Overview", summary: nil, kind: .overview, orderIndex: 0, steps: [
                Step(
                    id: rewritten.id,
                    sectionID: rewritten.sectionID,
                    title: rewritten.title,
                    summary: rewritten.summary,
                    type: rewritten.type,
                    state: rewritten.state,
                    owner: rewritten.owner,
                    timing: rewritten.timing,
                    dependencyStepIDs: rewritten.dependencyStepIDs,
                    isOptional: rewritten.isOptional,
                    isRepeatable: rewritten.isRepeatable,
                    evidenceRequired: rewritten.evidenceRequired,
                    successSignals: rewritten.successSignals,
                    actionability: StepActionability(action: rewritten.actionability.action, completionDefinition: rewritten.actionability.completionDefinition, evidenceOfCompletion: [], fallbackMicroStep: rewritten.actionability.fallbackMicroStep, contextRequirements: rewritten.actionability.contextRequirements)
                )
            ])
        ], assumptions: [], lint: PlanLintResult(goalID: "goal-1", planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: []))

        let lint = GoalEnginePlanLinter().lint(plan: plan, goal: draft)
        XCTAssertTrue(lint.issues.contains(where: { $0.code == .missingStepEvidence }))
    }
}
