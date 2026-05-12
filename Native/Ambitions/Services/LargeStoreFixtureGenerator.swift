import Foundation

struct LargeStoreFixtureConfiguration: Sendable, Equatable, Hashable {
    let goalCount: Int
    let capturesPerGoal: Int
    let evidencePerGoal: Int
    let feedbackPerGoal: Int
    let generatedAt: String

    init(
        goalCount: Int = 120,
        capturesPerGoal: Int = 2,
        evidencePerGoal: Int = 2,
        feedbackPerGoal: Int = 1,
        generatedAt: String = GoalEngineFixtures.fixedNow
    ) {
        self.goalCount = max(0, goalCount)
        self.capturesPerGoal = max(0, capturesPerGoal)
        self.evidencePerGoal = max(0, evidencePerGoal)
        self.feedbackPerGoal = max(0, feedbackPerGoal)
        self.generatedAt = generatedAt
    }
}

struct LargeStoreFixtureSummary: Sendable, Equatable, Hashable {
    let goalCount: Int
    let captureCount: Int
    let evidenceCount: Int
    let feedbackCount: Int
    let localOnly: Bool
}

struct LargeStoreFixtureStore: Sendable, Equatable {
    let configuration: LargeStoreFixtureConfiguration
    let goals: [Goal]
    let captures: [Capture]
    let evidence: [ProgressEvidence]
    let feedback: [GoalFeedbackEvent]

    var summary: LargeStoreFixtureSummary {
        LargeStoreFixtureSummary(
            goalCount: goals.count,
            captureCount: captures.count,
            evidenceCount: evidence.count,
            feedbackCount: feedback.count,
            localOnly: captures.allSatisfy(\.localOnly)
        )
    }
}

struct LargeStoreFixtureGenerator: Sendable {
    func generate(configuration: LargeStoreFixtureConfiguration = LargeStoreFixtureConfiguration()) -> LargeStoreFixtureStore {
        let templates = plannedGoalTemplates()
        guard configuration.goalCount > 0, templates.isEmpty == false else {
            return LargeStoreFixtureStore(configuration: configuration, goals: [], captures: [], evidence: [], feedback: [])
        }

        var goals: [Goal] = []
        var captures: [Capture] = []
        var evidence: [ProgressEvidence] = []
        var feedback: [GoalFeedbackEvent] = []

        for index in 0..<configuration.goalCount {
            let template = templates[index % templates.count]
            let goal = makeGoal(from: template, index: index, generatedAt: configuration.generatedAt)
            goals.append(goal)
            captures.append(contentsOf: makeCaptures(for: goal, index: index, configuration: configuration))
            evidence.append(contentsOf: makeEvidence(for: goal, index: index, configuration: configuration))
            feedback.append(contentsOf: makeFeedback(for: goal, index: index, configuration: configuration))
        }

        return LargeStoreFixtureStore(
            configuration: configuration,
            goals: goals,
            captures: captures,
            evidence: evidence,
            feedback: feedback
        )
    }
}

private extension LargeStoreFixtureGenerator {
    func plannedGoalTemplates() -> [GoalPlannedResult] {
        GoalEngineFixtures.orchestrationFixtures.compactMap { fixture in
            switch fixture.result {
            case let .planned(result):
                return result
            case let .starterPlanned(result):
                return GoalPlannedResult(draft: result.draft, plan: result.plan, lint: result.lint)
            case .clarificationRequired, .blocked:
                return nil
            }
        }
    }

    func makeGoal(from template: GoalPlannedResult, index: Int, generatedAt: String) -> Goal {
        let id = "large-store-goal-\(index)"
        return Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: id,
            revision: 1,
            createdAt: generatedAt,
            updatedAt: generatedAt,
            state: index.isMultiple(of: 11) ? .paused : .active,
            title: "\(template.draft.title) \(index + 1)",
            summary: template.draft.summary,
            mode: template.draft.mode,
            relationshipKind: template.draft.relationshipKind,
            actor: template.draft.actor,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: template.draft.tags + ["large-store-fixture"],
            timing: template.draft.timing,
            planningStrategy: template.draft.planningStrategy,
            progressStrategy: template.draft.progressStrategy,
            plan: nil,
            lifeGraph: template.draft.lifeGraph
        )
    }

    func makeCaptures(
        for goal: Goal,
        index: Int,
        configuration: LargeStoreFixtureConfiguration
    ) -> [Capture] {
        (0..<configuration.capturesPerGoal).map { captureIndex in
            Capture(
                id: "large-store-capture-\(index)-\(captureIndex)",
                createdAt: configuration.generatedAt,
                updatedAt: configuration.generatedAt,
                rawText: "Large-store fixture capture \(captureIndex + 1) for \(goal.title)",
                sourceType: .todayQuickCapture,
                status: .goalBound,
                linkedGoalID: goal.id,
                triage: CaptureTriageMetadata(destination: .attachToGoal, hint: "Deterministic large-store fixture."),
                kind: .oneTimeCommitment,
                route: .goalAttachment,
                triageStatus: .routed,
                localOnly: true,
                privacy: .privateUserText
            )
        }
    }

    func makeEvidence(
        for goal: Goal,
        index: Int,
        configuration: LargeStoreFixtureConfiguration
    ) -> [ProgressEvidence] {
        (0..<configuration.evidencePerGoal).map { evidenceIndex in
            ProgressEvidence(
                id: "large-store-evidence-\(index)-\(evidenceIndex)",
                goalID: goal.id,
                stepID: nil,
                evidenceKind: .stepCompleted,
                source: .manual,
                capturedAt: configuration.generatedAt,
                progressDelta: 0.05,
                confidenceDelta: 0.02,
                minutesInvested: 15 + evidenceIndex,
                note: "Deterministic large-store fixture evidence."
            )
        }
    }

    func makeFeedback(
        for goal: Goal,
        index: Int,
        configuration: LargeStoreFixtureConfiguration
    ) -> [GoalFeedbackEvent] {
        (0..<configuration.feedbackPerGoal).map { feedbackIndex in
            GoalFeedbackEvent.completed(
                base: GoalFeedbackEventBase(
                    id: "large-store-feedback-\(index)-\(feedbackIndex)",
                    stepID: "large-store-step-\(index)-\(feedbackIndex)",
                    occurredAt: configuration.generatedAt,
                    note: "Deterministic large-store fixture feedback for \(goal.id)."
                ),
                actualDuration: 20 + feedbackIndex,
                effortLevel: .medium,
                confidenceDelta: 0.02
            )
        }
    }
}
