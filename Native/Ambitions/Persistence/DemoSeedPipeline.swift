import Foundation

struct DemoSeedPipeline {
    static let seedVersion = "native_demo_seed.v1"

    let repositories: AppRepositories

    func seedIfNeeded(force: Bool = false) async throws {
        let existingGoals = try await repositories.goals.listGoals()
        var state = try await repositories.appState.loadState()

        if !force, !existingGoals.isEmpty, state.lastSeedVersion == Self.seedVersion {
            return
        }

        let seededGoals = seededGoalFixtures()
        let seededDrafts = seededDraftFixtures(plannedGoals: seededGoals)
        let seededEvidence = seededEvidenceFixtures(goals: seededGoals)
        let seededFeedback = seededFeedbackFixtures()

        try await repositories.goals.saveGoals(seededGoals)
        try await repositories.drafts.saveDrafts(seededDrafts)
        try await repositories.evidence.saveEvidence(seededEvidence)

        for (goalID, events) in Dictionary(grouping: seededFeedback, by: { $0.0 }) {
            try await repositories.feedback.saveEvents(events.map { $0.1 }, goalID: goalID)
        }

        state.hasCompletedBootstrap = true
        state.lastSeedVersion = Self.seedVersion
        state.lastSeededAt = GoalEngineFixtures.fixedNow
        if state.userDisplayName.isEmpty {
            state.userDisplayName = "Demo User"
        }
        try await repositories.appState.saveState(state)
    }
}

private extension DemoSeedPipeline {
    func seededGoalFixtures() -> [Goal] {
        GoalEngineFixtures.orchestrationFixtures.compactMap { fixture in
            switch fixture.result {
            case let .planned(result):
                return Goal(
                    schemaVersion: goalEngineSchemaVersion,
                    id: result.plan.goalID,
                    revision: 1,
                    createdAt: GoalEngineFixtures.fixedNow,
                    updatedAt: GoalEngineFixtures.fixedNow,
                    state: .active,
                    title: result.draft.title,
                    summary: result.draft.summary,
                    mode: result.draft.mode,
                    relationshipKind: result.draft.relationshipKind,
                    actor: result.draft.actor,
                    parentGoalID: result.draft.parentGoalID,
                    childGoalIDs: [],
                    supportGoalIDs: [],
                    tags: result.draft.tags,
                    timing: result.draft.timing,
                    planningStrategy: result.draft.planningStrategy,
                    progressStrategy: result.draft.progressStrategy,
                    plan: result.plan
                )
            case let .starterPlanned(result):
                return Goal(
                    schemaVersion: goalEngineSchemaVersion,
                    id: result.plan.goalID,
                    revision: 1,
                    createdAt: GoalEngineFixtures.fixedNow,
                    updatedAt: GoalEngineFixtures.fixedNow,
                    state: .active,
                    title: result.draft.title,
                    summary: result.draft.summary,
                    mode: result.draft.mode,
                    relationshipKind: result.draft.relationshipKind,
                    actor: result.draft.actor,
                    parentGoalID: result.draft.parentGoalID,
                    childGoalIDs: [],
                    supportGoalIDs: [],
                    tags: result.draft.tags,
                    timing: result.draft.timing,
                    planningStrategy: result.draft.planningStrategy,
                    progressStrategy: result.draft.progressStrategy,
                    plan: result.plan
                )
            case .clarificationRequired, .blocked:
                return nil
            }
        }
    }

    func seededDraftFixtures(plannedGoals: [Goal]) -> [PersistedGoalDraft] {
        let plannedGoalIDs = Set(plannedGoals.map(\.id))
        return GoalEngineFixtures.orchestrationFixtures.compactMap { fixture in
            switch fixture.result {
            case let .planned(result):
                return PersistedGoalDraft(id: "draft-\(fixture.id)", createdAt: GoalEngineFixtures.fixedNow, updatedAt: GoalEngineFixtures.fixedNow, draft: result.draft, classification: nil, clarification: result.metadata.clarification, stagedPlan: result.plan, assumptions: [], blockers: [], metadata: result.metadata, plannedGoalID: plannedGoalIDs.contains(result.plan.goalID) ? result.plan.goalID : nil, latestResultKind: .planned)
            case let .starterPlanned(result):
                return PersistedGoalDraft(id: "draft-\(fixture.id)", createdAt: GoalEngineFixtures.fixedNow, updatedAt: GoalEngineFixtures.fixedNow, draft: result.draft, classification: nil, clarification: result.clarification, stagedPlan: result.plan, assumptions: result.assumptions, blockers: [], metadata: result.metadata, plannedGoalID: plannedGoalIDs.contains(result.plan.goalID) ? result.plan.goalID : nil, latestResultKind: .starterPlanned)
            case let .clarificationRequired(result):
                return PersistedGoalDraft(id: "draft-\(fixture.id)", createdAt: GoalEngineFixtures.fixedNow, updatedAt: GoalEngineFixtures.fixedNow, draft: result.draft, classification: nil, clarification: result.clarification, stagedPlan: nil, assumptions: result.metadata.reasoning.assumptions, blockers: [], metadata: result.metadata, plannedGoalID: nil, latestResultKind: .clarificationRequired)
            case let .blocked(result):
                return PersistedGoalDraft(id: "draft-\(fixture.id)", createdAt: GoalEngineFixtures.fixedNow, updatedAt: GoalEngineFixtures.fixedNow, draft: result.draft, classification: nil, clarification: result.clarification, stagedPlan: nil, assumptions: result.metadata.reasoning.assumptions, blockers: result.blockers, metadata: result.metadata, plannedGoalID: nil, latestResultKind: .blocked)
            }
        }
    }

    func seededEvidenceFixtures(goals: [Goal]) -> [ProgressEvidence] {
        goals.compactMap { goal in
            guard let firstStep = goal.plan?.sections.flatMap(\.steps).first else { return nil }
            return ProgressEvidence(
                id: "evidence-\(firstStep.id)",
                goalID: goal.id,
                stepID: firstStep.id,
                evidenceKind: .sessionLogged,
                source: .manual,
                capturedAt: GoalEngineFixtures.fixedNow,
                progressDelta: 0.2,
                confidenceDelta: 0.1,
                minutesInvested: 25,
                note: "Seeded execution sample for previews and simulator work."
            )
        }
    }

    func seededFeedbackFixtures() -> [(String, GoalFeedbackEvent)] {
        GoalEngineFixtures.feedbackFixtures.flatMap { fixture in
            let goalID = fixture.input.currentResult.plan.goalID
            return fixture.input.feedbackHistory.map { (goalID, $0) }
        }
    }
}
