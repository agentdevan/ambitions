import AmbitionsDesignSystem
import Foundation

struct RepositoryBackedGoalsService: GoalsServicing {
    let repositories: AppRepositories
    let planner: DeterministicGoalPlanner
    let adaptationService: GoalEngineAdaptationService
    let rescheduleEngine: RescheduleEngine
    let orchestrator: GoalEngineOrchestrator

    init(
        repositories: AppRepositories,
        planner: DeterministicGoalPlanner = DeterministicGoalPlanner(),
        adaptationService: GoalEngineAdaptationService = GoalEngineAdaptationService(),
        rescheduleEngine: RescheduleEngine = RescheduleEngine(),
        orchestrator: GoalEngineOrchestrator = GoalEngineOrchestrator()
    ) {
        self.repositories = repositories
        self.planner = planner
        self.adaptationService = adaptationService
        self.rescheduleEngine = rescheduleEngine
        self.orchestrator = orchestrator
    }

    func loadOverview() async throws -> GoalsOverview {
        let snapshot = try await loadSnapshot()
        return makeOverview(snapshot: snapshot)
    }

    func loadDetail(target: GoalRouteTarget) async throws -> GoalDetailPresentation {
        let snapshot = try await loadSnapshot()
        return try await makeDetail(target: target, snapshot: snapshot)
    }

    func createGoal(_ request: CreateGoalRequest, now: Date) async throws -> CreateGoalResponse {
        let trimmedTitle = request.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedTitle.isEmpty == false else {
            throw GoalsFeatureError.invalidTitle
        }

        let createdAt = Self.iso.string(from: now)
        let goalID = "goal-\(UUID().uuidString.lowercased())"
        let draftID = "draft-\(UUID().uuidString.lowercased())"
        let planSeed = planner.plan(for: trimmedTitle, preferredMode: request.mode)
        let draft = planSeed.blueprint.makeDraft()
        let plan = makeInitialPlan(goalID: goalID, seed: planSeed, generatedAt: createdAt)
        let goal = Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: goalID,
            revision: 1,
            createdAt: createdAt,
            updatedAt: createdAt,
            state: .active,
            title: draft.title,
            summary: draft.summary,
            mode: draft.mode,
            relationshipKind: draft.relationshipKind,
            actor: draft.actor,
            parentGoalID: draft.parentGoalID,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: draft.tags,
            timing: draft.timing,
            planningStrategy: draft.planningStrategy,
            progressStrategy: draft.progressStrategy,
            plan: plan
        )
        let storedDraft = PersistedGoalDraft(
            id: draftID,
            createdAt: createdAt,
            updatedAt: createdAt,
            draft: draft,
            classification: nil,
            clarification: nil,
            stagedPlan: plan,
            assumptions: [],
            blockers: [],
            metadata: nil,
            plannedGoalID: goalID,
            latestResultKind: .planned
        )

        try await repositories.goals.saveGoals([goal])
        try await repositories.drafts.saveDrafts([storedDraft])

        return CreateGoalResponse(
            target: GoalRouteTarget(goalID: goalID, draftID: draftID),
            blueprint: planSeed.blueprint
        )
    }

    func performAction(_ request: GoalDetailActionRequest, now: Date) async throws -> GoalDetailActionResponse {
        let snapshot = try await loadSnapshot()
        let detail = try resolveDetailContext(target: request.target, snapshot: snapshot)

        switch request.kind {
        case .showSupportMode:
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: detail.supportModeActive ? "Support framing is active" : "Direct ownership is still active",
                    body: detail.supportModeActive
                        ? "\(detail.actorName) remains the owner of execution. Ambitions is framing your role as support, not control."
                        : "This goal is currently framed as your own execution path. Switch to support mode once the engine supports ownership rewriting in detail.",
                    state: detail.supportModeActive ? .selected : .default
                )
            )
        case .showPath:
            return GoalDetailActionResponse(message: nil)
        default:
            return try await performMutation(request: request, detail: detail, now: now)
        }
    }

    func submitClarificationAnswer(_ request: GoalClarificationAnswerRequest, now: Date) async throws -> GoalDetailActionResponse {
        let snapshot = try await loadSnapshot()
        guard let draft = snapshot.drafts.first(where: { $0.id == request.target.draftID || ($0.plannedGoalID != nil && $0.plannedGoalID == request.target.goalID) }) else {
            throw GoalsFeatureError.notFound
        }

        let trimmed = request.answer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Answer still needed",
                    body: "Write the smallest real answer you have. Ambitions will keep the plan provisional rather than inventing one.",
                    state: .warning
                )
            )
        }

        let updatedDraft = materializeDraft(
            from: draft,
            answeredField: request.field,
            answer: trimmed,
            now: now
        )
        try await repositories.drafts.saveDrafts([updatedDraft.draft])
        if let goal = updatedDraft.goal {
            try await repositories.goals.saveGoals([goal])
        }

        return GoalDetailActionResponse(
            message: GoalDetailInlineMessage(
                title: updatedDraft.draft.latestResultKind == .clarificationRequired ? "Clarification saved" : "Plan refreshed",
                body: updatedDraft.message,
                state: updatedDraft.draft.latestResultKind == .clarificationRequired ? .selected : .success
            )
        )
    }
}

struct StubGoalsService: GoalsServicing {
    let overview: GoalsOverview
    let detailScenarios: [String: GoalDetailPresentation]

    init(
        overview: GoalsOverview = PreviewGoalsScenarios.overview,
        detailScenarios: [String: GoalDetailPresentation] = PreviewGoalsScenarios.detailScenarios
    ) {
        self.overview = overview
        self.detailScenarios = detailScenarios
    }

    func loadOverview() async throws -> GoalsOverview {
        overview
    }

    func loadDetail(target: GoalRouteTarget) async throws -> GoalDetailPresentation {
        if let scenario = detailScenarios[target.id] {
            return scenario
        }

        if let fallback = detailScenarios.values.first {
            return fallback
        }

        throw GoalsFeatureError.notFound
    }

    func createGoal(_ request: CreateGoalRequest, now: Date) async throws -> CreateGoalResponse {
        _ = now
        let seed = DeterministicGoalPlanner().plan(for: request.title, preferredMode: request.mode)
        return CreateGoalResponse(
            target: GoalRouteTarget(goalID: "preview-goal", draftID: "preview-draft"),
            blueprint: seed.blueprint
        )
    }

    func performAction(_ request: GoalDetailActionRequest, now: Date) async throws -> GoalDetailActionResponse {
        let title: String
        let body: String
        switch request.kind {
        case .complete:
            title = "Completion captured"
            body = "This interaction is preview-safe here. In the repository-backed service, the same action writes directly into plan evidence and feedback."
        case .switchToUntimed:
            title = "Timing softened"
            body = "This preview keeps the interaction shape intact. The live service removes artificial pressure when the goal can stay untimed."
        case .showSupportMode:
            title = "Support framing"
            body = "Support work stays framed as helpful structure, not ownership over someone else's execution."
        default:
            title = "Replanning signal captured"
            body = "This preview mirrors the same trust-preserving action rail used by the repository-backed service."
        }

        return GoalDetailActionResponse(
            message: GoalDetailInlineMessage(title: title, body: body, state: .selected)
        )
    }

    func submitClarificationAnswer(_ request: GoalClarificationAnswerRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        return GoalDetailActionResponse(
            message: GoalDetailInlineMessage(
                title: "Clarification saved",
                body: "Preview mode keeps the write-back interaction intact while the live service recompiles the draft.",
                state: .selected
            )
        )
    }
}

private enum GoalsFeatureError: LocalizedError {
    case notFound
    case missingStep
    case notActionable
    case invalidTitle

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "The requested goal could not be found in native persistence."
        case .missingStep:
            return "This goal does not currently expose an actionable step."
        case .notActionable:
            return "That action is not available for the current goal state."
        case .invalidTitle:
            return "A goal title is required before a native plan can be created."
        }
    }
}

private extension RepositoryBackedGoalsService {
    struct Snapshot {
        let goals: [Goal]
        let drafts: [PersistedGoalDraft]
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]
        let appState: AppStateSnapshot
    }

    struct DetailContext {
        let target: GoalRouteTarget
        let goal: Goal?
        let draft: PersistedGoalDraft?
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]

        var primaryStep: Step? {
            goal?.plan?.sections
                .flatMap(\.steps)
                .first(where: { $0.state != .completed && $0.state != .cancelled })
                ?? draft?.stagedPlan?.sections
                .flatMap(\.steps)
                .first(where: { $0.state != .completed && $0.state != .cancelled })
        }

        var actorName: String {
            goal?.actor.displayName ?? draft?.draft.actor.displayName ?? "someone else"
        }

        var supportModeActive: Bool {
            if goal?.mode == .delegatedSupport || draft?.draft.mode == .delegatedSupport {
                return true
            }
            if goal?.relationshipKind == .support || draft?.draft.relationshipKind == .support {
                return true
            }
            return goal?.actor.ownership != .self || draft?.draft.actor.ownership != .self
        }
    }

    func makeInitialPlan(goalID: String, seed: DeterministicGoalPlanSeed, generatedAt: String) -> GoalPlan {
        let planID = "plan-\(goalID)"
        let sectionID = "section-\(goalID)-active"
        let steps = seed.steps.enumerated().map { index, template in
            template.makeStep(
                sectionID: sectionID,
                owner: seed.blueprint.actor,
                dependencyStepIDs: index == 0 ? [] : [goalScopedStepID(goalID: goalID, templateID: seed.steps[index - 1].id)]
            )
        }.enumerated().map { index, step in
            Step(
                id: goalScopedStepID(goalID: goalID, templateID: seed.steps[index].id),
                sectionID: step.sectionID,
                title: step.title,
                summary: step.summary,
                type: step.type,
                state: step.state,
                owner: step.owner,
                timing: step.timing,
                dependencyStepIDs: step.dependencyStepIDs,
                isOptional: step.isOptional,
                isRepeatable: step.isRepeatable,
                evidenceRequired: step.evidenceRequired,
                successSignals: step.successSignals,
                actionability: step.actionability
            )
        }

        let section = PlanSection(
            id: sectionID,
            goalID: goalID,
            title: "Initial micro-plan",
            summary: "Deterministic local first-pass planning.",
            kind: .activeSteps,
            orderIndex: 0,
            steps: steps
        )
        let provisional = GoalPlan(
            id: planID,
            goalID: goalID,
            version: goalEnginePlanVersion,
            generatedAt: generatedAt,
            summary: "Three conservative first steps generated locally.",
            strategy: seed.blueprint.makeDraft().planningStrategy,
            sections: [section],
            assumptions: [],
            lint: PlanLintResult(goalID: goalID, planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: [])
        )

        return GoalPlan(
            id: provisional.id,
            goalID: provisional.goalID,
            version: provisional.version,
            generatedAt: provisional.generatedAt,
            summary: provisional.summary,
            strategy: provisional.strategy,
            sections: provisional.sections,
            assumptions: provisional.assumptions,
            lint: GoalContractValidator.lint(plan: provisional)
        )
    }

    func goalScopedStepID(goalID: String, templateID: String) -> String {
        "\(goalID)-\(templateID)"
    }

    func loadSnapshot() async throws -> Snapshot {
        async let goals = repositories.goals.listGoals()
        async let drafts = repositories.drafts.listDrafts()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)
        async let appState = repositories.appState.loadState()

        return try await Snapshot(
            goals: goals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback,
            appState: appState
        )
    }

    func makeOverview(snapshot: Snapshot) -> GoalsOverview {
        let orderedIDs = normalizedPriorityOrder(snapshot: snapshot)
        let manualRanks = Dictionary(uniqueKeysWithValues: orderedIDs.enumerated().map { ($1, $0) })

        let goalItems = snapshot.goals.map { goal in
            makeGoalListItem(
                goal: goal,
                draft: snapshot.drafts.first(where: { $0.plannedGoalID == goal.id }),
                evidence: snapshot.evidence,
                feedback: snapshot.feedback,
                manualRank: manualRanks[goal.id] ?? manualRanks.count
            )
        }

        let draftItems = snapshot.drafts.compactMap { draft -> GoalListItem? in
            guard draft.plannedGoalID == nil else { return nil }
            return makeDraftListItem(draft: draft, manualRank: manualRanks[draft.id] ?? manualRanks.count)
        }

        let items = goalItems + draftItems
        let activeCount = items.filter { $0.renderState == .active || $0.renderState == .starter || $0.renderState == .clarification || $0.renderState == .blocked }.count
        let onHoldCount = items.filter { $0.renderState == .onHold }.count
        let achievedCount = items.filter { $0.renderState == .achieved }.count
        let seeded = snapshot.appState.lastSeedVersion == DemoSeedPipeline.seedVersion

        return GoalsOverview(
            title: "Goals",
            subtitle: seeded
                ? "Your starter portfolio is already reading from native persistence, so Today, Goals, and Habits stay in sync while the account history fills in."
                : "Native goals, drafts, evidence, and feedback are now shaping the roadmap directly inside SwiftUI.",
            contextPills: [
                "\(activeCount) active",
                "\(snapshot.drafts.filter { $0.latestResultKind == .clarificationRequired || $0.latestResultKind == .blocked }.count) need care",
                seeded ? "Starter data loaded" : "Live native data"
            ],
            isSeeded: seeded,
            filterSummaries: [
                GoalsFilterSummary(filter: .active, count: activeCount),
                GoalsFilterSummary(filter: .onHold, count: onHoldCount),
                GoalsFilterSummary(filter: .achieved, count: achievedCount),
            ],
            items: items,
            emptyTitle: "No goals yet",
            emptyMessage: "Once a goal or planning draft exists, this screen will immediately explain the path, not just dump tasks."
        )
    }

    func makeDetail(target: GoalRouteTarget, snapshot: Snapshot) async throws -> GoalDetailPresentation {
        let context = try resolveDetailContext(target: target, snapshot: snapshot)

        if let goalID = context.goal?.id {
            var appState = snapshot.appState
            if appState.lastOpenedGoalID != goalID {
                appState.lastOpenedGoalID = goalID
                try await repositories.appState.saveState(appState)
            }
        }

        return buildDetailPresentation(from: context, appState: snapshot.appState, priorityOrder: normalizedPriorityOrder(snapshot: snapshot))
    }

    func resolveDetailContext(target: GoalRouteTarget, snapshot: Snapshot) throws -> DetailContext {
        let draft = snapshot.drafts.first { draft in
            if let draftID = target.draftID, draft.id == draftID {
                return true
            }
            if let goalID = target.goalID, draft.plannedGoalID == goalID {
                return true
            }
            return false
        }

        let resolvedGoalID = target.goalID ?? draft?.plannedGoalID
        let goal = resolvedGoalID.flatMap { goalID in
            snapshot.goals.first(where: { $0.id == goalID })
        }

        guard goal != nil || draft != nil else {
            throw GoalsFeatureError.notFound
        }

        let evidence = resolvedGoalID.map { goalID in
            snapshot.evidence.filter { $0.goalID == goalID }
        } ?? []

        let feedback = goal.map { currentGoal in
            let stepIDs = Set(currentGoal.plan?.sections.flatMap(\.steps).map(\.id) ?? [])
            return snapshot.feedback.filter { stepIDs.contains($0.stepID) }
        } ?? []

        return DetailContext(target: target, goal: goal, draft: draft, evidence: evidence, feedback: feedback)
    }

    func makeGoalListItem(
        goal: Goal,
        draft: PersistedGoalDraft?,
        evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent],
        manualRank: Int
    ) -> GoalListItem {
        let steps = goal.plan?.sections.flatMap(\.steps) ?? []
        let completed = steps.filter { $0.state == .completed }.count
        let firstActive = steps.first(where: { $0.state != .completed && $0.state != .cancelled })
        let progressValue = steps.isEmpty ? 0.08 : Double(completed) / Double(max(steps.count, 1))
        let renderState = renderState(goal: goal, draft: draft)
        let evidenceCount = evidence.filter { $0.goalID == goal.id }.count
        let frictionCount = feedback.filter { event in
            switch event {
            case .skipped, .confused, .tooBig, .notRelevant, .askedForSmallerVersion:
                return true
            default:
                return false
            }
        }.count
        let urgencyScore = urgencyScore(for: goal.timing, mode: goal.mode)
        let momentumScore = min(0.98, max(0.12, progressValue + Double(evidenceCount) * 0.08 - Double(frictionCount) * 0.04))
        let relevanceScore = min(0.99, max(0.1, urgencyScore * 0.45 + momentumScore * 0.35 + (renderState == .clarification || renderState == .blocked ? 0.2 : 0.05)))

        return GoalListItem(
            id: goal.id,
            target: GoalRouteTarget(goalID: goal.id, draftID: draft?.id),
            title: goal.title,
            subtitle: goal.summary ?? detailSubtitle(for: goal.mode),
            mode: goal.mode,
            renderState: renderState,
            progressValue: progressValue,
            progressLabel: steps.isEmpty ? "Plan forming" : "\(completed)/\(steps.count) steps complete",
            statusLabel: renderState.title,
            timingLabel: timingLabel(for: goal.timing, goalMode: goal.mode),
            nextStepHint: firstActive?.title ?? "Open detail to confirm the next move",
            modeLabel: goal.mode.displayTitle,
            supportLabel: goal.mode == .delegatedSupport ? "Support for \(goal.actor.displayName)" : nil,
            relevanceScore: relevanceScore,
            momentumScore: momentumScore,
            urgencyScore: urgencyScore,
            manualPriorityRank: manualRank,
            updatedAt: goal.updatedAt
        )
    }

    func makeDraftListItem(draft: PersistedGoalDraft, manualRank: Int) -> GoalListItem {
        let renderState: GoalRenderState
        switch draft.latestResultKind {
        case .clarificationRequired:
            renderState = .clarification
        case .blocked:
            renderState = .blocked
        case .starterPlanned:
            renderState = .starter
        default:
            renderState = .active
        }

        let nextHint: String
        if let question = draft.clarification?.questions.first {
            nextHint = question.prompt
        } else if let blocker = draft.blockers.first {
            nextHint = blocker.reason
        } else if let step = draft.stagedPlan?.sections.flatMap(\.steps).first {
            nextHint = step.title
        } else {
            nextHint = "Open detail to finish shaping the path"
        }

        return GoalListItem(
            id: draft.id,
            target: GoalRouteTarget(draftID: draft.id),
            title: draft.draft.title,
            subtitle: draft.draft.summary ?? detailSubtitle(for: draft.draft.mode),
            mode: draft.draft.mode,
            renderState: renderState,
            progressValue: draft.latestResultKind == .starterPlanned ? 0.22 : 0.05,
            progressLabel: renderState == .starter ? "Starter assumptions in play" : "Needs planning input",
            statusLabel: renderState.title,
            timingLabel: timingLabel(for: draft.draft.timing, goalMode: draft.draft.mode),
            nextStepHint: nextHint,
            modeLabel: draft.draft.mode.displayTitle,
            supportLabel: draft.draft.mode == .delegatedSupport ? "Support for \(draft.draft.actor.displayName)" : nil,
            relevanceScore: renderState == .blocked ? 0.92 : 0.78,
            momentumScore: renderState == .starter ? 0.38 : 0.2,
            urgencyScore: renderState == .blocked ? 0.9 : 0.64,
            manualPriorityRank: manualRank,
            updatedAt: draft.updatedAt
        )
    }

    func buildDetailPresentation(from context: DetailContext, appState: AppStateSnapshot, priorityOrder: [String]) -> GoalDetailPresentation {
        let sourceGoal = context.goal
        let sourceDraft = context.draft?.draft
        let effectiveMode = sourceGoal?.mode ?? sourceDraft?.mode ?? .project
        let renderState = renderState(goal: sourceGoal, draft: context.draft)
        let timing = sourceGoal?.timing ?? sourceDraft?.timing ?? GoalTiming(tempo: .untimed, timingType: .logWhenDone, startsOn: nil, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: nil)
        let sections = (sourceGoal?.plan ?? context.draft?.stagedPlan)?.sections ?? []
        let allSteps = sections.flatMap(\.steps)
        let completedCount = allSteps.filter { $0.state == .completed }.count
        let progressValue = allSteps.isEmpty ? (renderState == .starter ? 0.16 : 0.04) : Double(completedCount) / Double(max(allSteps.count, 1))
        let minutes = context.evidence.compactMap(\.minutesInvested).reduce(0, +)
        let evidenceLabel = context.evidence.isEmpty ? "No evidence logged yet" : "\(minutes) minutes of visible evidence"
        let suggestions = Array(allSteps.filter { $0.state != .completed && $0.state != .cancelled }.prefix(3)).map { makeStepItem(step: $0, goalMode: effectiveMode) }
        let pathStages = sections.sorted { $0.orderIndex < $1.orderIndex }.map { section in
            GoalPathStage(
                id: section.id,
                title: section.title,
                summary: section.summary ?? section.kind.rawValue.replacingOccurrences(of: "_", with: " "),
                stepCountLabel: "\(section.steps.count) step\(section.steps.count == 1 ? "" : "s")",
                highlight: section.steps.first(where: { $0.state != .completed && $0.state != .cancelled })?.title,
                state: section.steps.allSatisfy { $0.state == .completed } ? .success : renderState.visualState
            )
        }
        let sectionStates = sections.sorted { $0.orderIndex < $1.orderIndex }.map { section in
            GoalDetailSectionState(
                id: section.id,
                title: section.title,
                summary: section.summary ?? section.kind.rawValue.replacingOccurrences(of: "_", with: " "),
                kindLabel: section.kind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                steps: section.steps.map { makeStepItem(step: $0, goalMode: effectiveMode) }
            )
        }

        return GoalDetailPresentation(
            target: context.target,
            headline: GoalDetailHeadline(
                eyebrow: effectiveMode == .delegatedSupport ? "Support Goal" : "Goal Detail",
                title: sourceGoal?.title ?? sourceDraft?.title ?? "Goal",
                subtitle: sourceGoal?.summary ?? sourceDraft?.summary ?? detailSubtitle(for: effectiveMode),
                renderState: renderState,
                modeLabel: effectiveMode.displayTitle,
                timingLabel: timingLabel(for: timing, goalMode: effectiveMode),
                supportLabel: context.supportModeActive ? "This path is framed around supporting \(context.actorName)." : nil
            ),
            outcome: sourceDraft?.summary ?? sourceGoal?.summary ?? detailSubtitle(for: effectiveMode),
            intent: intentText(mode: effectiveMode, actorName: context.actorName, renderState: renderState),
            progress: GoalDetailProgress(
                label: allSteps.isEmpty ? "Structure forming" : "\(completedCount) of \(allSteps.count) steps landed",
                detail: renderState == .starter
                    ? "Starter-plan assumptions are being treated as temporary scaffolding."
                    : "Progress is reading the real persisted plan and evidence history.",
                value: progressValue,
                evidenceLabel: evidenceLabel
            ),
            timingNote: timingNote(for: timing, goalMode: effectiveMode),
            progressNote: renderState == .clarification
                ? "Clarification comes before decomposition. Ambitions is surfacing the missing information instead of inventing urgency."
                : renderState == .blocked
                    ? "The blocker is kept visible so the path can restart cleanly once the missing input arrives."
                    : effectiveMode == .delegatedSupport
                        ? "Support goals stay non-punitive. Progress reflects what you can support, not what you can force."
                        : "The next step stays small enough to act on without losing the broader path.",
            manualPriorityLabel: manualPriorityLabel(for: context, appState: appState, priorityOrder: priorityOrder),
            assumptions: context.draft?.assumptions.map(\.summary) ?? [],
            suggestions: suggestions,
            pathStages: pathStages,
            sections: sectionStates,
            clarification: clarificationState(from: context.draft),
            blocked: blockedState(from: context.draft),
            evidence: Array(context.evidence.prefix(6)).map(makeEvidenceItem),
            history: Array(context.feedback.prefix(6)).map(makeFeedbackItem),
            actions: detailActions(
                for: renderState,
                primaryStepAvailable: context.primaryStep != nil,
                canSwitchToUntimed: canSwitchToUntimed(mode: effectiveMode, timing: timing),
                supportModeActive: context.supportModeActive
            ),
            primaryStepID: context.primaryStep?.id,
            canSwitchToUntimed: canSwitchToUntimed(mode: effectiveMode, timing: timing),
            supportModeActive: context.supportModeActive,
            defaultLens: context.target.launchContext == .help || renderState == .clarification || renderState == .blocked ? .path : .tasks
        )
    }

    func performMutation(
        request: GoalDetailActionRequest,
        detail: DetailContext,
        now: Date
    ) async throws -> GoalDetailActionResponse {
        if request.kind == .raisePriority || request.kind == .lowerPriority {
            return try await adjustPriority(for: detail, direction: request.kind == .raisePriority ? -1 : 1)
        }

        guard var goal = detail.goal else {
            throw GoalsFeatureError.notActionable
        }

        guard let stepID = request.stepID ?? detail.primaryStep?.id,
              let selectedStep = goal.plan?.sections.flatMap(\.steps).first(where: { $0.id == stepID }) else {
            if request.kind == .switchToUntimed {
                let updatedGoal = updateGoalTiming(goal: goal) { timing in
                    GoalTiming(
                        tempo: .untimed,
                        timingType: .logWhenDone,
                        startsOn: timing.startsOn,
                        dueAt: nil,
                        targetBy: nil,
                        windowStart: nil,
                        windowEnd: nil,
                        suggestedNextAt: nil,
                        repeatEveryDays: timing.repeatEveryDays,
                        progressReviewCadenceDays: timing.progressReviewCadenceDays
                    )
                }
                try await repositories.goals.saveGoals([updatedGoal])
                return GoalDetailActionResponse(
                    message: GoalDetailInlineMessage(
                        title: "Timing softened",
                        body: "This goal now treats progress as log-when-done work instead of carrying fake deadline pressure.",
                        state: .selected
                    )
                )
            }
            throw GoalsFeatureError.missingStep
        }

        let timestamp = Self.iso.string(from: now)
        var history = try await repositories.feedback.listEvents(goalID: goal.id)
        let base = GoalFeedbackEventBase(
            id: "goal-detail-\(request.kind.rawValue)-\(UUID().uuidString)",
            stepID: selectedStep.id,
            occurredAt: timestamp,
            note: note(for: request.kind, step: selectedStep)
        )

        switch request.kind {
        case .complete:
            history.append(.completed(base: base, actualDuration: 25, effortLevel: .medium, confidenceDelta: 0.08))
            try await repositories.feedback.saveEvents(history, goalID: goal.id)
            try await repositories.evidence.saveEvidence([
                ProgressEvidence(
                    id: "evidence-\(UUID().uuidString)",
                    goalID: goal.id,
                    stepID: selectedStep.id,
                    evidenceKind: HabitGoalSemantics.isHabitLike(goal: goal, step: selectedStep) ? .habitCompletion : .stepCompleted,
                    source: .manual,
                    capturedAt: timestamp,
                    progressDelta: 0.18,
                    confidenceDelta: 0.08,
                    minutesInvested: 25,
                    note: "Completed from Goal Detail."
                )
            ])
            if HabitGoalSemantics.isHabitLike(goal: goal, step: selectedStep) {
                let cadenceDays = HabitGoalSemantics.cadenceDays(goal: goal, step: selectedStep)
                goal = update(goal: goal, stepID: selectedStep.id) { step in
                    updatedStep(
                        step,
                        summary: step.summary ?? step.actionability.fallbackMicroStep,
                        timing: HabitGoalSemantics.advancedTiming(from: step.timing, now: now, cadenceDays: cadenceDays)
                    )
                }
            } else {
                goal = update(goal: goal, stepID: selectedStep.id) { step in
                    Step(
                        id: step.id,
                        sectionID: step.sectionID,
                        title: step.title,
                        summary: step.summary,
                        type: step.type,
                        state: .completed,
                        owner: step.owner,
                        timing: step.timing,
                        dependencyStepIDs: step.dependencyStepIDs,
                        isOptional: step.isOptional,
                        isRepeatable: step.isRepeatable,
                        evidenceRequired: step.evidenceRequired,
                        successSignals: step.successSignals,
                        actionability: step.actionability
                    )
                }
            }
            try await repositories.goals.saveGoals([goal])
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: HabitGoalSemantics.isHabitLike(goal: goal, step: selectedStep) ? "Habit logged" : "Completion recorded",
                    body: HabitGoalSemantics.isHabitLike(goal: goal, step: selectedStep)
                        ? "\"\(selectedStep.title)\" now lands in native evidence while staying active as a recurring rhythm."
                        : "\"\(selectedStep.title)\" now lands in native evidence and plan history.",
                    state: .success
                )
            )
        case .delay:
            let decision = rescheduleDecision(for: request.kind, step: selectedStep, history: history, now: now)
            let adjustment = decision?.timingAdjustment ?? .laterToday
            history.append(.delayed(base: base, timingAdjustment: adjustment, date: decision?.suggestedTime))
            if let smaller = decision?.smallerStep {
                history.append(
                    .askedForSmallerVersion(
                        base: GoalFeedbackEventBase(
                            id: "goal-detail-delay-smaller-\(UUID().uuidString)",
                            stepID: selectedStep.id,
                            occurredAt: timestamp,
                            note: smaller.note
                        )
                    )
                )
            }
            try await repositories.feedback.saveEvents(history, goalID: goal.id)
            goal = update(goal: goal, stepID: selectedStep.id) { step in
                updatedStep(
                    step,
                    summary: decision?.smallerStep?.summary ?? step.summary ?? step.actionability.fallbackMicroStep,
                    timing: shiftedTiming(for: step.timing, now: now, adjustment: adjustment)
                )
            }
            try await repositories.goals.saveGoals([goal])
            let deferLine: String = {
                guard let decision, decision.deferRecommendation.indicatesDeferral else { return "" }
                return " The next attempt was deferred to keep pressure realistic."
            }()
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Pressure reduced",
                    body: "The step remains visible, but the timing is gentler now.\(deferLine)",
                    state: .selected
                )
            )
        case .skip:
            history.append(.skipped(base: base, reasonCode: .notNow))
            let decision = rescheduleDecision(for: request.kind, step: selectedStep, history: history, now: now)
            if let adjustment = decision?.timingAdjustment {
                history.append(
                    .delayed(
                        base: GoalFeedbackEventBase(
                            id: "goal-detail-skip-delay-\(UUID().uuidString)",
                            stepID: selectedStep.id,
                            occurredAt: timestamp,
                            note: decision?.rationale
                        ),
                        timingAdjustment: adjustment,
                        date: decision?.suggestedTime
                    )
                )
            }
            if let smaller = decision?.smallerStep {
                history.append(
                    .askedForSmallerVersion(
                        base: GoalFeedbackEventBase(
                            id: "goal-detail-skip-smaller-\(UUID().uuidString)",
                            stepID: selectedStep.id,
                            occurredAt: timestamp,
                            note: smaller.note
                        )
                    )
                )
            }
            try await repositories.feedback.saveEvents(history, goalID: goal.id)
            goal = update(goal: goal, stepID: selectedStep.id) { step in
                updatedStep(
                    step,
                    summary: decision?.smallerStep?.summary ?? step.summary ?? step.actionability.fallbackMicroStep,
                    timing: shiftedTiming(for: step.timing, now: now, adjustment: decision?.timingAdjustment ?? .laterThisWeek)
                )
            }
            try await repositories.goals.saveGoals([goal])
            let deferLine: String = {
                guard let decision, decision.deferRecommendation.indicatesDeferral else { return "" }
                return " The next attempt is intentionally deferred to avoid churn."
            }()
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Moved out of the way",
                    body: "The path stays intact without treating one skipped step like failure.\(deferLine)",
                    state: .warning
                )
            )
        case .markNotRelevant:
            history.append(.notRelevant(base: base))
            try await repositories.feedback.saveEvents(history, goalID: goal.id)
            goal = update(goal: goal, stepID: selectedStep.id) { step in
                Step(
                    id: step.id,
                    sectionID: step.sectionID,
                    title: step.title,
                    summary: step.summary,
                    type: step.type,
                    state: .cancelled,
                    owner: step.owner,
                    timing: step.timing,
                    dependencyStepIDs: step.dependencyStepIDs,
                    isOptional: step.isOptional,
                    isRepeatable: step.isRepeatable,
                    evidenceRequired: step.evidenceRequired,
                    successSignals: step.successSignals,
                    actionability: step.actionability
                )
            }
            try await repositories.goals.saveGoals([goal])
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Relevance updated",
                    body: "That step is no longer pushing the plan forward until a better version replaces it.",
                    state: .warning
                )
            )
        case .askWhyThisMatters:
            history.append(.askedWhyThisMatters(base: base))
            try await repositories.feedback.saveEvents(history, goalID: goal.id)
            let explanation = detail.draft.flatMap { draft in
                adjustmentPayload(draft: draft, goal: goal, step: selectedStep, history: history)?.explanationHook?.explanation
                    ?? createWhyThisMattersExplanation(draft: draft.draft, step: selectedStep).explanation
            } ?? "\(selectedStep.title) matters because it advances \(goal.title.lowercased()) through something observable and finishable."
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Why this matters",
                    body: explanation,
                    state: .selected
                )
            )
        case .askForSmallerStep:
            let decision = rescheduleDecision(for: request.kind, step: selectedStep, history: history, now: now)
            history.append(.askedForSmallerVersion(base: base))
            if let adjustment = decision?.timingAdjustment {
                history.append(
                    .delayed(
                        base: GoalFeedbackEventBase(
                            id: "goal-detail-smaller-delay-\(UUID().uuidString)",
                            stepID: selectedStep.id,
                            occurredAt: timestamp,
                            note: decision?.rationale
                        ),
                        timingAdjustment: adjustment,
                        date: decision?.suggestedTime
                    )
                )
            }
            try await repositories.feedback.saveEvents(history, goalID: goal.id)
            goal = update(goal: goal, stepID: selectedStep.id) { step in
                let timing = decision?.timingAdjustment.map { shiftedTiming(for: step.timing, now: now, adjustment: $0) } ?? step.timing
                return updatedStep(
                    step,
                    summary: decision?.smallerStep?.summary ?? step.actionability.fallbackMicroStep,
                    timing: timing
                )
            }
            try await repositories.goals.saveGoals([goal])
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Smaller version ready",
                    body: decision?.smallerStep?.summary ?? selectedStep.actionability.fallbackMicroStep,
                    state: .selected
                )
            )
        case .breakThisDownSmaller:
            let decision = rescheduleDecision(for: request.kind, step: selectedStep, history: history, now: now)
            history.append(.tooBig(base: base))
            history.append(.askedForSmallerVersion(base: GoalFeedbackEventBase(id: "smaller-\(UUID().uuidString)", stepID: selectedStep.id, occurredAt: timestamp, note: "Break this down smaller.")))
            if let adjustment = decision?.timingAdjustment {
                history.append(
                    .delayed(
                        base: GoalFeedbackEventBase(
                            id: "goal-detail-break-delay-\(UUID().uuidString)",
                            stepID: selectedStep.id,
                            occurredAt: timestamp,
                            note: decision?.rationale
                        ),
                        timingAdjustment: adjustment,
                        date: decision?.suggestedTime
                    )
                )
            }
            try await repositories.feedback.saveEvents(history, goalID: goal.id)
            goal = update(goal: goal, stepID: selectedStep.id) { step in
                let timing = decision?.timingAdjustment.map { shiftedTiming(for: step.timing, now: now, adjustment: $0) } ?? step.timing
                return updatedStep(
                    step,
                    summary: decision?.smallerStep?.summary ?? step.actionability.fallbackMicroStep,
                    timing: timing
                )
            }
            try await repositories.goals.saveGoals([goal])
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Broken down smaller",
                    body: decision?.smallerStep?.summary ?? selectedStep.actionability.fallbackMicroStep,
                    state: .selected
                )
            )
        case .imStuck:
            let decision = rescheduleDecision(for: request.kind, step: selectedStep, history: history, now: now)
            history.append(.confused(base: base, confusionType: .unclearAction))
            if let smaller = decision?.smallerStep {
                history.append(
                    .askedForSmallerVersion(
                        base: GoalFeedbackEventBase(
                            id: "goal-detail-stuck-smaller-\(UUID().uuidString)",
                            stepID: selectedStep.id,
                            occurredAt: timestamp,
                            note: smaller.note
                        )
                    )
                )
            }
            if let adjustment = decision?.timingAdjustment {
                history.append(
                    .delayed(
                        base: GoalFeedbackEventBase(
                            id: "goal-detail-stuck-delay-\(UUID().uuidString)",
                            stepID: selectedStep.id,
                            occurredAt: timestamp,
                            note: decision?.rationale
                        ),
                        timingAdjustment: adjustment,
                        date: decision?.suggestedTime
                    )
                )
            }
            try await repositories.feedback.saveEvents(history, goalID: goal.id)
            goal = update(goal: goal, stepID: selectedStep.id) { step in
                let timing = decision?.timingAdjustment.map { shiftedTiming(for: step.timing, now: now, adjustment: $0) } ?? step.timing
                return updatedStep(
                    step,
                    summary: decision?.smallerStep?.summary ?? step.actionability.fallbackMicroStep,
                    timing: timing
                )
            }
            try await repositories.goals.saveGoals([goal])
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "A calmer next move is ready",
                    body: decision?.smallerStep?.summary ?? selectedStep.actionability.fallbackMicroStep,
                    state: .selected
                )
            )
        case .switchToUntimed:
            history.append(.delayed(base: base, timingAdjustment: .removeDeadline, date: nil))
            try await repositories.feedback.saveEvents(history, goalID: goal.id)
            let updatedGoal = updateGoalTiming(goal: goal) { timing in
                GoalTiming(
                    tempo: .untimed,
                    timingType: .logWhenDone,
                    startsOn: timing.startsOn,
                    dueAt: nil,
                    targetBy: nil,
                    windowStart: nil,
                    windowEnd: nil,
                    suggestedNextAt: nil,
                    repeatEveryDays: timing.repeatEveryDays,
                    progressReviewCadenceDays: timing.progressReviewCadenceDays
                )
            }
            try await repositories.goals.saveGoals([updatedGoal])
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Untimed mode enabled",
                    body: "This goal now tracks progress without deadline pressure. Existing work stays visible, but the urgency language is removed.",
                    state: .selected
                )
            )
        case .showPath, .showSupportMode, .raisePriority, .lowerPriority:
            return GoalDetailActionResponse(message: nil)
        }
    }

    func applyAdaptiveRecommendation(
        goal: Goal,
        draft: PersistedGoalDraft?,
        step: Step,
        history: [GoalFeedbackEvent],
        fallbackTitle: String,
        fallbackBody: String
    ) async throws -> GoalDetailActionResponse {
        guard let draft,
              let adjustment = adjustmentPayload(draft: draft, goal: goal, step: step, history: history) else {
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(title: fallbackTitle, body: fallbackBody, state: .selected)
            )
        }

        let updatedGoal = updatedGoal(goal: goal, step: step, recommendation: adjustment.recommendation)
        if updatedGoal.revision != goal.revision {
            try await repositories.goals.saveGoals([updatedGoal])
        }

        return GoalDetailActionResponse(
            message: message(for: adjustment.recommendation, fallbackTitle: fallbackTitle, fallbackBody: fallbackBody)
        )
    }

    func adjustPriority(for detail: DetailContext, direction: Int) async throws -> GoalDetailActionResponse {
        let snapshot = try await loadSnapshot()
        let identifier = detail.goal?.id ?? detail.draft?.id
        guard let identifier else {
            throw GoalsFeatureError.notFound
        }

        var state = snapshot.appState
        var ordered = normalizedPriorityOrder(snapshot: snapshot)
        guard let currentIndex = ordered.firstIndex(of: identifier) else {
            throw GoalsFeatureError.notFound
        }

        let nextIndex = min(max(0, currentIndex + direction), max(ordered.count - 1, 0))
        if nextIndex != currentIndex {
            ordered.swapAt(currentIndex, nextIndex)
            state.goalPriorityOrder = ordered
            try await repositories.appState.saveState(state)
        }

        let rank = (ordered.firstIndex(of: identifier) ?? currentIndex) + 1
        return GoalDetailActionResponse(
            message: GoalDetailInlineMessage(
                title: "Priority updated",
                body: "This item now sits at manual priority #\(rank). Goals sort will preserve that order when you switch to the Priority lens.",
                state: .selected
            )
        )
    }

    func materializeDraft(
        from existingDraft: PersistedGoalDraft,
        answeredField: MissingFieldKey,
        answer: String,
        now: Date
    ) -> (draft: PersistedGoalDraft, goal: Goal?, message: String) {
        var clarifiedFields = existingDraft.metadata?.context.clarifiedFields ?? [:]
        clarifiedFields[answeredField.rawValue] = answer

        let previousContext = existingDraft.metadata?.context
        let result = orchestrator.compileGoal(
            existingDraft.metadata?.input.rawInput ?? existingDraft.draft.title,
            context: GoalEngineOrchestrationContext(
                actorName: previousContext?.actorName,
                preferredPlanningStrictness: previousContext?.preferredPlanningStrictness ?? .balanced,
                goalOwnerRole: previousContext?.goalOwnerRole,
                supportScope: previousContext?.supportScope,
                deadlineHints: previousContext?.deadlineHints ?? [],
                existingGoalReferences: previousContext?.existingGoalReferences ?? [],
                sourceScreen: previousContext?.sourceScreen,
                sourceFlow: previousContext?.sourceFlow,
                clarifiedFields: Dictionary(uniqueKeysWithValues: clarifiedFields.compactMap { key, value in
                    MissingFieldKey(rawValue: key).map { ($0, value) }
                }),
                referenceNow: Self.iso.string(from: now)
            )
        )

        let updatedAt = Self.iso.string(from: now)
        let draft: PersistedGoalDraft
        let goal: Goal?
        let message: String

        switch result {
        case let .clarificationRequired(required):
            draft = PersistedGoalDraft(
                id: existingDraft.id,
                createdAt: existingDraft.createdAt,
                updatedAt: updatedAt,
                draft: required.draft,
                classification: nil,
                clarification: required.clarification,
                stagedPlan: nil,
                assumptions: required.metadata.reasoning.assumptions,
                blockers: [],
                metadata: required.metadata,
                plannedGoalID: nil,
                latestResultKind: .clarificationRequired
            )
            goal = nil
            message = "The answer was saved, but the planner is still waiting on the remaining missing detail."
        case let .blocked(blocked):
            draft = PersistedGoalDraft(
                id: existingDraft.id,
                createdAt: existingDraft.createdAt,
                updatedAt: updatedAt,
                draft: blocked.draft,
                classification: nil,
                clarification: blocked.clarification,
                stagedPlan: nil,
                assumptions: blocked.metadata.reasoning.assumptions,
                blockers: blocked.blockers,
                metadata: blocked.metadata,
                plannedGoalID: nil,
                latestResultKind: .blocked
            )
            goal = nil
            message = "The answer was saved. The blocker is clearer now, but the draft still needs one real constraint resolved."
        case let .planned(planned):
            let plannedGoalID = existingDraft.plannedGoalID ?? planned.plan.goalID
            draft = PersistedGoalDraft(
                id: existingDraft.id,
                createdAt: existingDraft.createdAt,
                updatedAt: updatedAt,
                draft: planned.draft,
                classification: nil,
                clarification: planned.metadata.clarification,
                stagedPlan: planned.plan,
                assumptions: [],
                blockers: [],
                metadata: planned.metadata,
                plannedGoalID: plannedGoalID,
                latestResultKind: .planned
            )
            goal = Goal(
                schemaVersion: goalEngineSchemaVersion,
                id: plannedGoalID,
                revision: existingDraft.plannedGoalID == nil ? 1 : 2,
                createdAt: existingDraft.createdAt,
                updatedAt: updatedAt,
                state: .active,
                title: planned.draft.title,
                summary: planned.draft.summary,
                mode: planned.draft.mode,
                relationshipKind: planned.draft.relationshipKind,
                actor: planned.draft.actor,
                parentGoalID: planned.draft.parentGoalID,
                childGoalIDs: [],
                supportGoalIDs: [],
                tags: planned.draft.tags,
                timing: planned.draft.timing,
                planningStrategy: planned.draft.planningStrategy,
                progressStrategy: planned.draft.progressStrategy,
                plan: planned.plan
            )
            message = "The clarification unlocked a full plan. Goal Detail is now reading a real persisted path instead of a blocked draft."
        case let .starterPlanned(starter):
            let plannedGoalID = existingDraft.plannedGoalID ?? starter.plan.goalID
            draft = PersistedGoalDraft(
                id: existingDraft.id,
                createdAt: existingDraft.createdAt,
                updatedAt: updatedAt,
                draft: starter.draft,
                classification: nil,
                clarification: starter.clarification,
                stagedPlan: starter.plan,
                assumptions: starter.assumptions,
                blockers: [],
                metadata: starter.metadata,
                plannedGoalID: plannedGoalID,
                latestResultKind: .starterPlanned
            )
            goal = Goal(
                schemaVersion: goalEngineSchemaVersion,
                id: plannedGoalID,
                revision: (existingDraft.plannedGoalID == nil ? 1 : 2),
                createdAt: existingDraft.createdAt,
                updatedAt: updatedAt,
                state: .active,
                title: starter.draft.title,
                summary: starter.draft.summary,
                mode: starter.draft.mode,
                relationshipKind: starter.draft.relationshipKind,
                actor: starter.draft.actor,
                parentGoalID: starter.draft.parentGoalID,
                childGoalIDs: [],
                supportGoalIDs: [],
                tags: starter.draft.tags,
                timing: starter.draft.timing,
                planningStrategy: starter.draft.planningStrategy,
                progressStrategy: starter.draft.progressStrategy,
                plan: starter.plan
            )
            message = "The clarification unlocked a starter plan. The path stays provisional, but it now writes back as a real native goal."
        }

        return (draft, goal, message)
    }

    func updatedGoal(goal: Goal, step: Step, recommendation: GoalReplanRecommendation) -> Goal {
        switch recommendation {
        case let .shrinkStep(_, _, _, _, smallerVersion, fallbackMicroStep):
            return update(goal: goal, stepID: step.id) { current in
                updatedStep(current, summary: "\(smallerVersion) Start with: \(fallbackMicroStep)", timing: current.timing)
            }
        case let .suggestMicroStep(_, _, _, _, microStep):
            return update(goal: goal, stepID: step.id) { current in
                updatedStep(current, summary: microStep, timing: current.timing)
            }
        case let .reviseStep(_, _, _, _, rewriteHints, _, _):
            return update(goal: goal, stepID: step.id) { current in
                updatedStep(current, summary: rewriteHints.first ?? current.summary ?? current.actionability.fallbackMicroStep, timing: current.timing)
            }
        case let .relaxTiming(_, _, _, _, suggestedTimingType, removeDeadline):
            return update(goal: goal, stepID: step.id) { current in
                let timing = removeDeadline
                    ? GoalTiming(
                        tempo: .untimed,
                        timingType: suggestedTimingType,
                        startsOn: current.timing.startsOn,
                        dueAt: nil,
                        targetBy: nil,
                        windowStart: nil,
                        windowEnd: nil,
                        suggestedNextAt: nil,
                        repeatEveryDays: current.timing.repeatEveryDays,
                        progressReviewCadenceDays: current.timing.progressReviewCadenceDays
                    )
                    : current.timing
                return updatedStep(current, summary: current.summary ?? current.actionability.fallbackMicroStep, timing: timing)
            }
        case let .adjustPlanTone(_, _, _, _, toneGuidance):
            return update(goal: goal, stepID: step.id) { current in
                updatedStep(current, summary: toneGuidance.first ?? current.summary ?? current.actionability.fallbackMicroStep, timing: current.timing)
            }
        case let .suggestAlternatePath(_, _, _, _, alternatePath, _):
            return update(goal: goal, stepID: step.id) { current in
                updatedStep(current, summary: alternatePath, timing: current.timing)
            }
        case .requestReclarification, .noChange:
            return goal
        }
    }

    func updatedStep(_ step: Step, summary: String, timing: GoalTiming) -> Step {
        Step(
            id: step.id,
            sectionID: step.sectionID,
            title: step.title,
            summary: summary,
            type: step.type,
            state: step.state,
            owner: step.owner,
            timing: timing,
            dependencyStepIDs: step.dependencyStepIDs,
            isOptional: step.isOptional,
            isRepeatable: step.isRepeatable,
            evidenceRequired: step.evidenceRequired,
            successSignals: step.successSignals,
            actionability: step.actionability
        )
    }

    func message(
        for recommendation: GoalReplanRecommendation,
        fallbackTitle: String,
        fallbackBody: String
    ) -> GoalDetailInlineMessage {
        switch recommendation {
        case let .shrinkStep(_, rationale, _, _, smallerVersion, fallbackMicroStep):
            return GoalDetailInlineMessage(title: fallbackTitle, body: "\(smallerVersion) Start with: \(fallbackMicroStep)\n\n\(rationale)", state: .selected)
        case let .suggestMicroStep(_, rationale, _, _, microStep):
            return GoalDetailInlineMessage(title: fallbackTitle, body: "\(microStep)\n\n\(rationale)", state: .selected)
        case let .reviseStep(_, rationale, _, _, rewriteHints, _, hook):
            return GoalDetailInlineMessage(title: fallbackTitle, body: "\(rewriteHints.first ?? fallbackBody)\n\n\(hook?.explanation ?? rationale)", state: .selected)
        case let .relaxTiming(_, rationale, _, _, _, _):
            return GoalDetailInlineMessage(title: "Timing softened", body: rationale, state: .selected)
        case let .requestReclarification(_, rationale, _, _, questions):
            return GoalDetailInlineMessage(title: "Clarification first", body: ([rationale] + questions).joined(separator: "\n"), state: .warning)
        case let .adjustPlanTone(_, rationale, _, _, toneGuidance):
            return GoalDetailInlineMessage(title: "Tone adjusted", body: ([rationale] + toneGuidance).joined(separator: "\n"), state: .selected)
        case let .suggestAlternatePath(_, rationale, _, _, alternatePath, hook):
            return GoalDetailInlineMessage(title: fallbackTitle, body: "\(alternatePath)\n\n\(hook?.explanation ?? rationale)", state: .selected)
        case .noChange:
            return GoalDetailInlineMessage(title: fallbackTitle, body: fallbackBody, state: .selected)
        }
    }

    func clarificationState(from draft: PersistedGoalDraft?) -> GoalClarificationState? {
        guard draft?.latestResultKind == .clarificationRequired, let clarification = draft?.clarification else {
            return nil
        }

        return GoalClarificationState(
            title: "Clarification needed",
            subtitle: "Ambitions is pausing decomposition until these questions are answered cleanly.",
            questions: clarification.questions.map {
                GoalClarificationQuestionState(
                    id: $0.id,
                    field: $0.field,
                    prompt: $0.prompt,
                    rationale: $0.rationale,
                    gentleDefault: $0.skipSafeDefault,
                    existingAnswer: draft?.metadata?.context.clarifiedFields[$0.field.rawValue]
                )
            }
        )
    }

    func blockedState(from draft: PersistedGoalDraft?) -> GoalBlockedState? {
        guard draft?.latestResultKind == .blocked else { return nil }

        return GoalBlockedState(
            title: "Blocked planning state",
            subtitle: "The planner kept the blocker explicit instead of generating performative tasks.",
            blockers: draft?.blockers.map(\.reason) ?? ["A blocking condition is still unresolved."]
        )
    }

    func normalizedPriorityOrder(snapshot: Snapshot) -> [String] {
        let liveIDs = snapshot.goals.map(\.id) + snapshot.drafts.filter { $0.plannedGoalID == nil }.map(\.id)
        let preserved = snapshot.appState.goalPriorityOrder.filter { liveIDs.contains($0) }
        let missing = liveIDs.filter { preserved.contains($0) == false }
        return preserved + missing
    }

    func manualPriorityLabel(for context: DetailContext, appState: AppStateSnapshot, priorityOrder: [String]) -> String {
        let identifier = context.goal?.id ?? context.draft?.id
        let ordered = appState.goalPriorityOrder.isEmpty ? priorityOrder : appState.goalPriorityOrder
        guard let identifier, let index = ordered.firstIndex(of: identifier) else {
            return "Priority will follow the current portfolio order until you adjust it."
        }
        return "Manual priority #\(index + 1)"
    }

    func detailActions(
        for state: GoalRenderState,
        primaryStepAvailable: Bool,
        canSwitchToUntimed: Bool,
        supportModeActive: Bool
    ) -> [GoalDetailActionState] {
        var actions: [GoalDetailActionState] = [
            GoalDetailActionState(kind: .showPath, title: "Show the path", systemImage: "square.split.2x2", state: .default),
            GoalDetailActionState(kind: .raisePriority, title: "Raise priority", systemImage: "arrow.up.circle", state: .selected),
            GoalDetailActionState(kind: .lowerPriority, title: "Lower priority", systemImage: "arrow.down.circle", state: .default),
        ]

        if primaryStepAvailable, state != .clarification, state != .blocked, state != .achieved {
            actions.append(contentsOf: [
                GoalDetailActionState(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success),
                GoalDetailActionState(kind: .delay, title: "Delay", systemImage: "clock.arrow.circlepath", state: .default),
                GoalDetailActionState(kind: .skip, title: "Skip", systemImage: "forward.fill", state: .warning),
                GoalDetailActionState(kind: .askForSmallerStep, title: "Smaller step", systemImage: "scissors", state: .selected),
                GoalDetailActionState(kind: .breakThisDownSmaller, title: "Break it down", systemImage: "rectangle.split.3x1", state: .selected),
                GoalDetailActionState(kind: .imStuck, title: "I'm stuck", systemImage: "lifepreserver", state: .warning),
                GoalDetailActionState(kind: .askWhyThisMatters, title: "Why this matters", systemImage: "questionmark.circle", state: .default),
                GoalDetailActionState(kind: .markNotRelevant, title: "Not relevant", systemImage: "nosign", state: .warning),
            ])
        }

        if canSwitchToUntimed {
            actions.append(
                GoalDetailActionState(kind: .switchToUntimed, title: "Switch to untimed", systemImage: "calendar.badge.minus", state: .default)
            )
        }

        if supportModeActive {
            actions.append(
                GoalDetailActionState(kind: .showSupportMode, title: "Support mode", systemImage: "person.2.fill", state: .selected)
            )
        }

        return actions
    }

    func renderState(goal: Goal?, draft: PersistedGoalDraft?) -> GoalRenderState {
        if draft?.latestResultKind == .clarificationRequired { return .clarification }
        if draft?.latestResultKind == .blocked { return .blocked }
        if draft?.latestResultKind == .starterPlanned { return .starter }

        switch goal?.state {
        case .paused:
            return .onHold
        case .completed, .archived:
            return .achieved
        default:
            return .active
        }
    }

    func detailSubtitle(for mode: GoalMode) -> String {
        switch mode {
        case .achievement:
            return "Outcome-focused work with a clearer finish line."
        case .project:
            return "A structured build with parallel moving parts."
        case .habit:
            return "A repeatable loop that matters over time."
        case .learning:
            return "Skill growth without fake urgency."
        case .exploration:
            return "A path for learning by testing, not by pretending certainty."
        case .maintenance:
            return "Steady upkeep that works best when it stays calm."
        case .recovery:
            return "Gentle forward motion that should not punish your energy."
        case .delegatedSupport:
            return "Supportive structure for someone else's path."
        }
    }

    func intentText(mode: GoalMode, actorName: String, renderState: GoalRenderState) -> String {
        switch renderState {
        case .clarification:
            return "The system is protecting plan quality by showing what still needs to be clarified."
        case .blocked:
            return "The blocker is explicit so you can resolve the actual constraint instead of performing progress."
        default:
            switch mode {
            case .delegatedSupport:
                return "Support \(actorName) with structure that stays collaborative and non-punitive."
            case .learning, .exploration:
                return "Stay oriented to signal and learning, not just task completion."
            case .recovery:
                return "Keep the next move gentle enough that it still happens."
            default:
                return "Understand the path, the next move, and the evidence that proves it is moving."
            }
        }
    }

    func timingNote(for timing: GoalTiming, goalMode: GoalMode) -> String {
        switch goalMode {
        case .delegatedSupport:
            return "Support goals should suggest windows, not impose pressure."
        default:
            switch timing.tempo {
            case .untimed:
                return "This goal is intentionally untimed, so progress is visible without an artificial countdown."
            case .ongoing:
                return "Cadence matters more than a hard finish line here."
            case .targetWindow:
                return "The window matters, but the path still stays flexible."
            case .deadlineBased:
                return "The deadline is real, but the path should still stay session-sized."
            }
        }
    }

    func makeStepItem(step: Step, goalMode: GoalMode) -> GoalDetailStepItem {
        GoalDetailStepItem(
            id: step.id,
            title: step.title,
            summary: step.summary ?? step.actionability.fallbackMicroStep,
            timingLabel: timingLabel(for: step.timing, goalMode: goalMode),
            statusLabel: step.state.rawValue.capitalized,
            state: stepVisualState(step.state)
        )
    }

    func makeEvidenceItem(_ evidence: ProgressEvidence) -> GoalEvidenceItem {
        GoalEvidenceItem(
            id: evidence.id,
            title: evidence.note ?? "Progress signal recorded",
            subtitle: evidence.evidenceKind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
            timestamp: evidence.capturedAt,
            state: .success
        )
    }

    func makeFeedbackItem(_ feedback: GoalFeedbackEvent) -> GoalFeedbackItem {
        let title: String
        let subtitle: String
        let state: AmbitionVisualState

        switch feedback {
        case let .completed(base, _, _, _):
            title = "Completed"
            subtitle = base.note ?? "Completion captured."
            state = .success
        case let .skipped(base, _):
            title = "Skipped"
            subtitle = base.note ?? "Moved out of the way."
            state = .warning
        case let .delayed(base, _, _):
            title = "Delayed"
            subtitle = base.note ?? "Pressure softened."
            state = .selected
        case let .edited(base, text):
            title = "Rewritten"
            subtitle = text.isEmpty ? (base.note ?? "Step language changed.") : text
            state = .selected
        case let .confused(base, _):
            title = "Stuck signal"
            subtitle = base.note ?? "The next move was unclear."
            state = .warning
        case let .tooBig(base):
            title = "Too big"
            subtitle = base.note ?? "The current step needs to shrink."
            state = .warning
        case let .tooEasy(base):
            title = "Too easy"
            subtitle = base.note ?? "The current step may not generate enough signal."
            state = .default
        case let .notRelevant(base):
            title = "Not relevant"
            subtitle = base.note ?? "The path needs a relevance check."
            state = .warning
        case let .askedForSmallerVersion(base):
            title = "Asked for smaller step"
            subtitle = base.note ?? "A smaller version was requested."
            state = .selected
        case let .askedWhyThisMatters(base):
            title = "Asked why"
            subtitle = base.note ?? "The plan needs a clearer rationale."
            state = .default
        }

        return GoalFeedbackItem(id: feedback.base.id, title: title, subtitle: subtitle, timestamp: feedback.base.occurredAt, state: state)
    }

    func note(for kind: GoalDetailActionKind, step: Step) -> String {
        switch kind {
        case .complete:
            return "Completed from Goal Detail."
        case .delay:
            return "Delayed from Goal Detail."
        case .skip:
            return "Skipped from Goal Detail without punitive language."
        case .askForSmallerStep:
            return "Asked for a smaller version from Goal Detail."
        case .askWhyThisMatters:
            return "Asked why this matters from Goal Detail."
        case .markNotRelevant:
            return "Marked not relevant from Goal Detail."
        case .breakThisDownSmaller:
            return "Asked to break this down smaller."
        case .imStuck:
            return "Marked as stuck from Goal Detail."
        case .showPath, .switchToUntimed, .showSupportMode:
            return step.title
        case .raisePriority:
            return "Raised manual priority from Goal Detail."
        case .lowerPriority:
            return "Lowered manual priority from Goal Detail."
        }
    }

    func rescheduleDecision(
        for kind: GoalDetailActionKind,
        step: Step,
        history: [GoalFeedbackEvent],
        now: Date
    ) -> RescheduleDecision? {
        guard let trigger = rescheduleTrigger(for: kind) else { return nil }
        return rescheduleEngine.decide(
            RescheduleEngineInput(
                stepID: step.id,
                timing: step.timing,
                feedbackHistory: history,
                trigger: trigger,
                fallbackMicroStep: step.actionability.fallbackMicroStep,
                now: now
            )
        )
    }

    func rescheduleTrigger(for kind: GoalDetailActionKind) -> RescheduleTrigger? {
        switch kind {
        case .delay:
            return .delay
        case .skip:
            return .skip
        case .askForSmallerStep, .breakThisDownSmaller:
            return .askForSmallerStep
        case .imStuck:
            return .stuck
        case .complete, .askWhyThisMatters, .markNotRelevant, .showPath, .switchToUntimed, .showSupportMode, .raisePriority, .lowerPriority:
            return nil
        }
    }

    func adjustmentPayload(
        draft: PersistedGoalDraft,
        goal: Goal,
        step: Step,
        history: [GoalFeedbackEvent]
    ) -> GoalAdaptivePlanAdjustmentPayload? {
        guard let currentResult = adaptiveResult(from: draft, goal: goal) else { return nil }

        return adaptationService.recommendPlanAdjustment(
            input: GoalAdaptivePlanInput(
                currentResult: currentResult,
                selectedStep: step,
                feedbackHistory: history
            )
        )
    }

    func adaptiveResult(from draft: PersistedGoalDraft, goal: Goal) -> GoalAdaptivePlanResult? {
        guard let plan = goal.plan ?? draft.stagedPlan else { return nil }

        switch draft.latestResultKind {
        case .planned:
            guard let metadata = draft.metadata else { return nil }
            return .planned(
                GoalPlannedResult(draft: draft.draft, plan: plan, lint: plan.lint, metadata: metadata)
            )
        case .starterPlanned:
            guard let clarification = draft.clarification, let metadata = draft.metadata else { return nil }
            return .starterPlanned(
                GoalStarterPlannedResult(
                    draft: draft.draft,
                    plan: plan,
                    lint: plan.lint,
                    assumptions: draft.assumptions,
                    clarification: clarification,
                    metadata: metadata
                )
            )
        case .clarificationRequired, .blocked, .none:
            return nil
        }
    }

    func canSwitchToUntimed(mode: GoalMode, timing: GoalTiming) -> Bool {
        guard timing.tempo != .untimed else { return false }
        switch mode {
        case .achievement:
            return false
        case .project, .habit, .learning, .exploration, .maintenance, .recovery, .delegatedSupport:
            return true
        }
    }

    func urgencyScore(for timing: GoalTiming, mode: GoalMode) -> Double {
        if mode == .delegatedSupport {
            return timing.suggestedNextAt == nil ? 0.32 : 0.58
        }
        if timing.tempo == .untimed {
            return 0.22
        }

        guard let reference = parseDate(timing.dueAt ?? timing.targetBy ?? timing.windowEnd ?? timing.suggestedNextAt) else {
            return 0.42
        }
        let days = max(0, reference.timeIntervalSinceNow / 86_400)
        if days <= 2 { return 0.96 }
        if days <= 7 { return 0.82 }
        if days <= 21 { return 0.58 }
        return 0.34
    }

    func timingLabel(for timing: GoalTiming, goalMode: GoalMode) -> String {
        switch goalMode {
        case .delegatedSupport:
            return timing.suggestedNextAt == nil ? "Support when helpful" : "Support window open"
        default:
            switch timing.tempo {
            case .untimed:
                return "Untimed"
            case .ongoing:
                return timing.repeatEveryDays.map { "Every \($0) day\($0 == 1 ? "" : "s")" } ?? "Ongoing cadence"
            case .targetWindow:
                return timing.targetBy.map { "Target by \($0)" } ?? "Flexible window"
            case .deadlineBased:
                return timing.dueAt.map { "Due \($0)" } ?? "Deadline-based"
            }
        }
    }

    func shiftedTiming(for timing: GoalTiming, now: Date, adjustment: GoalTimingAdjustment) -> GoalTiming {
        let shiftedDate: Date
        switch adjustment {
        case .laterToday:
            shiftedDate = Calendar.current.date(byAdding: .hour, value: 3, to: now) ?? now
        case .laterThisWeek:
            shiftedDate = Calendar.current.date(byAdding: .day, value: 2, to: now) ?? now
        case .someday, .removeDeadline:
            shiftedDate = Calendar.current.date(byAdding: .day, value: 14, to: now) ?? now
        }

        let shiftedValue = adjustment == .removeDeadline ? nil : Self.iso.string(from: shiftedDate)
        return GoalTiming(
            tempo: adjustment == .removeDeadline ? .untimed : timing.tempo,
            timingType: adjustment == .removeDeadline ? .logWhenDone : .suggestedNext,
            startsOn: timing.startsOn,
            dueAt: adjustment == .removeDeadline ? nil : timing.dueAt,
            targetBy: adjustment == .removeDeadline ? nil : timing.targetBy,
            windowStart: timing.windowStart,
            windowEnd: timing.windowEnd,
            suggestedNextAt: shiftedValue,
            repeatEveryDays: timing.repeatEveryDays,
            progressReviewCadenceDays: timing.progressReviewCadenceDays
        )
    }

    func stepVisualState(_ state: StepLifecycleState) -> AmbitionVisualState {
        switch state {
        case .completed: .success
        case .blocked: .warning
        case .active: .selected
        case .cancelled: .default
        case .planned: .default
        }
    }

    func update(goal: Goal, stepID: String, transform: (Step) -> Step) -> Goal {
        let updatedSections = goal.plan?.sections.map { section in
            PlanSection(
                id: section.id,
                goalID: section.goalID,
                title: section.title,
                summary: section.summary,
                kind: section.kind,
                orderIndex: section.orderIndex,
                steps: section.steps.map { $0.id == stepID ? transform($0) : $0 }
            )
        }

        let updatedPlan = goal.plan.map { plan in
            GoalPlan(
                id: plan.id,
                goalID: plan.goalID,
                version: plan.version,
                generatedAt: plan.generatedAt,
                summary: plan.summary,
                strategy: plan.strategy,
                sections: updatedSections ?? plan.sections,
                assumptions: plan.assumptions,
                lint: plan.lint
            )
        }

        return Goal(
            schemaVersion: goal.schemaVersion,
            id: goal.id,
            revision: goal.revision + 1,
            createdAt: goal.createdAt,
            updatedAt: Self.iso.string(from: .now),
            state: goal.state,
            title: goal.title,
            summary: goal.summary,
            mode: goal.mode,
            relationshipKind: goal.relationshipKind,
            actor: goal.actor,
            parentGoalID: goal.parentGoalID,
            childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs,
            tags: goal.tags,
            timing: goal.timing,
            planningStrategy: goal.planningStrategy,
            progressStrategy: goal.progressStrategy,
            plan: updatedPlan
        )
    }

    func updateGoalTiming(goal: Goal, transform: (GoalTiming) -> GoalTiming) -> Goal {
        let newGoalTiming = transform(goal.timing)
        let updatedSections = goal.plan?.sections.map { section in
            PlanSection(
                id: section.id,
                goalID: section.goalID,
                title: section.title,
                summary: section.summary,
                kind: section.kind,
                orderIndex: section.orderIndex,
                steps: section.steps.map { step in
                    guard step.state != .completed && step.state != .cancelled else { return step }
                    return Step(
                        id: step.id,
                        sectionID: step.sectionID,
                        title: step.title,
                        summary: step.summary,
                        type: step.type,
                        state: step.state,
                        owner: step.owner,
                        timing: GoalTiming(
                            tempo: newGoalTiming.tempo,
                            timingType: newGoalTiming.timingType,
                            startsOn: step.timing.startsOn,
                            dueAt: nil,
                            targetBy: nil,
                            windowStart: nil,
                            windowEnd: nil,
                            suggestedNextAt: newGoalTiming.suggestedNextAt,
                            repeatEveryDays: step.timing.repeatEveryDays,
                            progressReviewCadenceDays: step.timing.progressReviewCadenceDays
                        ),
                        dependencyStepIDs: step.dependencyStepIDs,
                        isOptional: step.isOptional,
                        isRepeatable: step.isRepeatable,
                        evidenceRequired: step.evidenceRequired,
                        successSignals: step.successSignals,
                        actionability: step.actionability
                    )
                }
            )
        }
        let updatedPlan = goal.plan.map { plan in
            GoalPlan(
                id: plan.id,
                goalID: plan.goalID,
                version: plan.version,
                generatedAt: plan.generatedAt,
                summary: plan.summary,
                strategy: plan.strategy,
                sections: updatedSections ?? plan.sections,
                assumptions: plan.assumptions,
                lint: plan.lint
            )
        }

        return Goal(
            schemaVersion: goal.schemaVersion,
            id: goal.id,
            revision: goal.revision + 1,
            createdAt: goal.createdAt,
            updatedAt: Self.iso.string(from: .now),
            state: goal.state,
            title: goal.title,
            summary: goal.summary,
            mode: goal.mode,
            relationshipKind: goal.relationshipKind,
            actor: goal.actor,
            parentGoalID: goal.parentGoalID,
            childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs,
            tags: goal.tags,
            timing: newGoalTiming,
            planningStrategy: goal.planningStrategy,
            progressStrategy: goal.progressStrategy,
            plan: updatedPlan
        )
    }

    func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        return Self.iso.date(from: value) ?? Self.isoFallback.date(from: value)
    }

    static let iso: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let isoFallback: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}
