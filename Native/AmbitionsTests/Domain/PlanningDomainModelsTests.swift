import XCTest
@testable import Ambitions

final class PlanningDomainModelsTests: XCTestCase {
    func testGoalBlueprintUsesStableLocalFirstDefaults() {
        let blueprint = GoalBlueprint(title: "Ship native goal intake")

        XCTAssertEqual(blueprint.mode, .project)
        XCTAssertEqual(blueprint.relationshipKind, .independent)
        XCTAssertEqual(blueprint.actor, .localOwner)
        XCTAssertEqual(blueprint.pace, .untimed)
        XCTAssertEqual(blueprint.source, .manual)

        let draft = blueprint.makeDraft()
        XCTAssertEqual(draft.title, "Ship native goal intake")
        XCTAssertEqual(draft.mode, .project)
        XCTAssertEqual(draft.actor.ownership, .self)
        XCTAssertEqual(draft.timing.tempo, .untimed)
        XCTAssertEqual(draft.timing.timingType, .logWhenDone)
        XCTAssertEqual(draft.timing.progressReviewCadenceDays, 7)
    }

    func testPlanningPaceMapsDeterministicallyToExistingTimingContracts() {
        XCTAssertEqual(PlanningPace.untimed.goalTempo, .untimed)
        XCTAssertEqual(PlanningPace.untimed.defaultTimingType, .logWhenDone)

        XCTAssertEqual(PlanningPace.targeted.goalTempo, .targetWindow)
        XCTAssertEqual(PlanningPace.targeted.defaultTimingType, .targetBy)

        XCTAssertEqual(PlanningPace.deadline.goalTempo, .deadlineBased)
        XCTAssertEqual(PlanningPace.deadline.defaultTimingType, .dueAt)

        XCTAssertEqual(PlanningPace.ongoing.goalTempo, .ongoing)
        XCTAssertEqual(PlanningPace.ongoing.defaultTimingType, .repeatWithinWindow)

        XCTAssertEqual(PlanningPace(goalTempo: .untimed), .untimed)
        XCTAssertEqual(PlanningPace(goalTempo: .targetWindow), .targeted)
        XCTAssertEqual(PlanningPace(goalTempo: .deadlineBased), .deadline)
        XCTAssertEqual(PlanningPace(goalTempo: .ongoing), .ongoing)
    }

    func testPlanStepBuildsStableStepWithDefaultActionability() {
        let planStep = PlanStep(
            id: "step-blueprint-1",
            title: "Define draft persistence boundary",
            summary: "Document the smallest write path.",
            pace: .targeted,
            targetDate: "2026-04-21"
        )

        let step = planStep.makeStep(sectionID: "section-1")

        XCTAssertEqual(step.id, "step-blueprint-1")
        XCTAssertEqual(step.sectionID, "section-1")
        XCTAssertEqual(step.type, .actionUnit)
        XCTAssertEqual(step.state, .planned)
        XCTAssertEqual(step.owner, .localOwner)
        XCTAssertEqual(step.timing.tempo, .targetWindow)
        XCTAssertEqual(step.timing.timingType, .targetBy)
        XCTAssertEqual(step.timing.targetBy, "2026-04-21")
        XCTAssertTrue(step.successSignals.contains("Document the smallest write path."))
        XCTAssertEqual(step.actionability.completionDefinition, "Document the smallest write path.")
    }

    func testOngoingBlueprintAndPlanStepUseRepeatCadenceDefaults() {
        let blueprint = GoalBlueprint(
            title: "Weekly planning review",
            mode: .maintenance,
            pace: .ongoing
        )
        let draft = blueprint.makeDraft()

        XCTAssertEqual(draft.timing.tempo, .ongoing)
        XCTAssertEqual(draft.timing.timingType, .repeatWithinWindow)
        XCTAssertEqual(draft.timing.repeatEveryDays, 7)

        let planStep = PlanStep(
            id: "repeat-1",
            title: "Review this week's planning signals",
            type: .recurringRoutine,
            pace: .ongoing
        )
        let step = planStep.makeStep(sectionID: "cadence")

        XCTAssertEqual(step.timing.tempo, .ongoing)
        XCTAssertEqual(step.timing.repeatEveryDays, 7)
        XCTAssertTrue(step.isRepeatable)
    }

    func testPlanningEvaluationUsesStableCodableShape() throws {
        let evaluation = PlanningEvaluation(
            feasibilityScore: 0.81,
            feasibilityLevel: .comfortable,
            recommendationConfidence: .high,
            pressureLevel: .low,
            fragilityLevel: .low,
            effortPosture: .steady,
            reasons: ["No major fragility signals are present."]
        )

        let decoded = try PersistenceCoding.decode(PlanningEvaluation.self, from: PersistenceCoding.encode(evaluation))

        XCTAssertEqual(decoded, evaluation)
        XCTAssertEqual(decoded.schemaVersion, PlanningEvaluation.schemaVersion)
    }

    func testGoalBlueprintForwardsLifeGraphIntoDraft() {
        let blueprint = GoalBlueprint(
            title: "Become mission ready",
            mode: .project,
            lifeGraph: LifeGraphContext(
                domains: [LifeDomainAssignment(domain: .career)],
                roles: [LifeRole(kind: .aspirational, title: "Astronaut candidate")],
                path: LifePathDescriptor(kind: .careerTrack, title: "Astronaut path"),
                stages: [LifePathStage(id: "foundation", title: "Foundation", orderIndex: 0)],
                prerequisites: [LifePathPrerequisite(id: "application-needs-foundation", title: "Application needs foundation", kind: .stage, stageID: "application", requiredStageID: "foundation")],
                milestones: [LifeGraphMilestone(id: "screening", title: "Medical screening", summary: nil, targetDate: "2027-04-01", stageID: "foundation", dependencyIDs: [])]
            )
        )

        let draft = blueprint.makeDraft()

        XCTAssertEqual(draft.lifeGraph?.domains.map(\.domain), [.career])
        XCTAssertEqual(draft.lifeGraph?.roles.map(\.title), ["Astronaut candidate"])
        XCTAssertEqual(draft.lifeGraph?.path?.title, "Astronaut path")
        XCTAssertEqual(draft.lifeGraph?.stages.map(\.id), ["foundation"])
        XCTAssertEqual(draft.lifeGraph?.prerequisites.map(\.id), ["application-needs-foundation"])
        XCTAssertEqual(draft.lifeGraph?.milestones.map(\.id), ["screening"])
    }

    func testSharedLearnedFitScorerReordersEqualUrgencySelectionsWhenHistorySupportsOneGoal() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T09:30:00Z"))
        let strongFit = makeGoal(id: "goal-strong-fit", stepID: "step-strong-fit", dueAt: "2026-04-24T12:00:00Z")
        let weakFit = makeGoal(id: "goal-weak-fit", stepID: "step-weak-fit", dueAt: "2026-04-24T12:00:00Z")

        let evidence = [
            ProgressEvidence(id: "fit-1", goalID: strongFit.id, stepID: "step-strong-fit", evidenceKind: .stepCompleted, source: .manual, capturedAt: "2026-04-18T09:00:00Z", progressDelta: 0.2, confidenceDelta: 0.05, minutesInvested: 20, note: nil),
            ProgressEvidence(id: "fit-2", goalID: strongFit.id, stepID: "step-strong-fit", evidenceKind: .stepCompleted, source: .manual, capturedAt: "2026-04-19T09:10:00Z", progressDelta: 0.2, confidenceDelta: 0.05, minutesInvested: 25, note: nil),
            ProgressEvidence(id: "fit-3", goalID: strongFit.id, stepID: "step-strong-fit", evidenceKind: .stepCompleted, source: .manual, capturedAt: "2026-04-20T09:20:00Z", progressDelta: 0.2, confidenceDelta: 0.05, minutesInvested: 30, note: nil)
        ]
        let feedback: [GoalFeedbackEvent] = [
            .delayed(base: GoalFeedbackEventBase(id: "weak-1", stepID: "step-weak-fit", occurredAt: "2026-04-18T20:30:00Z", note: nil), timingAdjustment: .laterToday, date: nil),
            .skipped(base: GoalFeedbackEventBase(id: "weak-2", stepID: "step-weak-fit", occurredAt: "2026-04-19T20:45:00Z", note: nil), reasonCode: .notNow)
        ]

        let ranked = PlanningNextStepSelector().rankedSelections(
            goals: [weakFit, strongFit],
            evidence: evidence,
            feedback: feedback,
            now: now
        )

        XCTAssertEqual(ranked.first?.goal.id, "goal-strong-fit")
        XCTAssertGreaterThan(try XCTUnwrap(ranked.first?.candidate.learnedFitScore), try XCTUnwrap(ranked.last?.candidate.learnedFitScore))
    }

    func testEnergyFitSummaryAttachesWithoutChangingRecommendationOrder() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T09:30:00Z"))
        let soon = makeGoal(id: "goal-soon-energy", stepID: "step-soon-energy", dueAt: "2026-04-22T12:00:00Z")
        let later = makeGoal(id: "goal-later-energy", stepID: "step-later-energy", dueAt: "2026-05-01T12:00:00Z")
        let goals = [later, soon]
        let service = DefaultGoalEnergyFitService()
        let compiledPath = GoalCompiledPath.legacyFallback(from: GoalPathCompilerServiceTests().sampleUnderstanding())
        let canonical = service.evaluate(
            compiledPath: compiledPath,
            plannedSteps: soon.plan?.sections.flatMap(\.steps) ?? [],
            capacityContext: .assumedNeutral()
        )

        let baseline = PlanningNextStepSelector().rankedSelections(goals: goals, now: now)
        let withEnergy = PlanningNextStepSelector().rankedSelections(
            goals: goals,
            canonicalEnergyModelsByGoalID: [soon.id: canonical],
            now: now
        )

        XCTAssertEqual(withEnergy.map { "\($0.goal.id)|\($0.step.id)" }, baseline.map { "\($0.goal.id)|\($0.step.id)" })
        let canonicalSelection = try XCTUnwrap(withEnergy.first(where: { $0.goal.id == soon.id }))
        let canonicalStepEvaluation = try XCTUnwrap(canonical.evaluations.first(where: { $0.stepID == canonicalSelection.step.id }))
        XCTAssertEqual(canonicalSelection.candidate.energyFit?.source, .canonicalMetadata)
        XCTAssertEqual(canonicalSelection.candidate.energyFit?.score, canonicalStepEvaluation.score)
        XCTAssertEqual(canonicalSelection.candidate.energyFit?.reasonCodes, canonicalStepEvaluation.reasons.map(\.code).sorted { $0.rawValue < $1.rawValue })
        XCTAssertTrue(withEnergy.allSatisfy { $0.candidate.energyFit != nil })
    }
}

private extension PlanningDomainModelsTests {
    func makeGoal(id: String, stepID: String, dueAt: String) -> Goal {
        let actor = GoalActor(actorID: "self", displayName: "You", ownership: .self, roleLabel: "Primary owner", isPrimary: true)
        let timing = GoalTiming(tempo: .deadlineBased, timingType: .dueAt, startsOn: nil, dueAt: dueAt, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: 7)
        let strategy = PlanningStrategy(strategyKind: .sequential, allowParallelSteps: false, maxActiveSteps: 3, preferredSectionOrder: [.activeSteps], defaultStepType: .actionUnit, autoGenerateReviewSection: false, preferShortSteps: true, revisitCadenceDays: 7)
        let progress = ProgressStrategy(metricKind: .stepCompletion, rollupMethod: .ratio, targetStepCount: nil, targetEvidenceCount: nil, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        let step = Step(id: stepID, sectionID: "section-\(id)", title: "Do the next thing", summary: nil, type: .actionUnit, state: .planned, owner: actor, timing: timing, dependencyStepIDs: [], isOptional: false, isRepeatable: false, evidenceRequired: true, successSignals: ["Done"], actionability: StepActionability(action: "Do it", completionDefinition: "Done", evidenceOfCompletion: ["Done"], fallbackMicroStep: "Start", contextRequirements: []))
        let plan = GoalPlan(id: "plan-\(id)", goalID: id, version: goalEnginePlanVersion, generatedAt: "2026-04-15T12:00:00Z", summary: nil, strategy: strategy, sections: [PlanSection(id: "section-\(id)", goalID: id, title: "Active", summary: nil, kind: .activeSteps, orderIndex: 0, steps: [step])], assumptions: [], lint: PlanLintResult(goalID: id, planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: []))
        return Goal(schemaVersion: goalEngineSchemaVersion, id: id, revision: 1, createdAt: "2026-04-15T12:00:00Z", updatedAt: "2026-04-15T12:00:00Z", state: .active, title: id, summary: nil, mode: .project, relationshipKind: .independent, actor: actor, parentGoalID: nil, childGoalIDs: [], supportGoalIDs: [], tags: [], timing: timing, planningStrategy: strategy, progressStrategy: progress, plan: plan)
    }
}
