import Foundation

struct GoalEngineFixture: Sendable {
    let id: String
    let input: String
    let context: GoalEngineOrchestrationContext
    let result: GoalOrchestrationResult
}

struct GoalPlannerFixture: Sendable {
    let id: String
    let result: GoalPlannerResult
}

struct GoalFeedbackFixture: Sendable {
    let id: String
    let input: GoalAdaptivePlanInput
}

enum GoalEngineFixtures {
    static let fixedNow = "2026-04-14T12:00:00Z"

    static let orchestrationFixtures: [GoalEngineFixture] = [
        run(id: "clear-timed-self-goal", input: "Submit my conference talk proposal by 2026-05-15", context: GoalEngineOrchestrationContext(sourceScreen: "goal_composer", sourceFlow: "manual_entry", referenceNow: fixedNow)),
        run(id: "untimed-learning-goal", input: "Learn how to mix vocals", context: GoalEngineOrchestrationContext(sourceScreen: "goal_composer", referenceNow: fixedNow)),
        run(id: "exploratory-vague-goal", input: "Launch my business", context: GoalEngineOrchestrationContext(preferredPlanningStrictness: .starterFriendly, referenceNow: fixedNow)),
        run(id: "delegated-child-support-goal", input: "Help my daughter read better", context: GoalEngineOrchestrationContext(actorName: "Maya", goalOwnerRole: "Supported learner", supportScope: .supporting, referenceNow: fixedNow)),
        run(id: "blocked-requiring-clarification", input: "Break this down for someone else", context: GoalEngineOrchestrationContext(referenceNow: fixedNow)),
        run(id: "contradictory-input", input: "I want to launch my business this summer, but I don't want deadlines", context: GoalEngineOrchestrationContext(referenceNow: fixedNow)),
        run(id: "dont-know-where-to-start", input: "I don't know where to start", context: GoalEngineOrchestrationContext(referenceNow: fixedNow)),
        run(id: "target-window-goal", input: "Launch my portfolio this summer", context: GoalEngineOrchestrationContext(referenceNow: fixedNow)),
        run(id: "recovery-goal", input: "Get healthier", context: GoalEngineOrchestrationContext(preferredPlanningStrictness: .starterFriendly, referenceNow: fixedNow)),
        run(id: "exploration-goal", input: "Figure out if freelancing is right for me", context: GoalEngineOrchestrationContext(referenceNow: fixedNow)),
        run(id: "maintenance-goal", input: "Keep my stretching routine going weekly", context: GoalEngineOrchestrationContext(referenceNow: fixedNow)),
    ]

    static let plannerFixtures: [GoalPlannerFixture] = [
        plannerFixture(id: "timed-achievement-goal", input: "Submit my conference talk proposal by 2026-05-15"),
        plannerFixture(id: "untimed-learning-goal", input: "Learn how to mix vocals"),
        plannerFixture(id: "exploration-goal-with-ambiguity", input: "Figure out if freelancing is right for me"),
        plannerFixture(id: "maintenance-goal", input: "Keep my stretching routine going weekly"),
        plannerFixture(id: "recovery-goal", input: "Get healthier", context: GoalEngineOrchestrationContext(preferredPlanningStrictness: .starterFriendly, referenceNow: fixedNow)),
        plannerFixture(id: "delegated-child-support-goal", input: "Help my daughter read better", context: GoalEngineOrchestrationContext(actorName: "Maya", supportScope: .supporting, referenceNow: fixedNow)),
        plannerFixture(id: "vague-safe-starter-plan", input: "Launch my business", context: GoalEngineOrchestrationContext(preferredPlanningStrictness: .starterFriendly, referenceNow: fixedNow)),
        blockedPlannerFixture(id: "blocked-planning-case", input: "Break this down for someone else"),
    ]

    static let feedbackFixtures: [GoalFeedbackFixture] = buildFeedbackFixtures()

    static func fixture(id: String) -> GoalEngineFixture? {
        orchestrationFixtures.first(where: { $0.id == id })
    }

    static func plannerFixture(id: String) -> GoalPlannerFixture? {
        plannerFixtures.first(where: { $0.id == id })
    }

    static func feedbackFixture(id: String) -> GoalFeedbackFixture? {
        feedbackFixtures.first(where: { $0.id == id })
    }

    private static func run(id: String, input: String, context: GoalEngineOrchestrationContext) -> GoalEngineFixture {
        GoalEngineFixture(id: id, input: input, context: context, result: compileGoal(input, context: context))
    }

    private static func plannerFixture(id: String, input: String, context: GoalEngineOrchestrationContext = GoalEngineOrchestrationContext(referenceNow: fixedNow)) -> GoalPlannerFixture {
        let result = compileGoal(input, context: context)
        switch result {
        case let .planned(planned):
            return GoalPlannerFixture(id: id, result: .plan(draft: planned.draft, plan: planned.plan, lint: planned.lint))
        case let .starterPlanned(starter):
            return GoalPlannerFixture(id: id, result: .starterPlan(draft: starter.draft, plan: starter.plan, lint: starter.lint, assumptions: starter.assumptions))
        case let .blocked(blocked):
            return GoalPlannerFixture(id: id, result: .blocked(draft: blocked.draft, blockers: blocked.blockers, clarification: blocked.clarification.map {
                ClarificationSet(readiness: $0.readiness, questions: $0.questions, missingFields: $0.missingFields)
            }))
        case let .clarificationRequired(required):
            return GoalPlannerFixture(
                id: id,
                result: .blocked(
                    draft: required.draft,
                    blockers: required.clarification.missingFields.filter(\.blocksPlanning).map {
                        missing in
                        GoalPlanningBlocker(
                            code: missing.field.rawValue,
                            reason: missing.reason,
                            suggestedQuestion: required.clarification.questions.first(where: { $0.field == missing.field })?.prompt
                        )
                    },
                    clarification: ClarificationSet(readiness: required.clarification.readiness, questions: required.clarification.questions, missingFields: required.clarification.missingFields)
                )
            )
        }
    }

    private static func blockedPlannerFixture(id: String, input: String) -> GoalPlannerFixture {
        plannerFixture(id: id, input: input)
    }
}

private extension GoalEngineFixtures {
    static func buildFeedbackFixtures() -> [GoalFeedbackFixture] {
        let plannedAchievement = adaptivePlanResult(for: "clear-timed-self-goal")
        let learning = adaptivePlanResult(for: "untimed-learning-goal")
        let delegated = adaptivePlanResult(for: "delegated-child-support-goal")
        let exploration = adaptivePlanResult(for: "exploration-goal")
        let recovery = adaptivePlanResult(for: "recovery-goal")

        let achievementStep = firstStep(in: plannedAchievement)
        let learningStep = firstStep(in: learning)
        let delegatedStep = firstStep(in: delegated)
        let explorationStep = firstStep(in: exploration)
        let recoveryStep = firstStep(in: recovery)

        let untimedTimingStep = Step(
            id: learningStep.id,
            sectionID: learningStep.sectionID,
            title: learningStep.title,
            summary: learningStep.summary,
            type: learningStep.type,
            state: learningStep.state,
            owner: learningStep.owner,
            timing: GoalTiming(
                tempo: learning.draft.timing.tempo,
                timingType: .suggestedNext,
                startsOn: nil,
                dueAt: nil,
                targetBy: nil,
                windowStart: nil,
                windowEnd: nil,
                suggestedNextAt: fixedNow,
                repeatEveryDays: nil,
                progressReviewCadenceDays: learning.draft.timing.progressReviewCadenceDays
            ),
            dependencyStepIDs: learningStep.dependencyStepIDs,
            isOptional: learningStep.isOptional,
            isRepeatable: learningStep.isRepeatable,
            evidenceRequired: learningStep.evidenceRequired,
            successSignals: learningStep.successSignals,
            actionability: learningStep.actionability
        )

        let punitiveSupportStep = Step(
            id: delegatedStep.id,
            sectionID: delegatedStep.sectionID,
            title: "Make Maya finish her reading tonight",
            summary: delegatedStep.summary,
            type: delegatedStep.type,
            state: delegatedStep.state,
            owner: delegatedStep.owner,
            timing: delegatedStep.timing,
            dependencyStepIDs: delegatedStep.dependencyStepIDs,
            isOptional: delegatedStep.isOptional,
            isRepeatable: delegatedStep.isRepeatable,
            evidenceRequired: delegatedStep.evidenceRequired,
            successSignals: delegatedStep.successSignals,
            actionability: StepActionability(
                action: "Make sure Maya completes the reading tonight and stays on track.",
                completionDefinition: delegatedStep.actionability.completionDefinition,
                evidenceOfCompletion: delegatedStep.actionability.evidenceOfCompletion,
                fallbackMicroStep: delegatedStep.actionability.fallbackMicroStep,
                contextRequirements: delegatedStep.actionability.contextRequirements
            )
        )

        let rigidExplorationStep = Step(
            id: explorationStep.id,
            sectionID: explorationStep.sectionID,
            title: explorationStep.title,
            summary: explorationStep.summary,
            type: explorationStep.type,
            state: explorationStep.state,
            owner: explorationStep.owner,
            timing: GoalTiming(
                tempo: exploration.draft.timing.tempo,
                timingType: .targetBy,
                startsOn: nil,
                dueAt: nil,
                targetBy: "2026-04-18",
                windowStart: nil,
                windowEnd: nil,
                suggestedNextAt: nil,
                repeatEveryDays: nil,
                progressReviewCadenceDays: exploration.draft.timing.progressReviewCadenceDays
            ),
            dependencyStepIDs: explorationStep.dependencyStepIDs,
            isOptional: explorationStep.isOptional,
            isRepeatable: explorationStep.isRepeatable,
            evidenceRequired: explorationStep.evidenceRequired,
            successSignals: explorationStep.successSignals,
            actionability: explorationStep.actionability
        )

        return [
            GoalFeedbackFixture(id: "achievement-avoidance", input: GoalAdaptivePlanInput(currentResult: plannedAchievement, selectedStep: achievementStep, feedbackHistory: [
                .skipped(base: GoalFeedbackEventBase(id: "avoidance-1", stepID: achievementStep.id, occurredAt: fixedNow, note: "Kept putting it off."), reasonCode: .avoidance),
                .skipped(base: GoalFeedbackEventBase(id: "avoidance-2", stepID: achievementStep.id, occurredAt: "2026-04-15T12:00:00Z", note: "Still feels like too much."), reasonCode: .tooHard),
                .tooBig(base: GoalFeedbackEventBase(id: "too-big", stepID: achievementStep.id, occurredAt: "2026-04-15T12:05:00Z", note: nil)),
            ])),
            GoalFeedbackFixture(id: "learning-confusion", input: GoalAdaptivePlanInput(currentResult: learning, selectedStep: learningStep, feedbackHistory: [
                .confused(base: GoalFeedbackEventBase(id: "confused-1", stepID: learningStep.id, occurredAt: fixedNow, note: "Not sure what to actually do first."), confusionType: .unclearAction),
                .confused(base: GoalFeedbackEventBase(id: "confused-2", stepID: learningStep.id, occurredAt: "2026-04-15T12:00:00Z", note: "I don't know what completion looks like."), confusionType: .missingEvidence),
            ])),
            GoalFeedbackFixture(id: "untimed-timing-pressure", input: GoalAdaptivePlanInput(currentResult: learning, selectedStep: untimedTimingStep, feedbackHistory: [
                .delayed(base: GoalFeedbackEventBase(id: "delayed-1", stepID: untimedTimingStep.id, occurredAt: fixedNow, note: "I still want this, just not on a deadline."), timingAdjustment: .removeDeadline, date: nil),
            ])),
            GoalFeedbackFixture(id: "delegated-tone-drift", input: GoalAdaptivePlanInput(currentResult: delegated, selectedStep: punitiveSupportStep, feedbackHistory: [
                .edited(base: GoalFeedbackEventBase(id: "tone-edit", stepID: punitiveSupportStep.id, occurredAt: fixedNow, note: "This sounds too controlling."), rewrittenText: punitiveSupportStep.actionability.action),
            ])),
            GoalFeedbackFixture(id: "exploration-rigid", input: GoalAdaptivePlanInput(currentResult: exploration, selectedStep: rigidExplorationStep, feedbackHistory: [
                .delayed(base: GoalFeedbackEventBase(id: "exploration-delay", stepID: rigidExplorationStep.id, occurredAt: fixedNow, note: "This feels too structured for something exploratory."), timingAdjustment: .laterThisWeek, date: "2026-04-19"),
            ])),
            GoalFeedbackFixture(id: "recovery-gentle", input: GoalAdaptivePlanInput(currentResult: recovery, selectedStep: recoveryStep, feedbackHistory: [
                .skipped(base: GoalFeedbackEventBase(id: "recovery-skip", stepID: recoveryStep.id, occurredAt: fixedNow, note: "I was overwhelmed."), reasonCode: .avoidance),
                .tooBig(base: GoalFeedbackEventBase(id: "recovery-too-big", stepID: recoveryStep.id, occurredAt: "2026-04-15T12:00:00Z", note: nil)),
            ])),
            GoalFeedbackFixture(id: "not-relevant-reclarify", input: GoalAdaptivePlanInput(currentResult: learning, selectedStep: learningStep, feedbackHistory: [
                .notRelevant(base: GoalFeedbackEventBase(id: "not-relevant-1", stepID: learningStep.id, occurredAt: fixedNow, note: "This is not the issue anymore.")),
                .notRelevant(base: GoalFeedbackEventBase(id: "not-relevant-2", stepID: learningStep.id, occurredAt: "2026-04-15T09:00:00Z", note: "Still off target.")),
            ])),
            GoalFeedbackFixture(id: "why-this-matters", input: GoalAdaptivePlanInput(currentResult: learning, selectedStep: learningStep, feedbackHistory: [
                .askedWhyThisMatters(base: GoalFeedbackEventBase(id: "why", stepID: learningStep.id, occurredAt: fixedNow, note: "I don't see why this step matters.")),
            ])),
        ]
    }

    static func adaptivePlanResult(for id: String) -> GoalAdaptivePlanResult {
        guard let result = fixture(id: id)?.result.adaptivePlanResult else {
            fatalError("Missing adaptive plan result for fixture \(id)")
        }
        return result
    }

    static func firstStep(in result: GoalAdaptivePlanResult) -> Step {
        guard let step = result.plan.sections.flatMap(\.steps).first else {
            fatalError("Expected at least one step in adaptive fixture")
        }
        return step
    }
}
