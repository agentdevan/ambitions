import XCTest
@testable import Ambitions

final class GoalEnergyFitServiceTests: XCTestCase {
    func testEvaluationIsDeterministicForRepeatedInputs() {
        let service = DefaultGoalEnergyFitService()
        let compiledPath = GoalCompiledPath.legacyFallback(from: GoalPathCompilerServiceTests().sampleUnderstanding())

        let first = service.evaluate(compiledPath: compiledPath, capacityContext: .assumedNeutral())
        let second = service.evaluate(compiledPath: compiledPath, capacityContext: .assumedNeutral())

        XCTAssertEqual(first, second)
        XCTAssertTrue(first.evaluations.allSatisfy { (0...1).contains($0.score) })
    }

    func testRecoveryGoalCarriesRecoveryCompatibleMarkers() {
        let service = DefaultGoalEnergyFitService()
        let goal = makeGoal(mode: .recovery, stepState: .planned, dependencyStepIDs: [])
        let step = goal.plan!.sections[0].steps[0]

        let summary = service.planningSummary(
            for: step,
            goal: goal,
            evaluation: goal.plan!.evaluation,
            canonicalEnergyModel: nil
        )

        XCTAssertEqual(summary.fitBand, .sustainable)
        XCTAssertTrue(summary.reasonCodes.contains(.recoveryCompatible))
        XCTAssertTrue(summary.reasonCodes.contains(.lowFrictionStep))
    }

    func testBlockedDependencyHeavyStepCarriesStructuralStrainMarkers() {
        let service = DefaultGoalEnergyFitService()
        let goal = makeGoal(mode: .project, stepState: .blocked, dependencyStepIDs: ["step-prereq"])
        let step = goal.plan!.sections[0].steps[0]

        let summary = service.planningSummary(
            for: step,
            goal: goal,
            evaluation: goal.plan!.evaluation,
            canonicalEnergyModel: nil
        )

        XCTAssertTrue(summary.reasonCodes.contains(.blockedDependency))
        XCTAssertTrue(summary.reasonCodes.contains(.dependencyLoad))
        XCTAssertLessThan(summary.score, 0.6)
    }

    func testPlanningSummaryPrefersCanonicalModelWhenAvailable() {
        let service = DefaultGoalEnergyFitService()
        let goal = makeGoal(mode: .project, stepState: .planned, dependencyStepIDs: [])
        let step = goal.plan!.sections[0].steps[0]
        let canonical = GoalEnergyModel(
            schemaVersion: goalEnergyFitSchemaVersion,
            sourceCompiledPathSchemaVersion: nil,
            capacityContext: .assumedNeutral(),
            overallBand: .sustainable,
            candidateSummaries: [],
            evaluations: [
                GoalEnergyFitEvaluation(
                    id: "energy-step-\(step.id)",
                    targetKind: .planStep,
                    targetID: step.id,
                    candidateID: nil,
                    stageID: nil,
                    stepID: step.id,
                    workShape: .execution,
                    effortDemand: .moderate,
                    focusDemand: .moderate,
                    recoveryCompatibility: .compatible,
                    pacingPosture: .steady,
                    fitBand: .sustainable,
                    score: 0.77,
                    reasons: [
                        GoalEnergyFitReason(
                            code: .canonicalMetadata,
                            targetKind: .planStep,
                            targetID: step.id,
                            relatedStageKind: nil,
                            relatedStepType: step.type,
                            impact: .positive,
                            summary: "Canonical metadata supplied the planning summary."
                        )
                    ]
                )
            ],
            audit: GoalEnergyModelAuditMetadata(entries: [])
        )

        let summary = service.planningSummary(
            for: step,
            goal: goal,
            evaluation: goal.plan!.evaluation,
            canonicalEnergyModel: canonical
        )

        XCTAssertEqual(summary.score, 0.77)
        XCTAssertEqual(summary.reasonCodes, [.canonicalMetadata])
    }
}

private extension GoalEnergyFitServiceTests {
    func makeGoal(mode: GoalMode, stepState: StepLifecycleState, dependencyStepIDs: [String]) -> Goal {
        let actor = GoalActor(actorID: "self", displayName: "You", ownership: .self, roleLabel: "Primary owner", isPrimary: true)
        let timing = GoalTiming(tempo: .untimed, timingType: .suggestedNext, startsOn: nil, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: GoalEngineFixtures.fixedNow, repeatEveryDays: nil, progressReviewCadenceDays: 7)
        let strategy = PlanningStrategy(strategyKind: .adaptive, allowParallelSteps: true, maxActiveSteps: 3, preferredSectionOrder: [.activeSteps], defaultStepType: .actionUnit, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 7)
        let progress = ProgressStrategy(metricKind: .stepCompletion, rollupMethod: .ratio, targetStepCount: nil, targetEvidenceCount: nil, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        let stepType: StepType = mode == .recovery ? .observationPrompt : .actionUnit
        let step = Step(
            id: "step-energy",
            sectionID: "section-energy",
            title: mode == .recovery ? "Log what feels steadier" : "Complete dependency-heavy work",
            summary: nil,
            type: stepType,
            state: stepState,
            owner: actor,
            timing: timing,
            dependencyStepIDs: dependencyStepIDs,
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: true,
            successSignals: ["Done"],
            actionability: StepActionability(action: "Do it", completionDefinition: "Done", evidenceOfCompletion: ["Done"], fallbackMicroStep: "Start small", contextRequirements: dependencyStepIDs)
        )
        let plan = GoalPlan(
            id: "plan-energy",
            goalID: "goal-energy",
            version: goalEnginePlanVersion,
            generatedAt: GoalEngineFixtures.fixedNow,
            summary: nil,
            strategy: strategy,
            sections: [PlanSection(id: "section-energy", goalID: "goal-energy", title: "Active", summary: nil, kind: .activeSteps, orderIndex: 0, steps: [step])],
            assumptions: [],
            lint: PlanLintResult(goalID: "goal-energy", planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: []),
            evaluation: PlanningEvaluation(
                feasibilityScore: 0.78,
                feasibilityLevel: .comfortable,
                recommendationConfidence: .high,
                pressureLevel: .low,
                fragilityLevel: .low,
                effortPosture: mode == .recovery ? .gentle : .steady,
                reasons: ["Fixture."]
            )
        )
        return Goal(schemaVersion: goalEngineSchemaVersion, id: "goal-energy", revision: 1, createdAt: GoalEngineFixtures.fixedNow, updatedAt: GoalEngineFixtures.fixedNow, state: .active, title: "Energy goal", summary: nil, mode: mode, relationshipKind: .independent, actor: actor, parentGoalID: nil, childGoalIDs: [], supportGoalIDs: [], tags: [], timing: timing, planningStrategy: strategy, progressStrategy: progress, plan: plan)
    }
}
