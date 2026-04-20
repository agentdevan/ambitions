import XCTest
@testable import Ambitions

final class GoalEnergyLearningServiceTests: XCTestCase {
    func testSparseHistoryReturnsNeutralSummary() throws {
        let service = DefaultGoalEnergyLearningService()
        let goal = makeGoal(stepIDs: ["step-a"], stepType: .actionUnit)
        let step = try XCTUnwrap(goal.plan?.sections.first?.steps.first)

        let summary = service.planningSummary(
            for: step,
            goal: goal,
            evidence: [
                makeEvidence(id: "e1", goalID: goal.id, stepID: step.id, kind: .stepCompleted, at: "2026-04-20T09:00:00Z", minutes: 20)
            ],
            feedback: [],
            canonicalEnergyModel: makeCanonicalEnergyModel(stepIDs: [step.id], stepType: .actionUnit),
            energyFit: PlanningEnergyFitSummary(
                source: .canonicalMetadata,
                fitBand: .sustainable,
                score: 0.72,
                reasonCodes: [.canonicalMetadata]
            ),
            now: try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T12:00:00Z"))
        )

        XCTAssertEqual(summary.rankingAdjustment, 0)
        XCTAssertEqual(summary.confidence, .low)
        XCTAssertTrue(summary.reasonCodes.contains(.insufficientSignals))
        XCTAssertEqual(summary.tendencyCodes, [.mixedOrInsufficientHistory])
    }

    func testConflictingHistoryReturnsNeutralSummary() throws {
        let service = DefaultGoalEnergyLearningService()
        let goal = makeGoal(stepIDs: ["step-a"], stepType: .actionUnit)
        let step = try XCTUnwrap(goal.plan?.sections.first?.steps.first)

        let summary = service.planningSummary(
            for: step,
            goal: goal,
            evidence: [
                makeEvidence(id: "e1", goalID: goal.id, stepID: step.id, kind: .stepCompleted, at: "2026-04-18T09:00:00Z", minutes: 20),
                makeEvidence(id: "e2", goalID: goal.id, stepID: step.id, kind: .stepCompleted, at: "2026-04-19T09:00:00Z", minutes: 25),
                makeEvidence(id: "e3", goalID: goal.id, stepID: step.id, kind: .habitMinimumVersion, at: "2026-04-20T09:00:00Z", minutes: 10)
            ],
            feedback: [
                .skipped(base: makeBase(id: "f1", stepID: step.id, at: "2026-04-18T19:00:00Z"), reasonCode: .notNow),
                .tooBig(base: makeBase(id: "f2", stepID: step.id, at: "2026-04-19T19:00:00Z")),
                .askedForSmallerVersion(base: makeBase(id: "f3", stepID: step.id, at: "2026-04-20T19:00:00Z"))
            ],
            canonicalEnergyModel: makeCanonicalEnergyModel(stepIDs: [step.id], stepType: .actionUnit),
            energyFit: PlanningEnergyFitSummary(
                source: .canonicalMetadata,
                fitBand: .sustainable,
                score: 0.72,
                reasonCodes: [.canonicalMetadata]
            ),
            now: try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T12:00:00Z"))
        )

        XCTAssertEqual(summary.rankingAdjustment, 0)
        XCTAssertEqual(summary.confidence, .low)
        XCTAssertTrue(summary.reasonCodes.contains(.conflictingHistory))
    }

    func testSameStepPositiveHistoryProducesBoundedPositiveAdjustment() throws {
        let service = DefaultGoalEnergyLearningService()
        let goal = makeGoal(stepIDs: ["step-a"], stepType: .actionUnit)
        let step = try XCTUnwrap(goal.plan?.sections.first?.steps.first)

        let summary = service.planningSummary(
            for: step,
            goal: goal,
            evidence: [
                makeEvidence(id: "e1", goalID: goal.id, stepID: step.id, kind: .stepCompleted, at: "2026-04-18T09:00:00Z", minutes: 20),
                makeEvidence(id: "e2", goalID: goal.id, stepID: step.id, kind: .stepCompleted, at: "2026-04-19T09:00:00Z", minutes: 20),
                makeEvidence(id: "e3", goalID: goal.id, stepID: step.id, kind: .habitMinimumVersion, at: "2026-04-20T09:00:00Z", minutes: 10)
            ],
            feedback: [
                .completed(base: makeBase(id: "f1", stepID: step.id, at: "2026-04-18T09:30:00Z"), actualDuration: 20, effortLevel: .low, confidenceDelta: 0.08)
            ],
            canonicalEnergyModel: makeCanonicalEnergyModel(stepIDs: [step.id], stepType: .actionUnit),
            energyFit: PlanningEnergyFitSummary(
                source: .canonicalMetadata,
                fitBand: .sustainable,
                score: 0.72,
                reasonCodes: [.canonicalMetadata]
            ),
            now: try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T12:00:00Z"))
        )

        XCTAssertGreaterThan(summary.rankingAdjustment, 0)
        XCTAssertLessThanOrEqual(summary.rankingAdjustment, 0.08)
        XCTAssertEqual(summary.confidence, .high)
        XCTAssertTrue(summary.reasonCodes.contains(.sameStepPositiveHistory))
    }

    func testSameGoalSameStepTypeFallbackCanNudgeWhenExactStepHistoryIsSparse() throws {
        let service = DefaultGoalEnergyLearningService()
        let goal = makeGoal(stepIDs: ["step-a", "step-b"], stepType: .actionUnit)
        let step = try XCTUnwrap(goal.plan?.sections.first?.steps.first(where: { $0.id == "step-a" }))

        let summary = service.planningSummary(
            for: step,
            goal: goal,
            evidence: [
                makeEvidence(id: "e1", goalID: goal.id, stepID: "step-b", kind: .stepCompleted, at: "2026-04-18T09:00:00Z", minutes: 20),
                makeEvidence(id: "e2", goalID: goal.id, stepID: "step-b", kind: .stepCompleted, at: "2026-04-19T09:00:00Z", minutes: 20),
                makeEvidence(id: "e3", goalID: goal.id, stepID: "step-b", kind: .habitMinimumVersion, at: "2026-04-20T09:00:00Z", minutes: 10)
            ],
            feedback: [
                .completed(base: makeBase(id: "f1", stepID: "step-b", at: "2026-04-18T09:30:00Z"), actualDuration: 20, effortLevel: .low, confidenceDelta: 0.08)
            ],
            canonicalEnergyModel: makeCanonicalEnergyModel(stepIDs: ["step-a", "step-b"], stepType: .actionUnit),
            energyFit: PlanningEnergyFitSummary(
                source: .canonicalMetadata,
                fitBand: .sustainable,
                score: 0.72,
                reasonCodes: [.canonicalMetadata]
            ),
            now: try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T12:00:00Z"))
        )

        XCTAssertGreaterThan(summary.rankingAdjustment, 0)
        XCTAssertTrue(summary.reasonCodes.contains(.sameGoalSameTypeFallback))
    }

    func testMissingCanonicalEnergyModelReturnsNeutralSummary() throws {
        let service = DefaultGoalEnergyLearningService()
        let goal = makeGoal(stepIDs: ["step-a"], stepType: .actionUnit)
        let step = try XCTUnwrap(goal.plan?.sections.first?.steps.first)

        let summary = service.planningSummary(
            for: step,
            goal: goal,
            evidence: [
                makeEvidence(id: "e1", goalID: goal.id, stepID: step.id, kind: .stepCompleted, at: "2026-04-18T09:00:00Z", minutes: 20),
                makeEvidence(id: "e2", goalID: goal.id, stepID: step.id, kind: .stepCompleted, at: "2026-04-19T09:00:00Z", minutes: 20),
                makeEvidence(id: "e3", goalID: goal.id, stepID: step.id, kind: .habitMinimumVersion, at: "2026-04-20T09:00:00Z", minutes: 10)
            ],
            feedback: [],
            canonicalEnergyModel: nil,
            energyFit: PlanningEnergyFitSummary(
                source: .serviceFallback,
                fitBand: .sustainable,
                score: 0.72,
                reasonCodes: [.assumedNeutralCapacity]
            ),
            now: try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T12:00:00Z"))
        )

        XCTAssertEqual(summary.rankingAdjustment, 0)
        XCTAssertTrue(summary.reasonCodes.contains(.missingCanonicalEnergyModel))
    }

    func testReorderedInputsProduceDeterministicOutput() throws {
        let service = DefaultGoalEnergyLearningService()
        let goal = makeGoal(stepIDs: ["step-a"], stepType: .actionUnit)
        let step = try XCTUnwrap(goal.plan?.sections.first?.steps.first)
        let evidence = [
            makeEvidence(id: "e1", goalID: goal.id, stepID: step.id, kind: .stepCompleted, at: "2026-04-18T09:00:00Z", minutes: 20),
            makeEvidence(id: "e2", goalID: goal.id, stepID: step.id, kind: .stepCompleted, at: "2026-04-19T09:00:00Z", minutes: 20),
            makeEvidence(id: "e3", goalID: goal.id, stepID: step.id, kind: .habitMinimumVersion, at: "2026-04-20T09:00:00Z", minutes: 10)
        ]
        let feedback: [GoalFeedbackEvent] = [
            .completed(base: makeBase(id: "f1", stepID: step.id, at: "2026-04-18T09:30:00Z"), actualDuration: 20, effortLevel: .low, confidenceDelta: 0.08)
        ]
        let canonical = makeCanonicalEnergyModel(stepIDs: [step.id], stepType: .actionUnit)
        let energyFit = PlanningEnergyFitSummary(
            source: .canonicalMetadata,
            fitBand: .sustainable,
            score: 0.72,
            reasonCodes: [.canonicalMetadata]
        )
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T12:00:00Z"))

        let first = service.planningSummary(
            for: step,
            goal: goal,
            evidence: evidence,
            feedback: feedback,
            canonicalEnergyModel: canonical,
            energyFit: energyFit,
            now: now
        )
        let second = service.planningSummary(
            for: step,
            goal: goal,
            evidence: evidence.reversed(),
            feedback: feedback.reversed(),
            canonicalEnergyModel: canonical,
            energyFit: energyFit,
            now: now
        )

        XCTAssertEqual(first, second)
    }
}

private extension GoalEnergyLearningServiceTests {
    func makeGoal(stepIDs: [String], stepType: StepType) -> Goal {
        let actor = GoalActor(actorID: "self", displayName: "You", ownership: .self, roleLabel: "Primary owner", isPrimary: true)
        let timing = GoalTiming(tempo: .deadlineBased, timingType: .dueAt, startsOn: nil, dueAt: "2026-04-25T12:00:00Z", targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: 7)
        let strategy = PlanningStrategy(strategyKind: .sequential, allowParallelSteps: false, maxActiveSteps: 3, preferredSectionOrder: [.activeSteps], defaultStepType: stepType, autoGenerateReviewSection: false, preferShortSteps: true, revisitCadenceDays: 7)
        let progress = ProgressStrategy(metricKind: .stepCompletion, rollupMethod: .ratio, targetStepCount: nil, targetEvidenceCount: nil, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        let steps = stepIDs.enumerated().map { index, stepID in
            Step(
                id: stepID,
                sectionID: "section-goal-energy-learning",
                title: "Step \(index)",
                summary: nil,
                type: stepType,
                state: .planned,
                owner: actor,
                timing: timing,
                dependencyStepIDs: [],
                isOptional: false,
                isRepeatable: false,
                evidenceRequired: true,
                successSignals: ["Done"],
                actionability: StepActionability(action: "Do it", completionDefinition: "Done", evidenceOfCompletion: ["Done"], fallbackMicroStep: "Start small", contextRequirements: [])
            )
        }
        let plan = GoalPlan(
            id: "plan-goal-energy-learning",
            goalID: "goal-energy-learning",
            version: goalEnginePlanVersion,
            generatedAt: GoalEngineFixtures.fixedNow,
            summary: nil,
            strategy: strategy,
            sections: [PlanSection(id: "section-goal-energy-learning", goalID: "goal-energy-learning", title: "Active", summary: nil, kind: .activeSteps, orderIndex: 0, steps: steps)],
            assumptions: [],
            lint: PlanLintResult(goalID: "goal-energy-learning", planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: [])
        )
        return Goal(schemaVersion: goalEngineSchemaVersion, id: "goal-energy-learning", revision: 1, createdAt: GoalEngineFixtures.fixedNow, updatedAt: GoalEngineFixtures.fixedNow, state: .active, title: "Energy learning goal", summary: nil, mode: .project, relationshipKind: .independent, actor: actor, parentGoalID: nil, childGoalIDs: [], supportGoalIDs: [], tags: [], timing: timing, planningStrategy: strategy, progressStrategy: progress, plan: plan)
    }

    func makeEvidence(id: String, goalID: String, stepID: String, kind: ProgressEvidenceKind, at capturedAt: String, minutes: Int) -> ProgressEvidence {
        ProgressEvidence(id: id, goalID: goalID, stepID: stepID, evidenceKind: kind, source: .manual, capturedAt: capturedAt, progressDelta: 0.2, confidenceDelta: 0.05, minutesInvested: minutes, note: nil)
    }

    func makeBase(id: String, stepID: String, at occurredAt: String) -> GoalFeedbackEventBase {
        GoalFeedbackEventBase(id: id, stepID: stepID, occurredAt: occurredAt, note: nil)
    }

    func makeCanonicalEnergyModel(stepIDs: [String], stepType: StepType) -> GoalEnergyModel {
        GoalEnergyModel(
            schemaVersion: goalEnergyFitSchemaVersion,
            sourceCompiledPathSchemaVersion: nil,
            capacityContext: .assumedNeutral(),
            overallBand: .sustainable,
            candidateSummaries: [],
            evaluations: stepIDs.map { stepID in
                GoalEnergyFitEvaluation(
                    id: "energy-\(stepID)",
                    targetKind: .planStep,
                    targetID: stepID,
                    candidateID: nil,
                    stageID: nil,
                    stepID: stepID,
                    workShape: .execution,
                    effortDemand: .moderate,
                    focusDemand: .moderate,
                    recoveryCompatibility: .neutral,
                    pacingPosture: .steady,
                    fitBand: .sustainable,
                    score: 0.72,
                    reasons: [
                        GoalEnergyFitReason(
                            code: .canonicalMetadata,
                            targetKind: .planStep,
                            targetID: stepID,
                            relatedStageKind: nil,
                            relatedStepType: stepType,
                            impact: .positive,
                            summary: "Canonical metadata."
                        )
                    ]
                )
            },
            audit: GoalEnergyModelAuditMetadata(entries: [])
        )
    }
}
