import Foundation

struct DemoSeedPipeline {
    static let seedVersion = "native_demo_seed.v1"

    let repositories: AppRepositories

    func seedIfNeeded(force: Bool = false) async throws {
        let existingGoals = try await repositories.goals.listGoals()
        var state = try await repositories.appState.loadState()

        if !force, !existingGoals.isEmpty, state.lastSeedVersion == Self.seedVersion {
            #if DEBUG
            try await applyRenderedTimeFoundationSeedIfNeeded()
            #endif
            return
        }

        let seededGoals = seededGoalFixtures()
        let seededDrafts = seededDraftFixtures(plannedGoals: seededGoals)
        let seededEvidence = seededEvidenceFixtures(goals: seededGoals)
        let seededFeedback = seededFeedbackFixtures()

        try await repositories.goals.saveGoals(seededGoals)
        try await repositories.drafts.saveDrafts(seededDrafts)
        try await repositories.evidence.saveEvidence(seededEvidence)
        #if DEBUG
        try await applyRenderedTimeFoundationSeedIfNeeded()
        #endif

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

extension DemoSeedPipeline {
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
                    plan: result.plan,
                    lifeGraph: result.draft.lifeGraph
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
                    plan: result.plan,
                    lifeGraph: result.draft.lifeGraph
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

    #if DEBUG
    func applyRenderedTimeFoundationSeedIfNeeded() async throws {
        guard ProcessInfo.processInfo.environment["AMBITIONS_UI_TIME_FOUNDATION_SEED"] == "1" else {
            return
        }

        let now = Date()
        let lifecycle = SimpleStepLifecycleService(
            repositories: repositories,
            idProvider: { "p1e-rendered-time-foundation" }
        )
        let step = try await lifecycle.createSimpleStep(
            title: "Mail the library card form",
            summary: "P1E local Step scheduled through the Time foundation path.",
            now: now
        )
        let windowStart = now.addingTimeInterval(2 * 60 * 60)
        _ = try await lifecycle.placeStepInTime(
            goalID: step.goalID,
            stepID: step.stepID,
            windowStart: windowStart,
            windowEnd: windowStart.addingTimeInterval(30 * 60),
            now: now.addingTimeInterval(60)
        )
        try await repositories.goals.saveGoals([
            makeRenderedTimeFoundationFixedPointGoal(now: now)
        ])
        var state = try await repositories.appState.loadState()
        let seededAt = ISO8601DateFormatter().string(from: now)
        state.hasCompletedBootstrap = true
        state.hasCompletedOnboarding = true
        state.onboardingCompletedAt = state.onboardingCompletedAt ?? seededAt
        state.lastBootstrapSource = state.lastBootstrapSource ?? .live
        state.lastSeededAt = seededAt
        try await repositories.appState.saveState(state)
    }

    func makeRenderedTimeFoundationFixedPointGoal(now: Date) -> Goal {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let createdAt = iso.string(from: now)
        let dueAt = iso.string(from: now.addingTimeInterval(24 * 60 * 60))
        let actor = GoalActor.localOwner
        let timing = GoalTiming(
            tempo: .deadlineBased,
            timingType: .dueAt,
            startsOn: createdAt,
            dueAt: dueAt,
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: nil,
            progressReviewCadenceDays: nil
        )
        let step = Step(
            id: "p1e-fixed-step",
            sectionID: "p1e-fixed-section",
            title: "Attend the school conference",
            summary: "Fixed point used to prove rendered Time foundation semantics.",
            type: .actionUnit,
            state: .planned,
            owner: actor,
            timing: timing,
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: false,
            successSignals: ["Fixed point appears in Time"],
            actionability: StepActionability(
                action: "Attend the school conference",
                completionDefinition: "The fixed point was attended or intentionally closed.",
                evidenceOfCompletion: ["Local closure receipt"],
                fallbackMicroStep: "Review the conference note",
                contextRequirements: ["fixed time"]
            )
        )
        let section = PlanSection(
            id: "p1e-fixed-section",
            goalID: "p1e-fixed-goal",
            title: "Fixed point",
            summary: "One fixed local commitment.",
            kind: .activeSteps,
            orderIndex: 0,
            steps: [step]
        )
        let plan = GoalPlan(
            id: "p1e-fixed-plan",
            goalID: "p1e-fixed-goal",
            version: goalEnginePlanVersion,
            generatedAt: createdAt,
            summary: "A local fixed point for rendered Time proof.",
            strategy: PlanningStrategy(
                strategyKind: .sequential,
                allowParallelSteps: false,
                maxActiveSteps: 1,
                preferredSectionOrder: [.activeSteps],
                defaultStepType: .actionUnit,
                autoGenerateReviewSection: false,
                preferShortSteps: true,
                revisitCadenceDays: 7
            ),
            sections: [section],
            assumptions: [],
            lint: PlanLintResult(goalID: "p1e-fixed-goal", planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: [])
        )
        return Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: "p1e-fixed-goal",
            revision: 1,
            createdAt: createdAt,
            updatedAt: createdAt,
            state: .active,
            title: "School conference",
            summary: "A local fixed point in the Time foundation.",
            mode: .project,
            relationshipKind: .independent,
            actor: actor,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: ["p1e-rendered-time-foundation"],
            timing: timing,
            planningStrategy: plan.strategy,
            progressStrategy: ProgressStrategy(
                metricKind: .stepCompletion,
                rollupMethod: .ratio,
                targetStepCount: 1,
                targetEvidenceCount: nil,
                targetMinutes: nil,
                supportsUntimedProgress: true,
                countsChildGoals: false,
                countsSupportGoals: false
            ),
            plan: plan,
            lifeGraph: nil
        )
    }
    #endif
}
