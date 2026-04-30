import AmbitionsDesignSystem
import Foundation

struct RepositoryBackedGoalsService: GoalsServicing {
    let repositories: AppRepositories
    let planner: DeterministicGoalPlanner
    let adaptationService: GoalEngineAdaptationService
    let rescheduleEngine: any GoalRescheduling
    let orchestrator: any GoalOrchestrating
    let calendarRemindersService: any CalendarRemindersServicing
    let learningService: LearningAnticipationService
    let explainabilityProjector: any GoalExplainabilityProjecting
    let teachingService: any GoalTeachingSignalReading & GoalTeachingSignalCapturing
    let goalIntelligenceService: (any RuntimeGoalIntelligenceServicing)?

    init(
        repositories: AppRepositories,
        planner: DeterministicGoalPlanner = DeterministicGoalPlanner(),
        adaptationService: GoalEngineAdaptationService = GoalEngineAdaptationService(),
        rescheduleEngine: any GoalRescheduling = RescheduleEngine(),
        orchestrator: any GoalOrchestrating = GoalEngineOrchestrator(),
        calendarRemindersService: (any CalendarRemindersServicing)? = nil,
        learningService: LearningAnticipationService = LearningAnticipationService(),
        explainabilityProjector: any GoalExplainabilityProjecting = DefaultGoalExplainabilityProjector(),
        teachingService: (any GoalTeachingSignalReading & GoalTeachingSignalCapturing)? = nil,
        goalIntelligenceService: (any RuntimeGoalIntelligenceServicing)? = nil
    ) {
        let compatibilityTeachingService = DefaultGoalTeachingSignalService(repository: repositories.teaching)
        self.repositories = repositories
        self.planner = planner
        self.adaptationService = adaptationService
        self.rescheduleEngine = rescheduleEngine
        self.orchestrator = orchestrator
        self.calendarRemindersService = calendarRemindersService ?? StubCalendarRemindersService()
        self.learningService = learningService
        self.explainabilityProjector = explainabilityProjector
        self.teachingService = teachingService ?? compatibilityTeachingService
        self.goalIntelligenceService = goalIntelligenceService
    }

    func loadOverview() async throws -> GoalsOverview {
        let snapshot = try await loadSnapshot()
        return try await makeOverview(snapshot: snapshot)
    }

    func loadDetail(target: GoalRouteTarget) async throws -> GoalDetailPresentation {
        let snapshot = try await loadSnapshot()
        return try await makeDetail(target: target, snapshot: snapshot)
    }

    func makePathStagesForTesting(
        pathSummary: LifePathStateSummary?,
        sections: [PlanSection],
        renderState: GoalRenderState
    ) -> [GoalPathStage] {
        makePathStages(
            pathSummary: pathSummary,
            sections: sections,
            renderState: renderState,
            includeSyntheticFallback: true
        )
    }

    func previewCreateGoal(_ request: CreateGoalPreviewRequest, now: Date) async throws -> CreateGoalPreviewState {
        let trimmedTitle = request.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedTitle.isEmpty == false else {
            throw GoalsFeatureError.invalidTitle
        }

        let composedTitle = composerTitle(
            from: trimmedTitle,
            targetDateOverride: request.targetDateOverride
        )
        let referenceNow = DomainTimestamp.string(from: now)
        let result = orchestrator.compileGoal(
            composedTitle,
            context: composerContext(
                entrySource: request.entrySource,
                clarifiedFields: request.clarifiedFields,
                preferredPace: request.preferredPace,
                referenceNow: referenceNow
            )
        )

        switch result {
        case let .planned(planned):
            return makeCreateGoalPreview(
                draft: planned.draft,
                plan: planned.plan,
                metadata: planned.metadata,
                assumptions: [],
                blockers: [],
                resultKind: .planned,
                preferredPace: request.preferredPace,
                entrySource: request.entrySource,
                captureID: request.captureID,
                now: now
            )
        case let .starterPlanned(starter):
            return makeCreateGoalPreview(
                draft: starter.draft,
                plan: starter.plan,
                metadata: starter.metadata,
                assumptions: starter.assumptions,
                blockers: [],
                resultKind: .starterPlanned,
                preferredPace: request.preferredPace,
                entrySource: request.entrySource,
                captureID: request.captureID,
                now: now
            )
        case let .clarificationRequired(required):
            return makeCreateGoalPreview(
                draft: required.draft,
                plan: nil,
                metadata: required.metadata,
                assumptions: required.metadata.reasoning.assumptions,
                blockers: [],
                resultKind: .clarificationRequired,
                preferredPace: request.preferredPace,
                entrySource: request.entrySource,
                captureID: request.captureID,
                now: now
            )
        case let .blocked(blocked):
            return makeCreateGoalPreview(
                draft: blocked.draft,
                plan: nil,
                metadata: blocked.metadata,
                assumptions: blocked.metadata.reasoning.assumptions,
                blockers: blocked.blockers.map(\.reason),
                resultKind: .blocked,
                preferredPace: request.preferredPace,
                entrySource: request.entrySource,
                captureID: request.captureID,
                now: now
            )
        }
    }

    func createGoal(_ request: CreateGoalRequest, now: Date) async throws -> CreateGoalResponse {
        let trimmedTitle = request.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedTitle.isEmpty == false else {
            throw GoalsFeatureError.invalidTitle
        }

        let createdAt = DomainTimestamp.string(from: now)
        let goalID = DomainIdentifier.prefixed("goal")
        let draftID = DomainIdentifier.prefixed("draft")
        let composedTitle = composerTitle(
            from: trimmedTitle,
            targetDateOverride: request.targetDateOverride
        )
        let result = orchestrator.compileGoal(
            composedTitle,
            context: composerContext(
                goalID: goalID,
                entrySource: request.entrySource ?? .goalsCreate,
                clarifiedFields: request.clarifiedFields,
                preferredPace: request.preferredPace ?? .balanced,
                referenceNow: createdAt
            )
        )

        switch result {
        case let .planned(planned):
            let goal = goal(from: planned.draft, plan: planned.plan, id: goalID, createdAt: createdAt, updatedAt: createdAt)
            let storedDraft = storedDraft(
                id: draftID,
                createdAt: createdAt,
                updatedAt: createdAt,
                draft: planned.draft,
                stagedPlan: planned.plan,
                assumptions: [],
                blockers: [],
                metadata: planned.metadata,
                plannedGoalID: goalID,
                resultKind: .planned
            )
            try await repositories.goals.saveGoals([goal])
            try await repositories.drafts.saveDrafts([storedDraft])
            return CreateGoalResponse(target: GoalRouteTarget(goalID: goalID, draftID: draftID), blueprint: blueprint(from: planned.draft), resultKind: .planned, planningEvaluation: planned.plan.evaluation)
        case let .starterPlanned(starter):
            let goal = goal(from: starter.draft, plan: starter.plan, id: goalID, createdAt: createdAt, updatedAt: createdAt)
            let storedDraft = storedDraft(
                id: draftID,
                createdAt: createdAt,
                updatedAt: createdAt,
                draft: starter.draft,
                clarification: starter.clarification,
                stagedPlan: starter.plan,
                assumptions: starter.assumptions,
                blockers: [],
                metadata: starter.metadata,
                plannedGoalID: goalID,
                resultKind: .starterPlanned
            )
            try await repositories.goals.saveGoals([goal])
            try await repositories.drafts.saveDrafts([storedDraft])
            return CreateGoalResponse(target: GoalRouteTarget(goalID: goalID, draftID: draftID), blueprint: blueprint(from: starter.draft), resultKind: .starterPlanned, planningEvaluation: starter.plan.evaluation)
        case let .clarificationRequired(required):
            let storedDraft = storedDraft(
                id: draftID,
                createdAt: createdAt,
                updatedAt: createdAt,
                draft: required.draft,
                clarification: required.clarification,
                stagedPlan: nil,
                assumptions: required.metadata.reasoning.assumptions,
                blockers: [],
                metadata: required.metadata,
                plannedGoalID: nil,
                resultKind: .clarificationRequired
            )
            try await repositories.drafts.saveDrafts([storedDraft])
            return CreateGoalResponse(target: GoalRouteTarget(draftID: draftID), blueprint: blueprint(from: required.draft), resultKind: .clarificationRequired, planningEvaluation: nil)
        case let .blocked(blocked):
            let storedDraft = storedDraft(
                id: draftID,
                createdAt: createdAt,
                updatedAt: createdAt,
                draft: blocked.draft,
                clarification: blocked.clarification,
                stagedPlan: nil,
                assumptions: blocked.metadata.reasoning.assumptions,
                blockers: blocked.blockers,
                metadata: blocked.metadata,
                plannedGoalID: nil,
                resultKind: .blocked
            )
            try await repositories.drafts.saveDrafts([storedDraft])
            return CreateGoalResponse(target: GoalRouteTarget(draftID: draftID), blueprint: blueprint(from: blocked.draft), resultKind: .blocked, planningEvaluation: nil)
        }
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

    func submitExplainabilityCorrection(_ request: GoalExplainabilityCorrectionRequest, now: Date) async throws -> GoalDetailActionResponse {
        let snapshot = try await loadSnapshot()
        let detail = try resolveDetailContext(target: request.target, snapshot: snapshot)
        guard let metadata = detail.draft?.metadata else {
            throw GoalsFeatureError.notActionable
        }

        let goalID = detail.goal?.id ?? detail.draft?.plannedGoalID ?? metadata.context.goalID
        guard let goalID else {
            throw GoalsFeatureError.notActionable
        }

        let signal: GoalTeachingSignal
        if let goalIntelligenceService {
            do {
                signal = try await goalIntelligenceService.captureCorrection(
                    target: request.target,
                    control: request.control,
                    now: now
                )
            } catch RuntimeGoalIntelligenceError.notFound {
                throw GoalsFeatureError.notFound
            } catch RuntimeGoalIntelligenceError.notActionable {
                throw GoalsFeatureError.notActionable
            }
        } else {
            signal = try await teachingService.capture(
                GoalTeachingCaptureRequest(
                    goalID: goalID,
                    capturedAt: DomainTimestamp.string(from: now),
                    kind: request.control.teachingSignalKind,
                    payload: request.control.payload,
                    target: request.control.target,
                    userNote: request.control.subtitle
                ),
                metadata: metadata
            )
        }

        return GoalDetailActionResponse(
            message: GoalDetailInlineMessage(
                title: "Correction captured",
                body: correctionMessage(for: signal),
                state: .selected
            )
        )
    }
}

#if DEBUG
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

    func previewCreateGoal(_ request: CreateGoalPreviewRequest, now: Date) async throws -> CreateGoalPreviewState {
        _ = now
        let seed = DeterministicGoalPlanner().plan(for: request.title, preferredMode: request.mode)
        return CreateGoalPreviewState(
            normalizedTitle: seed.blueprint.title,
            summary: seed.blueprint.summary ?? "A preview-safe local strategy with a believable first pass.",
            modeLabel: seed.blueprint.mode.displayTitle,
            resultKind: .planned,
            renderState: .active,
            selectedPace: request.preferredPace,
            paceOptions: [
                StrategyComposerPaceOptionState(choice: .conservative, title: "Conservative", subtitle: "Preserve room for recovery.", badgeTitle: "More room", state: request.preferredPace == .conservative ? .selected : .default),
                StrategyComposerPaceOptionState(choice: .balanced, title: "Balanced", subtitle: "Keep a believable weekly load.", badgeTitle: "Believable", state: request.preferredPace == .balanced ? .selected : .default),
                StrategyComposerPaceOptionState(choice: .aggressive, title: "Aggressive", subtitle: "Accept tighter pressure to keep the original push.", badgeTitle: "Tighter", state: request.preferredPace == .aggressive ? .selected : .default)
            ],
            feasibility: StrategyComposerFeasibilityState(
                title: "Believable first pass",
                summary: "Preview mode keeps the first path readable without writing to persistence.",
                details: [],
                state: .selected
            ),
            deadlineGuidance: nil,
            pathStages: [
                GoalPathStage(
                    id: "preview-first-pass",
                    title: "First pass",
                    summary: "A lightweight starting path based on the current title.",
                    stepCountLabel: "\(seed.steps.count) step\(seed.steps.count == 1 ? "" : "s")",
                    position: .current,
                    statusLabel: GoalPathStagePosition.current.title,
                    highlight: seed.steps.first?.title,
                    state: .selected
                )
            ],
            milestonePreview: seed.steps.prefix(3).map {
                GoalDetailStepItem(
                    id: $0.id,
                    title: $0.title,
                    summary: $0.summary ?? "Preview step",
                    timingLabel: $0.timing.dueAt ?? $0.timing.targetBy ?? "Flexible",
                    statusLabel: "Planned",
                    state: .default
                )
            },
            clarification: nil,
            blocked: nil,
            trust: StrategyComposerTrustState(
                title: "Trust framing",
                lines: ["Preview bootstrap keeps the composer local and non-persisting."],
                badgeTitle: "Preview safe",
                state: .selected
            ),
            planningEvaluation: nil
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

    func submitExplainabilityCorrection(_ request: GoalExplainabilityCorrectionRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        return GoalDetailActionResponse(
            message: GoalDetailInlineMessage(
                title: "Correction captured",
                body: "Preview mode keeps explainability correction controls visible while the live service writes through teaching persistence.",
                state: .selected
            )
        )
    }
}
#endif

extension GoalsServicing {
    func previewCreateGoal(_ request: CreateGoalPreviewRequest, now: Date) async throws -> CreateGoalPreviewState {
        if let repository = self as? RepositoryBackedGoalsService {
            return try await repository.previewCreateGoal(request, now: now)
        }

        if let snapshotRefreshing = self as? SnapshotRefreshingGoalsService {
            return try await snapshotRefreshing.base.previewCreateGoal(request, now: now)
        }

        if let stub = self as? StubGoalsService {
            return try await stub.previewCreateGoal(request, now: now)
        }

        let planner = DeterministicGoalPlanner()
        let seed = planner.plan(for: request.title, preferredMode: request.mode)
        return CreateGoalPreviewState(
            normalizedTitle: seed.blueprint.title,
            summary: seed.blueprint.summary ?? "Ambitions shaped a lightweight local preview.",
            modeLabel: seed.blueprint.mode.displayTitle,
            resultKind: .planned,
            renderState: .active,
            selectedPace: request.preferredPace,
            paceOptions: [
                StrategyComposerPaceOptionState(choice: .conservative, title: "Conservative", subtitle: "Preserve room.", badgeTitle: "Room", state: request.preferredPace == .conservative ? .selected : .default),
                StrategyComposerPaceOptionState(choice: .balanced, title: "Balanced", subtitle: "Stay believable.", badgeTitle: "Believable", state: request.preferredPace == .balanced ? .selected : .default),
                StrategyComposerPaceOptionState(choice: .aggressive, title: "Aggressive", subtitle: "Accept more pressure.", badgeTitle: "Tighter", state: request.preferredPace == .aggressive ? .selected : .default)
            ],
            feasibility: nil,
            deadlineGuidance: nil,
            pathStages: [],
            milestonePreview: [],
            clarification: nil,
            blocked: nil,
            trust: StrategyComposerTrustState(
                title: "Trust framing",
                lines: ["This fallback preview keeps the composer readable when a specialized preview seam is unavailable."],
                badgeTitle: "Local fallback",
                state: .default
            ),
            planningEvaluation: nil
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
        let captures: [Capture]
        let appState: AppStateSnapshot
    }

    struct DetailContext {
        let target: GoalRouteTarget
        let goal: Goal?
        let draft: PersistedGoalDraft?
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]

        var primaryStep: Step? {
            if let goal {
                return goal.plan?.sections
                    .flatMap(\.steps)
                    .first(where: { $0.state != .completed && $0.state != .cancelled })
            }

            return draft?.stagedPlan?.sections
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

    func goal(
        from draft: GoalDraft,
        plan: GoalPlan,
        id: String,
        createdAt: String,
        updatedAt: String
    ) -> Goal {
        Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: id,
            revision: 1,
            createdAt: createdAt,
            updatedAt: updatedAt,
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
            plan: plan,
            lifeGraph: draft.lifeGraph
        )
    }

    func storedDraft(
        id: String,
        createdAt: String,
        updatedAt: String,
        draft: GoalDraft,
        clarification: GoalOrchestrationClarification? = nil,
        stagedPlan: GoalPlan?,
        assumptions: [PlanAssumption],
        blockers: [GoalPlanningBlocker],
        metadata: GoalOrchestrationMetadata?,
        plannedGoalID: String?,
        resultKind: GoalOrchestrationResultKind
    ) -> PersistedGoalDraft {
        PersistedGoalDraft(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            draft: draft,
            classification: nil,
            clarification: clarification,
            stagedPlan: stagedPlan,
            assumptions: assumptions,
            blockers: blockers,
            metadata: metadata,
            plannedGoalID: plannedGoalID,
            latestResultKind: resultKind
        )
    }

    func blueprint(from draft: GoalDraft) -> GoalBlueprint {
        GoalBlueprint(
            title: draft.title,
            summary: draft.summary,
            mode: draft.mode,
            relationshipKind: draft.relationshipKind,
            actor: draft.actor,
            parentGoalID: draft.parentGoalID,
            tags: draft.tags,
            pace: PlanningPace(goalTempo: draft.timing.tempo),
            targetDate: draft.timing.dueAt ?? draft.timing.targetBy ?? draft.timing.windowEnd,
            repeatEveryDays: draft.timing.repeatEveryDays,
            source: draft.source,
            lifeGraph: draft.lifeGraph
        )
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
        async let captures = repositories.captures.listCaptures()
        async let appState = repositories.appState.loadState()

        return try await Snapshot(
            goals: goals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback,
            captures: captures,
            appState: appState
        )
    }

    func makeOverview(snapshot: Snapshot) async throws -> GoalsOverview {
        let orderedIDs = normalizedPriorityOrder(snapshot: snapshot)
        let manualRanks = Dictionary(uniqueKeysWithValues: orderedIDs.enumerated().map { ($1, $0) })
        let learningSnapshot = learningService.buildSnapshot(
            goals: snapshot.goals,
            evidence: snapshot.evidence,
            feedback: snapshot.feedback,
            now: .now
        )
        let shellSummaries = try await overviewShellSummaries(snapshot: snapshot, now: .now)

        let goalItems = snapshot.goals.map { goal in
            makeGoalListItem(
                goal: goal,
                draft: snapshot.drafts.first(where: { $0.plannedGoalID == goal.id }),
                evidence: snapshot.evidence,
                feedback: snapshot.feedback,
                learningSummary: learningSnapshot.goalSummaries[goal.id],
                underrepresentedSignal: learningSnapshot.underrepresentedGoalSignals.first(where: { $0.goalID == goal.id }),
                manualRank: manualRanks[goal.id] ?? manualRanks.count,
                shellSummary: shellSummaries[goal.id]
            )
        }

        let draftItems = snapshot.drafts.compactMap { draft -> GoalListItem? in
            guard draft.plannedGoalID == nil else { return nil }
            return makeDraftListItem(
                draft: draft,
                manualRank: manualRanks[draft.id] ?? manualRanks.count,
                shellSummary: shellSummaries[draft.id]
            )
        }

        let items = goalItems + draftItems
        let cards = items.map { item in
            makeBoardCard(
                from: item,
                snapshot: snapshot,
                learningSummary: learningSnapshot.goalSummaries[item.target.goalID ?? ""]
            )
        }
        let activeCards = cards.filter { $0.lifecycleState.isCurrentPortfolioState || $0.renderState == .starter }
        let activeDirectionCards = activeCards
            .filter { $0.posture == .active || $0.lifecycleState == .protected }
            .sorted(by: boardPriorityDescriptor)
        let pressuredCards = cards
            .filter { [.atRisk, .crowded, .stalled].contains($0.posture) || $0.lifecycleState == .waiting || $0.lifecycleState == .blocked }
            .sorted(by: boardPriorityDescriptor)
        let recentMovementCards = activeCards
            .sorted(by: recentMovementDescriptor)
            .prefix(3)
        let lowerPriorityCards = cards
            .filter { $0.posture == .lowerPriority || $0.posture == .achieved || $0.renderState == .onHold || $0.renderState == .achieved }
            .sorted(by: boardPriorityDescriptor)
        let heroPrimaryAction = heroPrimaryAction(
            activeDirectionCards: activeDirectionCards,
            pressuredCards: pressuredCards,
            cards: cards
        )
        let oneStepGoals = oneStepGoals(from: snapshot.captures, now: .now)
        let northStars: [NorthStar] = []
        let lifeAreasState = makeLifeAreasState(
            snapshot: snapshot,
            cards: cards,
            northStars: northStars,
            oneStepGoals: oneStepGoals
        )
        let northStarsState = makeNorthStarsRailState(
            northStars: northStars,
            goals: snapshot.goals
        )
        let oneStepGoalsState = makeOneStepGoalsPanelState(
            oneStepGoals: oneStepGoals,
            goals: snapshot.goals
        )
        let weekPressureSummary = makeWeekPressureSummary(
            activeCount: activeCards.count,
            pressuredCount: pressuredCards.count,
            crowdedCount: pressuredCards.filter { $0.posture == .crowded }.count,
            stalledCount: pressuredCards.filter { $0.posture == .stalled }.count
        )
        let archiveSummary = makeArchiveSummary(cards: cards)
        let maturitySummary = makePortfolioMaturitySummary(
            cards: cards,
            oneStepGoals: oneStepGoals,
            archiveSummary: archiveSummary
        )
        let seeded = snapshot.appState.lastSeedVersion == DemoSeedPipeline.seedVersion

        return GoalsOverview(
            hero: makeHeroState(
                seeded: seeded,
                activeDirectionCards: activeDirectionCards,
                pressuredCards: pressuredCards,
                items: items,
                weekPressureSummary: weekPressureSummary
            ),
            heroPrimaryAction: heroPrimaryAction,
            bands: [
                GoalsBoardBand(
                    kind: .activeDirection,
                    title: "Active direction",
                    subtitle: activeDirectionCards.isEmpty
                        ? "The portfolio is quiet right now. The next step is to seed one live ambition."
                        : "The ambitions that are truly alive and still have believable momentum this week.",
                    cards: Array(activeDirectionCards.prefix(4))
                ),
                GoalsBoardBand(
                    kind: .pressure,
                    title: "Pressure points",
                    subtitle: pressuredCards.isEmpty
                        ? "Nothing is loudly off-track right now."
                        : "Where pressure, crowding, or drift is starting to distort the direction board.",
                    cards: Array(pressuredCards.prefix(4))
                ),
                GoalsBoardBand(
                    kind: .recentMovement,
                    title: "Recent movement",
                    subtitle: recentMovementCards.isEmpty
                        ? "Once a goal gets fresh evidence or a clearer step, it will surface here."
                        : "Visible momentum so you can see which ambitions are actually moving.",
                    cards: Array(recentMovementCards)
                )
            ],
            horizonLadder: makeHorizonLadder(
                activeDirectionCards: activeDirectionCards,
                pressuredCards: pressuredCards,
                snapshot: snapshot
            ),
            weekPressureSummary: weekPressureSummary,
            lowerPriority: GoalsLowerPriorityState(
                title: "Archive and quieter goals",
                subtitle: "Parked, completed, and cancelled goals stay part of the progress history without competing with live direction.",
                disclosureTitle: "Show archive",
                cards: lowerPriorityCards
            ),
            lifecycleRail: makeLifecycleRail(cards: cards),
            stateChips: makeStateChips(cards: cards),
            lifeAreas: lifeAreasState,
            northStars: northStarsState,
            oneStepGoals: oneStepGoalsState,
            atlasPreview: makeAtlasPreview(snapshot: snapshot, cards: cards, northStars: northStars, oneStepGoals: oneStepGoals),
            archiveSummary: archiveSummary,
            maturitySummary: maturitySummary,
            items: items,
            isSeeded: seeded,
            emptyTitle: "No goals yet",
            emptyMessage: "Once a goal or planning draft exists, this screen will immediately explain the path, not just dump steps."
        )
    }

    func makeDetail(target: GoalRouteTarget, snapshot: Snapshot) async throws -> GoalDetailPresentation {
        let context = try resolveDetailContext(target: target, snapshot: snapshot)
        let applicableSignals = try await explainabilitySignals(for: context)
        let runtimeIntelligenceContext = try await goalIntelligenceContext(
            for: context,
            primaryStepID: context.primaryStep?.id,
            includeWhyNow: true,
            now: .now
        )

        if let goalID = context.goal?.id {
            var appState = snapshot.appState
            if appState.lastOpenedGoalID != goalID {
                appState.lastOpenedGoalID = goalID
                try await repositories.appState.saveState(appState)
            }
        }

        return buildDetailPresentation(
            from: context,
            appState: snapshot.appState,
            priorityOrder: normalizedPriorityOrder(snapshot: snapshot),
            applicableSignals: applicableSignals,
            runtimeIntelligenceContext: runtimeIntelligenceContext
        )
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

        let feedback: [GoalFeedbackEvent] = goal.map { currentGoal in
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
        learningSummary: GoalLearningSummary?,
        underrepresentedSignal: UnderrepresentedGoalSignal?,
        manualRank: Int,
        shellSummary: GoalShellSummaryState?
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
        let historicalFit = learningSummary?.historicalFit.score ?? 0.5
        let underrepresentedBoost = underrepresentedSignal.map { min(0.12, $0.pressureScore * 0.1) } ?? 0
        let timelineRiskBoost = learningSummary.map { min(0.12, $0.timelineRisk.riskScore * 0.08) } ?? 0
        let relevanceScore = min(
            0.99,
            max(
                0.1,
                urgencyScore * 0.4
                    + momentumScore * 0.28
                    + historicalFit * 0.2
                    + underrepresentedBoost
                    + timelineRiskBoost
                    + (renderState == .clarification || renderState == .blocked ? 0.18 : 0.04)
            )
        )

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
            nextStepHint: firstActive?.title ?? "Open detail to confirm the next step",
            modeLabel: goal.mode.displayTitle,
            supportLabel: goal.mode == .delegatedSupport ? "Support for \(goal.actor.displayName)" : nil,
            relevanceScore: relevanceScore,
            momentumScore: momentumScore,
            urgencyScore: urgencyScore,
            manualPriorityRank: manualRank,
            updatedAt: goal.updatedAt,
            shellSummary: shellSummary
        )
    }

    func makeDraftListItem(
        draft: PersistedGoalDraft,
        manualRank: Int,
        shellSummary: GoalShellSummaryState?
    ) -> GoalListItem {
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
            updatedAt: draft.updatedAt,
            shellSummary: shellSummary
        )
    }

    func overviewShellSummaries(
        snapshot: Snapshot,
        now: Date
    ) async throws -> [String: GoalShellSummaryState] {
        guard let goalIntelligenceService else { return [:] }

        var requestKeys: [String] = []
        var requests: [RuntimeGoalIntelligenceRequest] = []
        requestKeys.reserveCapacity(snapshot.goals.count + snapshot.drafts.count)
        requests.reserveCapacity(snapshot.goals.count + snapshot.drafts.count)

        for goal in snapshot.goals {
            let draft = snapshot.drafts.first(where: { $0.plannedGoalID == goal.id })
            requestKeys.append(goal.id)
            requests.append(
                RuntimeGoalIntelligenceRequest(
                    target: GoalRouteTarget(goalID: goal.id, draftID: draft?.id),
                    primaryStepID: shellPrimaryStepID(goal: goal, draft: draft),
                    includeWhyNow: true
                )
            )
        }

        for draft in snapshot.drafts where draft.plannedGoalID == nil {
            requestKeys.append(draft.id)
            requests.append(
                RuntimeGoalIntelligenceRequest(
                    target: GoalRouteTarget(draftID: draft.id),
                    primaryStepID: shellPrimaryStepID(goal: nil, draft: draft),
                    includeWhyNow: true
                )
            )
        }

        let contexts = try await goalIntelligenceService.loadContexts(requests, now: now)
        let projector = GoalShellSummaryProjector()
        return Dictionary(uniqueKeysWithValues: zip(requestKeys, contexts).compactMap { key, context in
            guard let context else { return nil }
            return (key, projector.makeState(from: context))
        })
    }

    func shellPrimaryStepID(goal: Goal?, draft: PersistedGoalDraft?) -> String? {
        let steps = (goal?.plan ?? draft?.stagedPlan)?.sections.flatMap(\.steps) ?? []
        return steps.first(where: { $0.state != .completed && $0.state != .cancelled })?.id ?? steps.first?.id
    }

    func overviewAttentionPills(items: [GoalListItem]) -> [String] {
        let freshnessAttention = items.filter { item in
            item.shellSummary?.indicators.contains(where: { $0.kind == .freshness && $0.state == .warning }) == true
        }.count
        let contradictionAttention = items.filter { item in
            item.shellSummary?.indicators.contains(where: { $0.kind == .contradiction }) == true
        }.count
        let correctionAttention = items.filter { item in
            item.shellSummary?.indicators.contains(where: { $0.kind == .correction }) == true
        }.count

        return [
            freshnessAttention > 0 ? "\(freshnessAttention) freshness attention" : nil,
            contradictionAttention > 0 ? "\(contradictionAttention) contradiction attention" : nil,
            correctionAttention > 0 ? "\(correctionAttention) taught paths" : nil
        ]
        .compactMap { $0 }
    }

    func makeBoardCard(
        from item: GoalListItem,
        snapshot: Snapshot,
        learningSummary: GoalLearningSummary?
    ) -> GoalsBoardCardState {
        let posture = classifyPosture(for: item, snapshot: snapshot, learningSummary: learningSummary)
        let pathSummary = pathSummary(for: item, snapshot: snapshot)
        let phaseSummary = activeStageTitle(for: pathSummary)
            ?? item.shellSummary?.pathSummary
            ?? item.progressLabel
        let milestoneSummary = milestoneSummary(for: item, pathSummary: pathSummary)
        let sourceGoal = item.target.goalID.flatMap { goalID in snapshot.goals.first(where: { $0.id == goalID }) }
        let sourceDraft = item.target.draftID.flatMap { draftID in snapshot.drafts.first(where: { $0.id == draftID }) }
        let goalEvidence = item.target.goalID.map { goalID in snapshot.evidence.filter { $0.goalID == goalID } } ?? []
        let lifecycleState = portfolioLifecycleState(
            item: item,
            goal: sourceGoal,
            draft: sourceDraft,
            pathSummary: pathSummary,
            learningSummary: learningSummary,
            evidence: goalEvidence
        )
        let proofSummary = proofSummary(for: item, evidence: goalEvidence)
        let nextVisibleStep = nextVisibleStep(for: item, goal: sourceGoal, draft: sourceDraft)
        let weather = weatherState(
            lifecycleState: lifecycleState,
            posture: posture,
            proofSummary: proofSummary,
            nextVisibleStep: nextVisibleStep,
            pathSummary: pathSummary
        )
        let momentumIntegrity = momentumIntegrity(
            lifecycleState: lifecycleState,
            posture: posture,
            proofSummary: proofSummary,
            nextVisibleStep: nextVisibleStep,
            evidence: goalEvidence
        )

        return GoalsBoardCardState(
            id: item.id,
            target: item.target,
            title: item.title,
            subtitle: item.subtitle,
            modeLabel: item.modeLabel,
            posture: posture,
            renderState: item.renderState,
            progressValue: item.progressValue,
            progressLabel: item.progressLabel,
            timingLabel: item.timingLabel,
            weekRelationship: weekRelationship(for: item, learningSummary: learningSummary),
            phaseSummary: phaseSummary,
            milestoneSummary: milestoneSummary,
            pressureSummary: pressureSummary(for: item, posture: posture, learningSummary: learningSummary),
            nextStepHint: item.nextStepHint,
            lifecycleState: lifecycleState,
            weather: weather,
            weatherSummary: weatherSummary(for: weather, lifecycleState: lifecycleState, posture: posture, proofSummary: proofSummary, nextVisibleStep: nextVisibleStep),
            proofSummary: proofSummary,
            nextVisibleStep: nextVisibleStep,
            momentumIntegrity: momentumIntegrity,
            supportLabel: item.supportLabel,
            priorityLabel: "Priority #\(item.manualPriorityRank + 1)",
            manualPriorityRank: item.manualPriorityRank,
            shellSummary: item.shellSummary
        )
    }

    func classifyPosture(
        for item: GoalListItem,
        snapshot: Snapshot,
        learningSummary: GoalLearningSummary?
    ) -> GoalsBoardPosture {
        switch item.renderState {
        case .clarification, .blocked:
            return .atRisk
        case .onHold:
            return .lowerPriority
        case .achieved:
            return .achieved
        case .starter, .active:
            break
        }

        let freshnessWarning = item.shellSummary?.indicators.contains(where: { $0.kind == .freshness && $0.state == .warning }) == true
        let contradictionFlag = item.shellSummary?.indicators.contains(where: { $0.kind == .contradiction }) == true
        let pathSummary = pathSummary(for: item, snapshot: snapshot)
        let blockedPath = pathSummary?.blockedPrerequisites.isEmpty == false
            || (pathSummary?.readiness.gapCount ?? 0) > 0
        let timelineRisk = learningSummary?.timelineRisk.riskScore ?? 0
        let driftCount = learningSummary?.driftTriggers.count ?? 0

        if freshnessWarning || contradictionFlag || blockedPath {
            return .atRisk
        }

        if item.manualPriorityRank >= 2 && item.urgencyScore >= 0.48 && item.momentumScore <= 0.56 {
            return .crowded
        }

        if timelineRisk >= 0.85 {
            return .atRisk
        }

        if item.manualPriorityRank == 0 && driftCount == 0 && item.urgencyScore >= 0.55 {
            return .active
        }

        if item.momentumScore < 0.24 {
            return .stalled
        }

        if item.momentumScore < 0.42 && item.manualPriorityRank > 0 {
            return .stalled
        }

        if driftCount > 0 && item.progressValue < 0.35 {
            return .stalled
        }

        return .active
    }

    func pathSummary(for item: GoalListItem, snapshot: Snapshot) -> LifePathStateSummary? {
        pathSummary(for: item.target, snapshot: snapshot)
    }

    func pathSummary(for target: GoalRouteTarget, snapshot: Snapshot) -> LifePathStateSummary? {
        if let goalID = target.goalID,
           let goal = snapshot.goals.first(where: { $0.id == goalID }) {
            return LifeGraphResolver.pathStateSummary(for: goal)
        }

        if let draftID = target.draftID,
           let draft = snapshot.drafts.first(where: { $0.id == draftID }) {
            return LifeGraphResolver.pathStateSummary(for: draft.draft, plan: draft.stagedPlan)
        }

        return nil
    }

    func milestoneSummary(for item: GoalListItem, pathSummary: LifePathStateSummary?) -> String {
        if let pathSummary {
            let completed = pathSummary.progression.completedMilestoneIDs.count
            let total = pathSummary.progression.totalMilestoneCount
            if total > 0 {
                return "\(completed)/\(total) milestones visible"
            }
        }

        return item.progressLabel
    }

    func weekRelationship(for item: GoalListItem, learningSummary: GoalLearningSummary?) -> String {
        if item.renderState == .clarification || item.renderState == .blocked {
            return "This week needs a clarifying step before more planning."
        }

        if let risk = learningSummary?.timelineRisk.riskScore, risk >= 0.7 {
            return "This week is carrying real deadline pressure."
        }

        if item.manualPriorityRank == 0 {
            return "This week this goal is carrying the strongest directional weight."
        }

        if item.momentumScore >= 0.6 {
            return "This week momentum is visible and worth protecting."
        }

        if item.momentumScore < 0.4 {
            return "This week needs a small visible signal to stay alive."
        }

        return "This week can stay steady without opening Plan."
    }

    func pressureSummary(
        for item: GoalListItem,
        posture: GoalsBoardPosture,
        learningSummary: GoalLearningSummary?
    ) -> String {
        switch posture {
        case .atRisk:
            return learningSummary?.timelineRisk.reasons.first
                ?? item.shellSummary?.explanationSummary
                ?? "Pressure is high enough that this goal needs direct attention."
        case .crowded:
            return "This goal is still alive, but portfolio pressure is squeezing it behind more urgent work."
        case .stalled:
            return learningSummary?.driftTriggers.first?.summary
                ?? "Recent movement is thin, so this goal is starting to drift out of view."
        case .active:
            return item.shellSummary?.explanationSummary
                ?? "The path still has believable momentum."
        case .lowerPriority:
            return "This goal is intentionally quieter right now."
        case .achieved:
            return "This loop is closed and no longer competing for attention."
        }
    }

    func portfolioLifecycleState(
        item: GoalListItem,
        goal: Goal?,
        draft: PersistedGoalDraft?,
        pathSummary: LifePathStateSummary?,
        learningSummary: GoalLearningSummary?,
        evidence: [ProgressEvidence]
    ) -> GoalPortfolioLifecycleState {
        if item.renderState == .blocked || draft?.latestResultKind == .blocked {
            return .blocked
        }

        if item.renderState == .clarification {
            return .active
        }

        if let goal {
            switch goal.state {
            case .completed:
                return .completed
            case .archived:
                return goal.plan?.sections.flatMap(\.steps).contains(where: { $0.state == .completed }) == true ? .previous : .cancelledDropped
            case .paused:
                return .parked
            case .draft:
                return .future
            case .active:
                break
            }

            if goal.plan?.sections.flatMap(\.steps).contains(where: { $0.state == .blocked }) == true ||
                pathSummary?.blockedPrerequisites.isEmpty == false {
                return .blocked
            }

            if hasFutureStart(goal.timing) {
                return .future
            }
        }

        if pathSummary?.readiness.gapCount ?? 0 > 0 {
            return .waiting
        }

        if learningSummary?.timelineRisk.riskScore ?? 0 >= 0.8,
           item.manualPriorityRank == 0 {
            return .protected
        }

        if item.manualPriorityRank == 0,
           item.urgencyScore >= 0.58,
           item.renderState == .active {
            return .protected
        }

        if item.mode == .maintenance || item.mode == .learning || item.mode == .exploration {
            if item.manualPriorityRank > 1 && evidence.isEmpty {
                return .passive
            }
        }

        if item.renderState == .onHold {
            return .passive
        }

        return item.renderState == .starter ? .passive : .active
    }

    func proofSummary(for item: GoalListItem, evidence: [ProgressEvidence]) -> GoalProofSummary {
        let sortedEvidence = evidence.sorted { lhs, rhs in
            (parseDate(lhs.capturedAt) ?? .distantPast) > (parseDate(rhs.capturedAt) ?? .distantPast)
        }
        let count = sortedEvidence.count
        let latest = sortedEvidence.first
        let title: String
        let detail: String
        let visualState: AmbitionVisualState

        if count == 0 {
            title = "No proof yet"
            detail = "Needs evidence"
            visualState = .default
        } else if let latest {
            title = count == 1 ? "1 proof point" : "\(count) proof points"
            detail = "Last proof: \(proofTitle(for: latest))"
            visualState = .selected
        } else {
            title = "Proof building"
            detail = "Receipts available"
            visualState = .selected
        }

        return GoalProofSummary(
            title: title,
            detail: detail,
            count: count,
            latestTitle: latest.map(proofTitle(for:)),
            visualState: visualState
        )
    }

    func nextVisibleStep(for item: GoalListItem, goal: Goal?, draft: PersistedGoalDraft?) -> GoalNextVisibleStep {
        let step = (goal?.plan ?? draft?.stagedPlan)?.sections
            .flatMap(\.steps)
            .first { $0.state != .completed && $0.state != .cancelled }

        if let step {
            let effort = step.actionability.fallbackMicroStep.isEmpty ? nil : step.actionability.fallbackMicroStep
            let timing = nextStepTimingLabel(for: step.timing)
            let proof = step.evidenceRequired ? "proof useful" : nil
            return GoalNextVisibleStep(
                title: step.title,
                detail: [effort, timing, proof].compactMap { $0 }.joined(separator: " · "),
                isAvailable: true
            )
        }

        let hint = item.nextStepHint.trimmingCharacters(in: .whitespacesAndNewlines)
        if hint.isEmpty == false, hint.lowercased().contains("open detail") == false {
            return GoalNextVisibleStep(title: hint, detail: "Ready to clarify", isAvailable: true)
        }

        return GoalNextVisibleStep(title: "Needs a next step", detail: "Ready to clarify", isAvailable: false)
    }

    func weatherState(
        lifecycleState: GoalPortfolioLifecycleState,
        posture: GoalsBoardPosture,
        proofSummary: GoalProofSummary,
        nextVisibleStep: GoalNextVisibleStep,
        pathSummary: LifePathStateSummary?
    ) -> GoalWeatherState {
        if lifecycleState == .protected {
            return .protected
        }
        if lifecycleState == .blocked || posture == .atRisk || pathSummary?.blockedPrerequisites.isEmpty == false {
            return .stormy
        }
        if proofSummary.count == 0 {
            return .foggy
        }
        if nextVisibleStep.isAvailable == false || nextVisibleStep.title.lowercased().contains("clarify") {
            return .cloudy
        }
        return .clear
    }

    func weatherSummary(
        for weather: GoalWeatherState,
        lifecycleState: GoalPortfolioLifecycleState,
        posture: GoalsBoardPosture,
        proofSummary: GoalProofSummary,
        nextVisibleStep: GoalNextVisibleStep
    ) -> String {
        switch weather {
        case .clear:
            return "Proof and the next step are visible."
        case .cloudy:
            return "Progress exists, but the next step needs more shape."
        case .stormy:
            return lifecycleState == .blocked ? "A blocker is visible." : posture == .atRisk ? "Risk is visible." : "Pressure needs attention."
        case .foggy:
            return proofSummary.count == 0 ? "Proof is still missing." : "Clarity is still forming."
        case .protected:
            return "This goal should be defended from distraction."
        }
    }

    func momentumIntegrity(
        lifecycleState: GoalPortfolioLifecycleState,
        posture: GoalsBoardPosture,
        proofSummary: GoalProofSummary,
        nextVisibleStep: GoalNextVisibleStep,
        evidence: [ProgressEvidence]
    ) -> GoalMomentumIntegrity {
        if lifecycleState == .blocked {
            return GoalMomentumIntegrity(title: "Blocked", detail: "Do not treat activity as progress until the blocker moves.", visualState: .warning)
        }
        if lifecycleState == .waiting {
            return GoalMomentumIntegrity(title: "Waiting", detail: "Momentum depends on an outside answer, date, or condition.", visualState: .warning)
        }
        if lifecycleState == .parked {
            return GoalMomentumIntegrity(title: "Parked", detail: "Intentionally quiet for later.", visualState: .default)
        }
        if lifecycleState == .protected {
            return GoalMomentumIntegrity(title: "Kept in view", detail: "Keep the next step visible.", visualState: .selected)
        }
        if proofSummary.count > 0 && nextVisibleStep.isAvailable {
            return GoalMomentumIntegrity(title: "Building proof", detail: "Evidence and a next step both exist.", visualState: .selected)
        }
        if proofSummary.count == 0 && nextVisibleStep.isAvailable {
            return GoalMomentumIntegrity(title: "Needs proof", detail: "The next step is clear; evidence has not landed yet.", visualState: .default)
        }
        if posture == .stalled || evidence.isEmpty {
            return GoalMomentumIntegrity(title: "Losing shape", detail: "Add one concrete next step or proof point.", visualState: .warning)
        }
        return GoalMomentumIntegrity(title: "Clear next step", detail: "Momentum can stay simple.", visualState: .selected)
    }

    func hasFutureStart(_ timing: GoalTiming) -> Bool {
        guard let startsOn = parseDate(timing.startsOn) else { return false }
        return startsOn > Date()
    }

    func nextStepTimingLabel(for timing: GoalTiming) -> String? {
        if let suggested = timing.suggestedNextAt ?? timing.startsOn,
           let date = parseDate(suggested) {
            let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
            if days <= 0 { return "today" }
            if days <= 7 { return "soon" }
            return "later"
        }
        return nil
    }

    func proofTitle(for evidence: ProgressEvidence) -> String {
        if let note = evidence.note?.trimmingCharacters(in: .whitespacesAndNewlines),
           note.isEmpty == false {
            return note
        }

        return switch evidence.evidenceKind {
        case .stepCompleted: "Completed step"
        case .habitCompletion: "Ritual completion"
        case .habitMinimumVersion: "Minimum version"
        case .habitQuickLog: "Quick log"
        case .sessionLogged: "Session logged"
        case .reflectionLogged: "Reflection"
        case .delegatedUpdate: "Delegated update"
        case .observationLogged: "Observation"
        case .milestoneReached: "Milestone reached"
        }
    }

    func makeWeekPressureSummary(
        activeCount: Int,
        pressuredCount: Int,
        crowdedCount: Int,
        stalledCount: Int
    ) -> GoalsWeekPressureSummary {
        let title: String
        let subtitle: String
        let pill: GoalsHeroPillState

        switch pressuredCount {
        case 0:
            title = "Direction pressure is calm"
            subtitle = "The board can stay oriented around active ambitions instead of rescue work."
            pill = GoalsHeroPillState(title: "Calm week", icon: "leaf", state: .success)
        case 1:
            title = "One goal is carrying the week"
            subtitle = "A single pressure point is shaping the board and should stay visible."
            pill = GoalsHeroPillState(title: "Focused pressure", icon: "scope", state: .selected)
        default:
            title = "Pressure is spreading across the board"
            subtitle = "Multiple goals are competing for week-level attention."
            pill = GoalsHeroPillState(title: "Compressed week", icon: "exclamationmark.triangle", state: .warning)
        }

        return GoalsWeekPressureSummary(
            title: title,
            subtitle: subtitle,
            leadingMetric: "\(activeCount) active",
            trailingMetric: "\(crowdedCount + stalledCount) stretching thin",
            pill: pill
        )
    }

    func makeHeroState(
        seeded: Bool,
        activeDirectionCards: [GoalsBoardCardState],
        pressuredCards: [GoalsBoardCardState],
        items: [GoalListItem],
        weekPressureSummary: GoalsWeekPressureSummary
    ) -> GoalsBoardHeroState {
        let dominantTruth: String
        if let primary = activeDirectionCards.first {
            dominantTruth = "\(primary.title) is the clearest live ambition right now."
        } else if let pressured = pressuredCards.first {
            dominantTruth = "\(pressured.title) is shaping the board because pressure is outrunning movement."
        } else {
            dominantTruth = "The board is ready for a new live direction."
        }

        let pressureSummary = pressuredCards.first?.pressureSummary ?? weekPressureSummary.subtitle
        let attentionPills = overviewAttentionPills(items: items).map {
            GoalsHeroPillState(title: $0, icon: "sparkle.magnifyingglass", state: .warning)
        }

        return GoalsBoardHeroState(
            eyebrow: "Direction Board",
            title: "Goals",
            subtitle: seeded
                ? "Starter and live goals are being composed as a direction board instead of a portfolio list."
                : "Live goals, drafts, and evidence are now grouped by direction pressure instead of list sorting.",
            dominantTruth: dominantTruth,
            pressureSummary: pressureSummary,
            contextPills: [
                GoalsHeroPillState(title: weekPressureSummary.leadingMetric, icon: "scope", state: .selected),
                GoalsHeroPillState(title: weekPressureSummary.trailingMetric, icon: "wind", state: pressuredCards.isEmpty ? .default : .warning),
                GoalsHeroPillState(title: seeded ? "Starter data loaded" : "Live native data", icon: "sparkles", state: seeded ? .celebration : .selected)
            ],
            attentionPills: attentionPills
        )
    }

    func heroPrimaryAction(
        activeDirectionCards: [GoalsBoardCardState],
        pressuredCards: [GoalsBoardCardState],
        cards: [GoalsBoardCardState]
    ) -> GoalsBoardPrimaryAction {
        if let atRisk = pressuredCards.first(where: { $0.posture == .atRisk }) {
            return GoalsBoardPrimaryAction(
                kind: .recoverGoal,
                title: "Recover \(atRisk.title)",
                subtitle: atRisk.pressureSummary,
                systemImage: "lifepreserver",
                target: atRisk.target,
                state: .warning
            )
        }

        if let crowded = pressuredCards.first(where: { $0.posture == .crowded }) {
            return GoalsBoardPrimaryAction(
                kind: .refineStrategy,
                title: "Refine \(crowded.title)",
                subtitle: crowded.weekRelationship,
                systemImage: "slider.horizontal.3",
                target: crowded.target,
                state: .selected
            )
        }

        if let primary = activeDirectionCards.first {
            return GoalsBoardPrimaryAction(
                kind: .openGoal,
                title: "Open \(primary.title)",
                subtitle: primary.weekRelationship,
                systemImage: "arrow.up.right.circle",
                target: primary.target,
                state: .selected
            )
        }

        return GoalsBoardPrimaryAction(
            kind: .createGoal,
            title: cards.isEmpty ? "Create your first goal" : "Create another goal",
            subtitle: "Start one live direction instead of growing a passive list.",
            systemImage: "plus.circle",
            target: nil,
            state: .selected
        )
    }

    func makeHorizonLadder(
        activeDirectionCards: [GoalsBoardCardState],
        pressuredCards: [GoalsBoardCardState],
        snapshot: Snapshot
    ) -> GoalsHorizonLadderState {
        let sources = Array((activeDirectionCards + pressuredCards).prefix(4))
        let rungs = sources.compactMap { card -> GoalsHorizonLadderRung? in
            let pathSummary = pathSummary(for: card.target, snapshot: snapshot)
            let completedMilestones = pathSummary?.progression.completedMilestoneIDs.count ?? 0
            let totalMilestones = pathSummary?.progression.totalMilestoneCount ?? 0
            let activeStageTitle = activeStageTitle(for: pathSummary) ?? card.phaseSummary
            let highlight = nextMilestoneTitle(for: pathSummary) ?? card.nextStepHint
            let signalLabel: String
            let state: AmbitionVisualState

            if pathSummary?.blockedPrerequisites.isEmpty == false || (pathSummary?.readiness.gapCount ?? 0) > 0 {
                signalLabel = "Blocked signal visible"
                state = .warning
            } else if card.posture == .atRisk {
                signalLabel = "Pressure is high"
                state = .warning
            } else if card.posture == .active {
                signalLabel = "Path is moving"
                state = .selected
            } else {
                signalLabel = "Needs a smaller step"
                state = .default
            }

            return GoalsHorizonLadderRung(
                id: card.id,
                target: card.target,
                title: card.title,
                summary: activeStageTitle,
                milestoneLabel: totalMilestones > 0 ? "\(completedMilestones)/\(totalMilestones) milestones" : card.milestoneSummary,
                signalLabel: signalLabel,
                highlight: highlight,
                state: state
            )
        }

        return GoalsHorizonLadderState(
            title: "Horizon ladder",
            subtitle: "A shallow read on where the live goals sit in their current phase or path without opening Goal Detail.",
            rungs: rungs
        )
    }

    func makeLifecycleRail(cards: [GoalsBoardCardState]) -> [GoalLifecycleRailSegment] {
        let previousCount = cards.filter { [.completed, .cancelledDropped, .previous, .parked].contains($0.lifecycleState) }.count
        let activeCount = cards.filter(\.lifecycleState.isCurrentPortfolioState).count
        let futureCount = cards.filter { $0.lifecycleState == .future }.count

        return [
            GoalLifecycleRailSegment(
                id: "previous",
                title: "Previous",
                count: previousCount,
                subtitle: previousCount == 0 ? "History will stay visible here" : "Closed, parked, or transformed",
                state: .default
            ),
            GoalLifecycleRailSegment(
                id: "active",
                title: "Active",
                count: activeCount,
                subtitle: activeCount == 0 ? "No live pursuit right now" : "Currently shaping attention",
                state: activeCount == 0 ? .default : .selected
            ),
            GoalLifecycleRailSegment(
                id: "future",
                title: "Future",
                count: futureCount,
                subtitle: futureCount == 0 ? "No scheduled future goals" : "Planned, not active yet",
                state: .default
            )
        ]
    }

    func makeStateChips(cards: [GoalsBoardCardState]) -> [GoalStateChipState] {
        let chipStates: [GoalPortfolioLifecycleState] = [.protected, .waiting, .blocked, .parked, .completed, .cancelledDropped]
        return chipStates.map { state in
            GoalStateChipState(lifecycleState: state, count: cards.filter { $0.lifecycleState == state }.count)
        }
    }

    func makeArchiveSummary(cards: [GoalsBoardCardState]) -> GoalPortfolioArchiveSummary {
        let archiveChips = makeStateChips(cards: cards).filter {
            [.parked, .completed, .cancelledDropped].contains($0.lifecycleState)
        }
        let count = archiveChips.map(\.count).reduce(0, +)
        let learningLines = archiveLearningLines(cards: cards)
        return GoalPortfolioArchiveSummary(
            title: count == 0 ? "Archive is quiet" : "\(count) goals in archive states",
            subtitle: count == 0
                ? "Completed, parked, and cancelled goals will remain part of your progress history."
                : "Completed, parked, and cancelled goals are preserved without being treated as failure.",
            chips: archiveChips,
            learningLines: learningLines
        )
    }

    func makePortfolioMaturitySummary(
        cards: [GoalsBoardCardState],
        oneStepGoals: [OneStepGoal],
        archiveSummary: GoalPortfolioArchiveSummary
    ) -> GoalPortfolioMaturitySummary {
        let liveCards = cards.filter { $0.lifecycleState.isCurrentPortfolioState || $0.renderState == .starter }
        let prooflessLiveCount = liveCards.filter { $0.proofSummary.count == 0 }.count
        let blockedOrWaitingCount = liveCards.filter { [.blocked, .waiting].contains($0.lifecycleState) }.count
        let crowdedOrStalledCount = liveCards.filter { [.crowded, .stalled, .atRisk].contains($0.posture) }.count
        let missingNextStepCount = liveCards.filter { $0.nextVisibleStep.isAvailable == false }.count
        let openOneStepCount = oneStepGoals.filter(\.status.isOpen).count

        let scopeSignal = GoalPortfolioMaturitySignal(
            id: "scope",
            title: liveCards.count <= 3 ? "Scope is readable" : "Scope needs review",
            detail: liveCards.count <= 3
                ? "\(liveCards.count) live ambitions are competing for attention."
                : "\(liveCards.count) live ambitions are active; choose what should stay protected.",
            state: liveCards.count <= 3 ? .selected : .warning
        )
        let stuckWorkSignal = GoalPortfolioMaturitySignal(
            id: "stuck-work",
            title: blockedOrWaitingCount + crowdedOrStalledCount == 0 ? "No stuck work is loud" : "Stuck work is visible",
            detail: stuckWorkDetail(
                blockedOrWaitingCount: blockedOrWaitingCount,
                crowdedOrStalledCount: crowdedOrStalledCount,
                openOneStepCount: openOneStepCount
            ),
            state: blockedOrWaitingCount + crowdedOrStalledCount == 0 ? .selected : .warning
        )
        let proofSignal = GoalPortfolioMaturitySignal(
            id: "proof",
            title: prooflessLiveCount == 0 ? "Proof is visible" : "Proof is thin",
            detail: prooflessLiveCount == 0
                ? "Live ambitions have proof or receipts attached."
                : "\(prooflessLiveCount) live ambitions need a proof point before momentum is easy to trust.",
            state: prooflessLiveCount == 0 ? .selected : .default
        )
        let nextStepSignal = GoalPortfolioMaturitySignal(
            id: "next-step",
            title: missingNextStepCount == 0 ? "Next steps are clear" : "Some next steps need shape",
            detail: missingNextStepCount == 0
                ? "Every live ambition has a current next visible step."
                : "\(missingNextStepCount) live ambitions need one concrete next step before they can carry attention.",
            state: missingNextStepCount == 0 ? .selected : .warning
        )

        let accessibilityValue = [
            scopeSignal.title,
            stuckWorkSignal.title,
            proofSignal.title,
            nextStepSignal.title
        ].joined(separator: ". ")

        return GoalPortfolioMaturitySummary(
            title: "Portfolio maturity",
            subtitle: "A qualitative read on scope, proof, stuck work, and what should happen next.",
            scopeSignal: scopeSignal,
            stuckWorkSignal: stuckWorkSignal,
            proofSignal: proofSignal,
            nextStepSignal: nextStepSignal,
            archiveLearning: archiveSummary.learningLines,
            accessibilityLabel: "Portfolio maturity",
            accessibilityValue: accessibilityValue,
            accessibilityHint: "Review scope, stuck work, proof, and next-step clarity before adding more goals."
        )
    }

    func stuckWorkDetail(
        blockedOrWaitingCount: Int,
        crowdedOrStalledCount: Int,
        openOneStepCount: Int
    ) -> String {
        var parts: [String] = []
        if blockedOrWaitingCount > 0 {
            parts.append("\(blockedOrWaitingCount) waiting or blocked")
        }
        if crowdedOrStalledCount > 0 {
            parts.append("\(crowdedOrStalledCount) crowded or stalled")
        }
        if openOneStepCount > 3 {
            parts.append("\(openOneStepCount) open One-Step Goals")
        }
        return parts.isEmpty ? "No blockers, waiting states, or overloaded standalone Tasks are driving the board." : parts.joined(separator: " · ")
    }

    func archiveLearningLines(cards: [GoalsBoardCardState]) -> [String] {
        let archivedCards = cards.filter {
            [.parked, .completed, .cancelledDropped, .previous].contains($0.lifecycleState)
        }
        guard archivedCards.isEmpty == false else {
            return ["Archive learning will appear after a goal is completed, parked, or closed."]
        }

        return archivedCards.prefix(3).map { card in
            switch card.lifecycleState {
            case .completed:
                return "\(card.title): completed with \(card.proofSummary.title.lowercased())."
            case .cancelledDropped:
                return "\(card.title): closed without being treated as failure."
            case .parked:
                return "\(card.title): parked so attention can stay honest."
            case .previous:
                return "\(card.title): preserved as previous progress."
            default:
                return "\(card.title): kept in history."
            }
        }
    }

    func makeLifeAreasState(
        snapshot: Snapshot,
        cards: [GoalsBoardCardState],
        northStars: [NorthStar],
        oneStepGoals: [OneStepGoal]
    ) -> GoalsLifeAreasOverviewState {
        let cardsByGoalID = Dictionary(uniqueKeysWithValues: cards.compactMap { card in
            card.target.goalID.map { ($0, card) }
        })
        let projection = LifeAreaAtlasProjector().overview(
            from: .init(
                goals: snapshot.goals,
                northStars: northStars,
                oneStepGoals: oneStepGoals,
                maxGoalReferencesPerArea: 3
            )
        )
        let contentAreas = projection.areas.filter(\.counts.hasContent)
        let maxVisibleAreas = 6
        let items = contentAreas.prefix(maxVisibleAreas).map { area in
            let goalReferences = (area.activeGoals + area.parkedGoals)
                .sorted { lhs, rhs in
                    (cardsByGoalID[lhs.id]?.manualPriorityRank ?? Int.max) < (cardsByGoalID[rhs.id]?.manualPriorityRank ?? Int.max)
                }
                .prefix(3)
                .map { goal in
                    let card = cardsByGoalID[goal.id]
                    return GoalAtlasPreviewItem(
                        id: goal.id,
                        title: goal.title,
                        subtitle: card?.nextVisibleStep.title ?? goal.summary ?? "Held in this Life Area",
                        state: card?.lifecycleState.visualState ?? visualState(for: goal.state)
                    )
                }
            return GoalsLifeAreaItemState(
                id: area.id.rawValue,
                title: area.definition.displayName,
                subtitle: area.compactSummary,
                nextFocus: area.nextFocus ?? area.emptyMessage,
                activeGoalCount: area.counts.activeGoalCount,
                parkedGoalCount: area.counts.parkedGoalCount,
                northStarCount: area.counts.northStarCount,
                oneStepGoalCount: area.counts.oneStepGoalCount,
                goalReferences: Array(goalReferences),
                state: visualState(for: area.posture),
                accessibilityLabel: area.accessibility.label,
                accessibilityValue: area.accessibility.value,
                accessibilityHint: "Map and list views are available. \(area.accessibility.hint)"
            )
        }

        return GoalsLifeAreasOverviewState(
            title: "Life Areas",
            subtitle: contentAreas.isEmpty
                ? "Life Areas will fill in as goals, North Stars, and One-Step Goals appear."
                : "Goals, North Stars, and standalone Tasks stay organized by the parts of life they belong to.",
            items: Array(items),
            contentAreaCount: contentAreas.count,
            emptyTitle: projection.emptyTitle,
            emptyMessage: projection.emptyMessage,
            availableZoomModes: GoalsSemanticZoomMode.allCases,
            supportsListFallback: true,
            maxVisibleAreas: maxVisibleAreas,
            accessibilityLabel: projection.accessibility.label,
            accessibilityValue: projection.accessibility.value,
            accessibilityHint: "Map view has a list fallback and never adds a top-level tab."
        )
    }

    func makeNorthStarsRailState(
        northStars: [NorthStar],
        goals: [Goal]
    ) -> GoalsNorthStarsRailState {
        let projection = NorthStarProjector().projection(
            from: NorthStarProjector.Input(
                northStars: northStars,
                goals: goals,
                includeArchived: false,
                maxNorthStarsPerArea: 4
            )
        )
        let items = projection.areas.flatMap { area in
            area.northStars.map { northStar in
                GoalsNorthStarRailItemState(
                    id: northStar.id.rawValue,
                    title: northStar.title,
                    subtitle: northStar.summary ?? northStar.activationReadiness.displayName,
                    lifeAreaLabel: area.definition?.displayName ?? "Area unavailable",
                    postureLabel: northStar.posture.displayName,
                    readinessLabel: northStar.activationReadiness.displayName,
                    suggestedNextAction: northStar.suggestedNextAction ?? "Held without pressure",
                    linkedActiveGoalCount: northStar.linkedActiveGoalCount,
                    canBeShaped: northStar.canBeShaped,
                    shapeIntoGoalLabel: northStar.shapeIntoGoalLabel,
                    state: visualState(for: northStar.posture),
                    accessibilityLabel: northStar.accessibility.label,
                    accessibilityValue: northStar.accessibility.value,
                    accessibilityHint: northStar.accessibility.hint
                )
            }
        }

        return GoalsNorthStarsRailState(
            title: projection.title,
            subtitle: projection.subtitle,
            items: Array(items.prefix(6)),
            totalCount: projection.counts.total,
            emptyTitle: projection.emptyTitle,
            emptyMessage: projection.emptyMessage,
            accessibilityLabel: projection.accessibility.label,
            accessibilityValue: projection.accessibility.value,
            accessibilityHint: projection.accessibility.hint
        )
    }

    func makeOneStepGoalsPanelState(
        oneStepGoals: [OneStepGoal],
        goals: [Goal]
    ) -> GoalsOneStepGoalsPanelState {
        let projection = OneStepGoalProjector().projection(
            from: OneStepGoalProjector.Input(
                oneStepGoals: oneStepGoals,
                goals: goals,
                includeArchived: false,
                maxOneStepGoalsPerArea: 4
            )
        )
        let items = projection.areas.flatMap { area in
            area.oneStepGoals.map { oneStepGoal in
                GoalsOneStepGoalPanelItemState(
                    id: oneStepGoal.id.rawValue,
                    title: oneStepGoal.title,
                    subtitle: oneStepGoal.note ?? oneStepGoal.suggestedNextAction,
                    areaLabel: area.displayName,
                    statusLabel: oneStepGoal.status.displayName,
                    timingLabel: oneStepGoal.timingLabel,
                    suggestedNextAction: oneStepGoal.suggestedNextAction,
                    canPromoteToGoal: oneStepGoal.canPromoteToGoal,
                    canAttachToGoal: oneStepGoal.canAttachToGoal,
                    promoteLabel: "Make this a goal",
                    attachLabel: "Attach to goal",
                    state: visualState(for: oneStepGoal.status),
                    accessibilityLabel: oneStepGoal.accessibility.label,
                    accessibilityValue: oneStepGoal.accessibility.value,
                    accessibilityHint: oneStepGoal.accessibility.hint
                )
            }
        }

        return GoalsOneStepGoalsPanelState(
            title: projection.title,
            subtitle: projection.subtitle,
            items: Array(items.prefix(5)),
            openCount: projection.counts.openCount,
            parkedCount: projection.counts.parked,
            emptyTitle: projection.emptyTitle,
            emptyMessage: projection.emptyMessage,
            accessibilityLabel: projection.accessibility.label,
            accessibilityValue: projection.accessibility.value,
            accessibilityHint: projection.accessibility.hint
        )
    }

    func oneStepGoals(from captures: [Capture], now: Date) -> [OneStepGoal] {
        captures.compactMap { capture -> OneStepGoal? in
            guard capture.linkedGoalID == nil else { return nil }
            switch capture.kind {
            case .oneTimeCommitment, .deadlineTask:
                break
            case .raw, .goalSeed, .goalSupportingTask, .deliverableSeed, .waitingItem, .optionalSomeday, .archiveItem:
                return nil
            }

            return OneStepGoal(
                id: OneStepGoalID(rawValue: "capture.\(capture.id)"),
                title: capture.rawText,
                note: nil,
                lifeAreaID: nil,
                status: oneStepGoalStatus(for: capture),
                timing: OneStepGoalTimingMetadata(
                    dueAt: nil,
                    dueLabel: capture.deadlineText,
                    reminderAt: nil,
                    reminderLabel: nil,
                    reviewAfter: nil
                ),
                source: .capture,
                sourceCaptureID: capture.id,
                createdAt: capture.createdAt,
                updatedAt: capture.updatedAt,
                lastReferencedAt: DomainTimestamp.string(from: now)
            )
        }
    }

    func oneStepGoalStatus(for capture: Capture) -> OneStepGoalStatus {
        switch capture.status {
        case .scheduled:
            return .scheduled
        case .waiting, .delegated:
            return .waiting
        case .optionalSomeday:
            return .parked
        case .archived:
            return .archived
        case .needsTriage, .seed:
            return .reviewLater
        case .actionable, .goalBound:
            return capture.deadlineKind == .hard ? .today : .ready
        }
    }

    func makeAtlasPreview(
        snapshot: Snapshot,
        cards: [GoalsBoardCardState],
        northStars: [NorthStar],
        oneStepGoals: [OneStepGoal]
    ) -> GoalAtlasPreviewState? {
        guard snapshot.goals.isEmpty == false else { return nil }
        let cardsByGoalID = Dictionary(uniqueKeysWithValues: cards.compactMap { card in
            card.target.goalID.map { ($0, card) }
        })
        let overview = LifeAreaAtlasProjector().overview(
            from: .init(
                goals: snapshot.goals,
                northStars: northStars,
                oneStepGoals: oneStepGoals
            )
        )
        let groups = overview.areas
            .filter { $0.counts.hasContent }
            .map { area -> GoalAtlasPreviewGroup in
                let orderedItems = (area.activeGoals + area.parkedGoals)
                    .sorted { lhs, rhs in
                        (cardsByGoalID[lhs.id]?.manualPriorityRank ?? Int.max) < (cardsByGoalID[rhs.id]?.manualPriorityRank ?? Int.max)
                    }
                    .prefix(3)
                    .map { goal in
                        let card = cardsByGoalID[goal.id]
                        return GoalAtlasPreviewItem(
                            id: goal.id,
                            title: goal.title,
                            subtitle: card?.nextVisibleStep.title ?? card?.phaseSummary ?? "Relationship data is still thin.",
                            state: card?.lifecycleState.visualState ?? .default
                        )
                    }
                return GoalAtlasPreviewGroup(
                    id: area.id.rawValue,
                    title: area.definition.displayName,
                    subtitle: "\(area.counts.activeGoalCount + area.counts.parkedGoalCount) goal\(area.counts.activeGoalCount + area.counts.parkedGoalCount == 1 ? "" : "s") connected here",
                    items: Array(orderedItems)
                )
            }
            .prefix(3)

        guard groups.isEmpty == false else { return nil }
        return GoalAtlasPreviewState(
            title: "Goal Atlas preview",
            subtitle: "A lightweight grouping by life area. Full path mapping stays owned by later batches.",
            groups: Array(groups)
        )
    }

    func visualState(for posture: LifeAreaPosture) -> AmbitionVisualState {
        switch posture {
        case .active:
            return .selected
        case .needsAttention:
            return .warning
        case .light, .empty, .unavailable:
            return .default
        }
    }

    func visualState(for posture: NorthStarPosture) -> AmbitionVisualState {
        switch posture {
        case .activeDirection, .readyToShape:
            return .selected
        case .needsReview:
            return .warning
        case .dormant, .parked, .archived:
            return .default
        }
    }

    func visualState(for status: OneStepGoalStatus) -> AmbitionVisualState {
        switch status {
        case .ready, .today:
            return .selected
        case .waiting, .reviewLater:
            return .warning
        case .completed:
            return .success
        case .scheduled, .parked, .archived:
            return .default
        }
    }

    func visualState(for lifecycleState: GoalLifecycleState) -> AmbitionVisualState {
        switch lifecycleState {
        case .active:
            return .selected
        case .completed:
            return .success
        case .paused, .draft, .archived:
            return .default
        }
    }

    func boardPriorityDescriptor(lhs: GoalsBoardCardState, rhs: GoalsBoardCardState) -> Bool {
        if lhs.posture != rhs.posture {
            let order: [GoalsBoardPosture] = [.atRisk, .crowded, .stalled, .active, .lowerPriority, .achieved]
            return (order.firstIndex(of: lhs.posture) ?? order.count) < (order.firstIndex(of: rhs.posture) ?? order.count)
        }

        if lhs.manualPriorityRank != rhs.manualPriorityRank {
            return lhs.manualPriorityRank < rhs.manualPriorityRank
        }

        return lhs.progressValue > rhs.progressValue
    }

    func recentMovementDescriptor(lhs: GoalsBoardCardState, rhs: GoalsBoardCardState) -> Bool {
        if lhs.progressValue == rhs.progressValue {
            return lhs.manualPriorityRank < rhs.manualPriorityRank
        }

        return lhs.progressValue > rhs.progressValue
    }

    func activeStageTitle(for pathSummary: LifePathStateSummary?) -> String? {
        guard let pathSummary else { return nil }
        guard let activeStageID = pathSummary.activeStageID else {
            return pathSummary.orderedStages.first?.title
        }
        return pathSummary.orderedStages.first(where: { $0.id == activeStageID })?.title
    }

    func nextMilestoneTitle(for pathSummary: LifePathStateSummary?) -> String? {
        guard let pathSummary else { return nil }

        for stage in pathSummary.orderedStages {
            let milestones = pathSummary.stageMilestones[stage.id] ?? []
            if let next = milestones.first(where: { pathSummary.progression.completedMilestoneIDs.contains($0.id) == false }) {
                return next.title
            }
        }

        return nil
    }

    func buildDetailPresentation(
        from context: DetailContext,
        appState: AppStateSnapshot,
        priorityOrder: [String],
        applicableSignals: GoalTeachingApplicableSet?,
        runtimeIntelligenceContext: RuntimeGoalIntelligenceContext?
    ) -> GoalDetailPresentation {
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
        let pathSummary = sourceGoal.map(LifeGraphResolver.pathStateSummary(for:)) ?? sourceDraft.map { LifeGraphResolver.pathStateSummary(for: $0, plan: context.draft?.stagedPlan) } ?? nil
        let learningSnapshot = sourceGoal.map {
            learningService.buildSnapshot(
                goals: [$0],
                evidence: context.evidence,
                feedback: context.feedback,
                now: .now
            )
        } ?? .empty
        let whyNow = sourceGoal.flatMap { goal in
            context.primaryStep.map { step in
                learningService.learnedStepInsight(
                    goal: goal,
                    step: step,
                    snapshot: learningSnapshot,
                    now: .now
                ).whyNow
            }
        }
        let explainability = runtimeIntelligenceContext?.explainability ?? context.draft?.metadata.map { metadata in
            explainabilityProjector.makeState(
                metadata: metadata,
                applicableSignals: applicableSignals,
                primaryStepID: context.primaryStep?.id,
                whyNow: whyNow
            )
        }
        let pathStages = makePathStages(
            pathSummary: pathSummary,
            sections: sections,
            renderState: renderState,
            includeSyntheticFallback: true
        )
        let sectionStates = sections.sorted { $0.orderIndex < $1.orderIndex }.map { section in
            GoalDetailSectionState(
                id: section.id,
                title: section.title,
                summary: section.summary ?? section.kind.rawValue.replacingOccurrences(of: "_", with: " "),
                kindLabel: section.kind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                steps: section.steps.map { makeStepItem(step: $0, goalMode: effectiveMode) }
            )
        }
        let progressLabel = allSteps.isEmpty ? "Structure forming" : "\(completedCount) of \(allSteps.count) steps landed"
        let sharedProgressNote = renderState == .clarification
            ? "Clarification comes before decomposition. Ambitions is surfacing the missing information instead of inventing urgency."
            : renderState == .blocked
                ? "The blocker is kept visible so the path can restart cleanly once the missing input arrives."
                : effectiveMode == .delegatedSupport
                    ? "Support goals stay non-punitive. Progress reflects what you can support, not what you can force."
                    : whyNow?.conciseReason ?? "The next step stays small enough to act on without losing the broader path."
        let strategicStatus = strategicStatus(
            renderState: renderState,
            pathSummary: pathSummary,
            progressValue: progressValue,
            progressLabel: progressLabel,
            manualPriorityLabel: manualPriorityLabel(for: context, appState: appState, priorityOrder: priorityOrder),
            supportModeActive: context.supportModeActive,
            whyNow: whyNow?.conciseReason
        )
        let nextMovement = nextMovementState(
            primaryStep: context.primaryStep,
            suggestions: suggestions,
            whyNow: whyNow?.conciseReason,
            goalMode: effectiveMode,
            renderState: renderState
        )
        let trajectory = trajectoryState(
            pathSummary: pathSummary,
            pathStages: pathStages,
            sections: sectionStates,
            evidenceLabel: evidenceLabel,
            timingNote: timingNote(for: timing, goalMode: effectiveMode),
            progressNote: sharedProgressNote
        )
        let recentMovement = recentMovementState(
            evidence: Array(context.evidence.prefix(3)),
            feedback: Array(context.feedback.prefix(3)),
            evidenceLabel: evidenceLabel
        )
        let missionControl = missionControlState(
            context: context,
            title: sourceGoal?.title ?? sourceDraft?.title ?? "Goal",
            renderState: renderState,
            timing: timing,
            pathSummary: pathSummary,
            pathStages: pathStages,
            sections: sectionStates,
            suggestions: suggestions,
            evidenceItems: Array(context.evidence.prefix(6)).map(makeEvidenceItem),
            feedbackItems: Array(context.feedback.prefix(6)).map(makeFeedbackItem),
            nextMovement: nextMovement,
            trajectory: trajectory,
            progressLabel: progressLabel,
            evidenceLabel: evidenceLabel,
            currentTruth: strategicStatus.summary
        )
        let pathIntelligence = context.draft?.metadata.map {
            DefaultPathIntelligenceProjector().project(
                compiledPath: $0.compiledPath,
                resourceGraph: $0.resourceGraph
            )
        }
        let pathBuilder = pathBuilderState(
            pathIntelligence: pathIntelligence,
            pathStages: pathStages,
            sections: sectionStates,
            missionControl: missionControl,
            nextMovement: nextMovement,
            renderState: renderState
        )

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
                label: progressLabel,
                detail: renderState == .starter
                    ? "Starter-plan assumptions are being treated as temporary scaffolding."
                    : "Progress is reading the real persisted plan and evidence history.",
                value: progressValue,
                evidenceLabel: evidenceLabel
            ),
            strategicStatus: strategicStatus,
            nextMovement: nextMovement,
            trajectory: trajectory,
            timingNote: timingNote(for: timing, goalMode: effectiveMode),
            progressNote: sharedProgressNote,
            manualPriorityLabel: manualPriorityLabel(for: context, appState: appState, priorityOrder: priorityOrder),
            assumptions: context.draft?.assumptions.map(\.summary) ?? [],
            suggestions: suggestions,
            pathStages: pathStages,
            sections: sectionStates,
            clarification: clarificationState(from: context.draft),
            blocked: blockedState(from: context.draft),
            evidence: Array(context.evidence.prefix(6)).map(makeEvidenceItem),
            history: Array(context.feedback.prefix(6)).map(makeFeedbackItem),
            recentMovement: recentMovement,
            actions: detailActions(
                for: renderState,
                primaryStepAvailable: context.primaryStep != nil,
                canSwitchToUntimed: canSwitchToUntimed(mode: effectiveMode, timing: timing),
                supportModeActive: context.supportModeActive
            ),
            explainability: explainability,
            primaryStepID: context.primaryStep?.id,
            canSwitchToUntimed: canSwitchToUntimed(mode: effectiveMode, timing: timing),
            supportModeActive: context.supportModeActive,
            defaultLens: context.target.launchContext == .help || renderState == .clarification || renderState == .blocked ? .path : .tasks,
            missionControl: missionControl,
            pathBuilder: pathBuilder
        )
    }

    func pathBuilderState(
        pathIntelligence: PathIntelligenceProjection?,
        pathStages: [GoalPathStage],
        sections: [GoalDetailSectionState],
        missionControl: GoalDetailMissionControlState,
        nextMovement: GoalDetailNextMovement?,
        renderState: GoalRenderState
    ) -> GoalPathBuilderState? {
        guard pathIntelligence != nil || pathStages.isEmpty == false || sections.isEmpty == false else { return nil }

        let phaseStates = pathBuilderPhases(
            pathIntelligence: pathIntelligence,
            pathStages: pathStages,
            sections: sections,
            renderState: renderState
        )
        let forks = pathBuilderForks(from: pathIntelligence)
        let proofRequirements = pathBuilderProofRequirements(
            pathIntelligence: pathIntelligence,
            missionControl: missionControl
        )
        let todayTitle = pathIntelligence?.dailyConnection.nextStepTitle
            ?? nextMovement?.title
            ?? missionControl.primaryNextMove.title
        let todaySummary = pathIntelligence?.dailyConnection.proofHint
            ?? pathIntelligence?.dailyConnection.fallbackHint
            ?? nextMovement?.summary
            ?? missionControl.primaryNextMove.detail
        let breadcrumbLabels = Array((missionControl.breadcrumb.labels + ["Path Builder"]).prefix(4))
        let budget = "Bounded roadmap: \(phaseStates.count) phases, \(forks.count) forks, \(proofRequirements.count) proof checks."

        return GoalPathBuilderState(
            title: "Path Builder",
            subtitle: "A long-range view that still keeps the next step visible.",
            breadcrumbLabels: breadcrumbLabels,
            phases: phaseStates,
            forks: forks,
            proofRequirements: proofRequirements,
            todayConnectionTitle: todayTitle,
            todayConnectionSummary: todaySummary.isEmpty ? "Keep one believable next step visible before widening the roadmap." : todaySummary,
            planConnectionSummary: "Plan should only protect the next believable window; wider changes still need review.",
            decisionReceiptSummary: missionControl.decisions.items.first?.summary
                ?? "Path changes should leave a decision or proof trail before they reshape the plan.",
            roadmapListTitle: "Roadmap list",
            roadmapListSummary: "The same phases are available as a plain list for review.",
            performanceBudgetSummary: budget,
            accessibilityLabel: "Path Builder",
            accessibilityValue: "\(phaseStates.count) phases, \(forks.count) forks, \(proofRequirements.count) proof checks. Next step: \(todayTitle).",
            accessibilityHint: "Review the roadmap as phases, forks, proof, and the next step before changing the path."
        )
    }

    func pathBuilderPhases(
        pathIntelligence: PathIntelligenceProjection?,
        pathStages: [GoalPathStage],
        sections: [GoalDetailSectionState],
        renderState: GoalRenderState
    ) -> [GoalPathBuilderPhaseState] {
        let stageStateByID = Dictionary(uniqueKeysWithValues: pathStages.map { ($0.id, $0) })

        if let pathIntelligence, pathIntelligence.stages.isEmpty == false {
            return pathIntelligence.stages.prefix(6).map { stage in
                let matchingState = stageStateByID[stage.id]
                let dependency = stage.waitingStateSummary
                    ?? stage.dependencySummaries.first
                    ?? stage.prerequisiteHints.first
                    ?? "No blocking dependency visible."
                let proof = pathIntelligence.proofRequirements.first(where: { $0.stageID == stage.id })?.summary
                    ?? stage.readinessHints.first
                    ?? "Proof can be added when this phase creates a visible signal."

                return GoalPathBuilderPhaseState(
                    id: stage.id,
                    title: stage.title,
                    summary: stage.summary,
                    dependencySummary: dependency,
                    proofSummary: proof,
                    statusLabel: matchingState?.statusLabel ?? stage.kind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                    state: matchingState?.state ?? renderState.visualState
                )
            }
        }

        if pathStages.isEmpty == false {
            return pathStages.prefix(6).map { stage in
                GoalPathBuilderPhaseState(
                    id: stage.id,
                    title: stage.title,
                    summary: stage.summary,
                    dependencySummary: stage.highlight ?? "No blocking dependency visible.",
                    proofSummary: "Attach proof when this phase creates a visible signal.",
                    statusLabel: stage.statusLabel,
                    state: stage.state
                )
            }
        }

        return sections.prefix(6).map { section in
            GoalPathBuilderPhaseState(
                id: section.id,
                title: section.title,
                summary: section.summary,
                dependencySummary: section.steps.first?.timingLabel ?? "No blocking dependency visible.",
                proofSummary: section.steps.contains(where: { $0.summary.localizedCaseInsensitiveContains("proof") })
                    ? "This phase already asks for proof."
                    : "Attach proof when this phase creates a visible signal.",
                statusLabel: section.kindLabel,
                state: section.steps.contains(where: { $0.statusLabel.localizedCaseInsensitiveContains("blocked") }) ? .warning : .default
            )
        }
    }

    func pathBuilderForks(from pathIntelligence: PathIntelligenceProjection?) -> [GoalPathBuilderForkState] {
        let comparisons = (pathIntelligence?.forkComparisons ?? []).prefix(3).map { fork in
            GoalPathBuilderForkState(
                id: fork.id,
                title: fork.forkTitle,
                summary: fork.tradeoffSummary,
                basisSummary: fork.comparisonBasis.prefix(2).joined(separator: " "),
                decisionPrompt: fork.decisionPrompt,
                freshnessLabel: freshnessTitle(fork.freshnessLabel),
                state: fork.freshnessLabel == .current ? .selected : .warning
            )
        }

        if comparisons.isEmpty == false {
            return comparisons
        }

        return (pathIntelligence?.futureSelfScenarios ?? [])
            .filter { $0.kind != .continueCurrentPath }
            .prefix(2)
            .map { scenario in
                GoalPathBuilderForkState(
                    id: "path-builder-\(scenario.id)",
                    title: scenario.title,
                    summary: scenario.summary,
                    basisSummary: scenario.notPredictionLabel,
                    decisionPrompt: "Choose, edit, or park this fork from Goal Detail before it shapes Today.",
                    freshnessLabel: "May Need Review",
                    state: .warning
                )
            }
    }

    func pathBuilderProofRequirements(
        pathIntelligence: PathIntelligenceProjection?,
        missionControl: GoalDetailMissionControlState
    ) -> [GoalPathBuilderProofState] {
        let projectedProof = (pathIntelligence?.proofRequirements ?? []).prefix(4).map { proof in
            GoalPathBuilderProofState(
                id: proof.id,
                title: proof.proofKind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                summary: proof.summary,
                handoffLabel: handoffTitle(proof.handoffSurface),
                state: .default
            )
        }

        if projectedProof.isEmpty == false {
            return projectedProof
        }

        return missionControl.proofRail.items.prefix(4).map { item in
            GoalPathBuilderProofState(
                id: item.id,
                title: item.title,
                summary: item.subtitle,
                handoffLabel: "Proof",
                state: item.state
            )
        }
    }

    func freshnessTitle(_ freshness: PathIntelligenceFreshnessLabel) -> String {
        switch freshness {
        case .current:
            return "Current"
        case .mayNeedReview:
            return "May Need Review"
        case .basedOnOlderContext:
            return "Based on Older Context"
        }
    }

    func handoffTitle(_ surface: PathIntelligenceHandoffSurface) -> String {
        switch surface {
        case .today:
            return "Today"
        case .plan:
            return "Plan"
        case .goalDetail:
            return "Goal Detail"
        case .proof:
            return "Proof"
        }
    }

    func missionControlState(
        context: DetailContext,
        title: String,
        renderState: GoalRenderState,
        timing: GoalTiming,
        pathSummary: LifePathStateSummary?,
        pathStages: [GoalPathStage],
        sections: [GoalDetailSectionState],
        suggestions: [GoalDetailStepItem],
        evidenceItems: [GoalEvidenceItem],
        feedbackItems: [GoalFeedbackItem],
        nextMovement: GoalDetailNextMovement?,
        trajectory: GoalDetailTrajectoryState,
        progressLabel: String,
        evidenceLabel: String,
        currentTruth: String
    ) -> GoalDetailMissionControlState {
        let nextStep = nextMovement.map {
            GoalNextVisibleStep(title: $0.title, detail: $0.summary, isAvailable: true)
        } ?? GoalNextVisibleStep(
            title: renderState == .blocked ? "Resolve the blocker" : "Needs a next step",
            detail: renderState == .blocked ? "The path should not add more work until this clears." : "Clarify one real step before adding more steps.",
            isAvailable: false
        )
        let proofSummary = goalDetailProofSummary(evidenceItems: evidenceItems, evidenceLabel: evidenceLabel)
        let riskItems = goalDetailRisks(
            context: context,
            renderState: renderState,
            pathSummary: pathSummary,
            suggestions: suggestions,
            evidenceItems: evidenceItems,
            timing: timing
        )
        let decisions = goalDetailDecisions(context: context, feedbackItems: feedbackItems)
        let risks = GoalDetailRisksState(
            title: "Risks",
            subtitle: riskItems.isEmpty ? "No major risk is visible from this goal data." : "Risks stay explicit so recovery can stay calm.",
            items: riskItems,
            emptyTitle: "No major risk visible",
            emptyMessage: "Nothing in this goal is asking for rescue right now."
        )
        let archive = goalDetailArchive(context: context, renderState: renderState, evidenceItems: evidenceItems, feedbackItems: feedbackItems, progressLabel: progressLabel)
        let currentPhase = pathStages.first(where: { $0.position == .current || $0.position == .blocked }) ?? pathStages.first
        let nextMilestone = pathSummary.flatMap(nextMilestoneTitle(for:)) ?? suggestions.first?.title ?? nextMovement?.title
        let pathDetail = currentPhase?.summary ?? trajectory.phaseSummary
        let riskHeadline = riskItems.first?.title ?? risks.emptyTitle
        let riskDetail = riskItems.first?.summary ?? risks.emptyMessage
        let decisionHeadline = decisions.items.first?.title ?? decisions.emptyTitle
        let decisionDetail = decisions.items.first?.summary ?? decisions.emptyMessage

        return GoalDetailMissionControlState(
            currentTruth: currentTruth,
            primaryNextMove: nextStep,
            breadcrumb: goalDetailBreadcrumb(context: context, title: title),
            lanes: [
                GoalDetailMissionLaneState(
                    kind: .overview,
                    title: "Overview",
                    headline: renderState.title,
                    summary: currentTruth,
                    detail: "Next: \(nextStep.title)",
                    badgeTitle: "State",
                    systemImage: "rectangle.and.text.magnifyingglass",
                    state: renderState.visualState
                ),
                GoalDetailMissionLaneState(
                    kind: .path,
                    title: "Path",
                    headline: currentPhase?.title ?? trajectory.phaseTitle,
                    summary: nextMilestone.map { "Next milestone: \($0)" } ?? "The route is still forming.",
                    detail: pathDetail,
                    badgeTitle: currentPhase?.statusLabel ?? "Current",
                    systemImage: "point.topleft.down.curvedto.point.bottomright.up",
                    state: currentPhase?.state ?? .default
                ),
                GoalDetailMissionLaneState(
                    kind: .steps,
                    title: "Steps",
                    headline: nextStep.title,
                    summary: nextStep.detail,
                    detail: nextStep.isAvailable ? "Keep this as the primary contained Step." : "This goal needs one safe next Step before the tactical list grows.",
                    badgeTitle: nextStep.isAvailable ? "Next step" : "Needs review",
                    systemImage: "scope",
                    state: nextStep.isAvailable ? .selected : .warning
                ),
                GoalDetailMissionLaneState(
                    kind: .proof,
                    title: "Proof",
                    headline: proofSummary.title,
                    summary: proofSummary.detail,
                    detail: proofSummary.latestTitle.map { "Latest: \($0)" } ?? "No proof has been recorded for this goal yet.",
                    badgeTitle: proofSummary.count == 0 ? "No proof yet" : "Evidence visible",
                    systemImage: "checkmark.seal",
                    state: proofSummary.visualState
                ),
                GoalDetailMissionLaneState(
                    kind: .decisions,
                    title: "Decisions",
                    headline: decisionHeadline,
                    summary: decisionDetail,
                    detail: decisions.items.dropFirst().map(\.title).joined(separator: " · "),
                    badgeTitle: decisions.items.isEmpty ? "No decisions" : "\(decisions.items.count) recorded",
                    systemImage: "arrow.triangle.branch",
                    state: decisions.items.first?.state ?? .default
                ),
                GoalDetailMissionLaneState(
                    kind: .risks,
                    title: "Risks",
                    headline: riskHeadline,
                    summary: riskDetail,
                    detail: riskItems.dropFirst().map(\.title).joined(separator: " · "),
                    badgeTitle: riskItems.isEmpty ? "Calm" : "Needs review",
                    systemImage: "exclamationmark.triangle",
                    state: riskItems.isEmpty ? .success : .warning
                ),
                GoalDetailMissionLaneState(
                    kind: .archive,
                    title: "Archive",
                    headline: archive.title,
                    summary: archive.summary,
                    detail: archive.learning,
                    badgeTitle: archive.statusLabel,
                    systemImage: "archivebox",
                    state: archive.state
                )
            ],
            timeline: goalDetailTimeline(
                context: context,
                renderState: renderState,
                pathStages: pathStages,
                evidenceItems: evidenceItems,
                feedbackItems: feedbackItems,
                nextMovement: nextMovement,
                progressLabel: progressLabel
            ),
            assumptions: goalDetailAssumptions(
                context: context,
                renderState: renderState,
                timing: timing,
                evidenceItems: evidenceItems,
                suggestions: suggestions,
                risks: riskItems
            ),
            proofRail: GoalDetailProofRailState(
                title: "Proof",
                subtitle: proofSummary.count == 0 ? "Evidence will appear here when it is recorded." : proofSummary.detail,
                items: evidenceItems,
                emptyTitle: "No proof yet",
                emptyMessage: "Add proof later when there is something real to show."
            ),
            decisions: decisions,
            risks: risks,
            archive: archive,
            receipts: GoalDetailReceiptsState(
                title: "What changed",
                subtitle: "Goal-related receipts stay visible here when the current data source provides them.",
                items: [],
                emptyTitle: "No receipts yet",
                emptyMessage: "Receipts will appear here after goal changes are recorded."
            )
        )
    }

    func goalDetailProofSummary(evidenceItems: [GoalEvidenceItem], evidenceLabel: String) -> GoalProofSummary {
        guard let latest = evidenceItems.first else {
            return GoalProofSummary(title: "No proof yet", detail: "Needs evidence", count: 0, latestTitle: nil, visualState: .default)
        }
        return GoalProofSummary(
            title: evidenceItems.count == 1 ? "1 proof point" : "\(evidenceItems.count) proof points",
            detail: evidenceLabel,
            count: evidenceItems.count,
            latestTitle: latest.title,
            visualState: .selected
        )
    }

    func goalDetailBreadcrumb(context: DetailContext, title: String) -> GoalDetailBreadcrumbState {
        let graph = context.goal?.lifeGraph ?? context.draft?.draft.lifeGraph
        var labels: [String] = []
        if let domain = graph?.domains.max(by: { lhs, rhs in lhs.priority < rhs.priority })?.domain {
            labels.append(domain.lifeAreaDisplayName)
        }
        if let pathTitle = graph?.path?.title, pathTitle.isEmpty == false {
            labels.append(pathTitle)
        }
        labels.append(title)
        let compact = Array(labels.prefix(4))
        return GoalDetailBreadcrumbState(
            title: "Path",
            labels: compact.isEmpty ? [title] : compact,
            fallbackUsed: compact.count <= 1
        )
    }

    func goalDetailRisks(
        context: DetailContext,
        renderState: GoalRenderState,
        pathSummary: LifePathStateSummary?,
        suggestions: [GoalDetailStepItem],
        evidenceItems: [GoalEvidenceItem],
        timing: GoalTiming
    ) -> [GoalDetailRiskState] {
        var risks: [GoalDetailRiskState] = []
        if renderState == .blocked || context.draft?.blockers.isEmpty == false || pathSummary?.blockedPrerequisites.isEmpty == false {
            risks.append(GoalDetailRiskState(id: "risk-blocked", title: "Blocked", summary: "A blocker is visible, so the goal should not pretend to be moving normally.", state: .warning))
        }
        if pathSummary?.readiness.gapCount ?? 0 > 0 {
            risks.append(GoalDetailRiskState(id: "risk-waiting", title: "Waiting", summary: "One readiness gap needs an answer before the path is fully believable.", state: .warning))
        }
        if suggestions.isEmpty {
            risks.append(GoalDetailRiskState(id: "risk-next-step", title: "Needs a next step", summary: "The goal has no clear next step in the current plan.", state: .warning))
        }
        if evidenceItems.isEmpty {
            risks.append(GoalDetailRiskState(id: "risk-proof", title: "Proof is thin", summary: "No proof has been recorded yet.", state: .default))
        }
        if timing.dueAt != nil || timing.targetBy != nil {
            risks.append(GoalDetailRiskState(id: "risk-timing", title: "Timing needs review", summary: "The date is visible; keep the next step believable before adding more pressure.", state: .default))
        }
        return Array(risks.prefix(4))
    }

    func goalDetailDecisions(
        context: DetailContext,
        feedbackItems: [GoalFeedbackItem]
    ) -> GoalDetailDecisionsState {
        let items = feedbackItems.prefix(5).map { item in
            GoalDetailDecisionItemState(
                id: item.id,
                title: item.title,
                summary: item.subtitle,
                timestamp: item.timestamp,
                state: item.state
            )
        }

        let title = "Decisions"
        if items.isEmpty {
            return GoalDetailDecisionsState(
                title: title,
                subtitle: "Decision trail stays here when this goal changes.",
                items: [],
                emptyTitle: "No decisions yet",
                emptyMessage: context.goal == nil ? "Starter decisions will appear after this becomes an active goal." : "When you change, park, or explain this goal, the reason will stay visible here."
            )
        }

        return GoalDetailDecisionsState(
            title: title,
            subtitle: "\(items.count) goal decision\(items.count == 1 ? "" : "s") recorded from real history.",
            items: Array(items),
            emptyTitle: "No decisions yet",
            emptyMessage: "When this goal changes, the reason will stay visible here."
        )
    }

    func goalDetailArchive(
        context: DetailContext,
        renderState: GoalRenderState,
        evidenceItems: [GoalEvidenceItem],
        feedbackItems: [GoalFeedbackItem],
        progressLabel: String
    ) -> GoalDetailArchiveState {
        if renderState == .achieved || context.goal?.state == .completed {
            return GoalDetailArchiveState(
                title: "Completed",
                statusLabel: "Completed",
                summary: progressLabel,
                learning: evidenceItems.first.map { "Latest proof: \($0.title)" } ?? "Completion can still carry proof and reflection later.",
                state: .success
            )
        }

        if context.goal?.state == .archived {
            return GoalDetailArchiveState(
                title: "Archived",
                statusLabel: "Closed",
                summary: "This goal is closed without being treated as failure.",
                learning: feedbackItems.first.map { "Last change: \($0.title)" } ?? "Archive keeps the history available for later review.",
                state: .default
            )
        }

        if renderState == .onHold {
            return GoalDetailArchiveState(
                title: "Parked",
                statusLabel: "Review later",
                summary: "This goal is intentionally quiet for now.",
                learning: "Parking keeps the direction without forcing action today.",
                state: .default
            )
        }

        return GoalDetailArchiveState(
            title: "Archive ready",
            statusLabel: "Active",
            summary: "Archive learning will appear when this goal is parked, completed, or closed.",
            learning: "Nothing needs to be archived right now.",
            state: .selected
        )
    }

    func goalDetailTimeline(
        context: DetailContext,
        renderState: GoalRenderState,
        pathStages: [GoalPathStage],
        evidenceItems: [GoalEvidenceItem],
        feedbackItems: [GoalFeedbackItem],
        nextMovement: GoalDetailNextMovement?,
        progressLabel: String
    ) -> GoalDetailTimelineState {
        var items: [GoalDetailTimelineItemState] = [
            GoalDetailTimelineItemState(
                id: "started",
                kind: .started,
                title: "Started",
                summary: context.goal?.createdAt ?? context.draft?.createdAt ?? "Start date is not available.",
                timestamp: context.goal?.createdAt ?? context.draft?.createdAt,
                state: .default,
                isFuture: false
            )
        ]

        if let previous = pathStages.first(where: { $0.position == .completed }) {
            items.append(GoalDetailTimelineItemState(id: "previous-\(previous.id)", kind: .previous, title: previous.title, summary: previous.summary, timestamp: nil, state: previous.state, isFuture: false))
        }
        if let current = pathStages.first(where: { $0.position == .current || $0.position == .blocked }) ?? pathStages.first {
            items.append(GoalDetailTimelineItemState(id: "current-\(current.id)", kind: current.position == .blocked ? .waiting : .current, title: current.title, summary: current.highlight ?? current.summary, timestamp: nil, state: current.state, isFuture: false))
        }
        if let proof = evidenceItems.first {
            items.append(GoalDetailTimelineItemState(id: "proof-\(proof.id)", kind: .proof, title: proof.title, summary: proof.subtitle, timestamp: proof.timestamp, state: proof.state, isFuture: false))
        }
        if let decision = feedbackItems.first {
            items.append(GoalDetailTimelineItemState(id: "decision-\(decision.id)", kind: .decision, title: decision.title, summary: decision.subtitle, timestamp: decision.timestamp, state: decision.state, isFuture: false))
        }
        if renderState == .onHold {
            items.append(GoalDetailTimelineItemState(id: "parked", kind: .parked, title: "Parked", summary: "This goal is intentionally quiet.", timestamp: nil, state: .default, isFuture: false))
        }
        if renderState == .achieved || context.goal?.state == .completed {
            items.append(GoalDetailTimelineItemState(id: "completed", kind: .completed, title: "Completed", summary: progressLabel, timestamp: context.goal?.updatedAt, state: .success, isFuture: false))
        }
        if context.goal?.state == .archived && renderState != .achieved {
            items.append(GoalDetailTimelineItemState(id: "cancelled", kind: .cancelled, title: "Cancelled", summary: "This goal is closed without being treated as active work.", timestamp: context.goal?.updatedAt, state: .default, isFuture: false))
        }
        if let nextMovement, renderState != .achieved, context.goal?.state != .archived {
            items.append(GoalDetailTimelineItemState(id: "next", kind: .next, title: nextMovement.title, summary: nextMovement.summary, timestamp: nil, state: nextMovement.state, isFuture: true))
        }

        return GoalDetailTimelineState(
            title: "Storyline",
            subtitle: "A compact read on what happened, what is current, and what is only a possible next step.",
            items: Array(items.prefix(7))
        )
    }

    func goalDetailAssumptions(
        context: DetailContext,
        renderState: GoalRenderState,
        timing: GoalTiming,
        evidenceItems: [GoalEvidenceItem],
        suggestions: [GoalDetailStepItem],
        risks: [GoalDetailRiskState]
    ) -> [GoalDetailAssumptionState] {
        var assumptions: [GoalDetailAssumptionState] = [
            GoalDetailAssumptionState(
                id: "next-step",
                title: "This goal has a next step.",
                status: suggestions.isEmpty ? "Needs review" : "Visible",
                whyItMatters: "The screen should lead with one step, not a long step dump.",
                correctionLabel: suggestions.isEmpty ? "Review next step" : "Change next step",
                state: suggestions.isEmpty ? .warning : .selected
            ),
            GoalDetailAssumptionState(
                id: "proof",
                title: "This goal has enough proof.",
                status: evidenceItems.isEmpty ? "No proof yet" : "Proof visible",
                whyItMatters: "Progress should be backed by something observable.",
                correctionLabel: "Add proof later",
                state: evidenceItems.isEmpty ? .default : .selected
            ),
            GoalDetailAssumptionState(
                id: "blocked",
                title: "This goal is not blocked.",
                status: risks.contains(where: { $0.id == "risk-blocked" }) ? "Blocked" : "No blocker visible",
                whyItMatters: "Blocked goals need a clearing step before more planning.",
                correctionLabel: risks.contains(where: { $0.id == "risk-blocked" }) ? "Review blocker" : nil,
                state: risks.contains(where: { $0.id == "risk-blocked" }) ? .warning : .success
            ),
            GoalDetailAssumptionState(
                id: "timing",
                title: "This timing is still believable.",
                status: timing.dueAt == nil && timing.targetBy == nil ? "Untimed" : "Needs review",
                whyItMatters: "Dates should not create fake pressure.",
                correctionLabel: timing.dueAt == nil && timing.targetBy == nil ? nil : "Review timing",
                state: timing.dueAt == nil && timing.targetBy == nil ? .default : .warning
            ),
            GoalDetailAssumptionState(
                id: "active",
                title: "This goal is active, not parked.",
                status: renderState == .onHold ? "Parked" : renderState == .achieved ? "Completed" : "Active",
                whyItMatters: "Closed or parked goals should not compete with live direction.",
                correctionLabel: renderState == .onHold ? "Review parked state" : nil,
                state: renderState == .onHold ? .default : renderState == .achieved ? .success : .selected
            )
        ]

        assumptions.append(contentsOf: context.draft?.assumptions.prefix(2).map { assumption in
            GoalDetailAssumptionState(
                id: "draft-\(assumption.id)",
                title: assumption.summary,
                status: "Provisional",
                whyItMatters: "Starter assumptions should stay visible until corrected by real use.",
                correctionLabel: "Correct later",
                state: .default
            )
        } ?? [])

        return Array(assumptions.prefix(7))
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
                    title: HabitGoalSemantics.isHabitLike(goal: goal, step: selectedStep) ? "Ritual logged" : "Completion recorded",
                    body: HabitGoalSemantics.isHabitLike(goal: goal, step: selectedStep)
                        ? "\"\(selectedStep.title)\" now lands in native evidence while staying active as a recurring rhythm."
                        : "\"\(selectedStep.title)\" now lands in native evidence and plan history.",
                    state: .success
                )
            )
        case .delay:
            let decision = rescheduleDecision(for: request.kind, goal: goal, step: selectedStep, history: history, now: now)
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
                    summary: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? step.summary ?? step.actionability.fallbackMicroStep,
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
            let decision = rescheduleDecision(for: request.kind, goal: goal, step: selectedStep, history: history, now: now)
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
                    summary: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? step.summary ?? step.actionability.fallbackMicroStep,
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
                    title: "Rescheduled",
                    body: "The path stays intact without treating one skipped step like failure.\(deferLine)",
                    state: .warning
                )
            )
        case .createReminder:
            let selection = nextStepSchedulingSelection(goal: goal, step: selectedStep)
            let authorization = await calendarRemindersService.requestAuthorizationIfNeeded(for: .reminders)
            guard authorization.canWrite else {
                return GoalDetailActionResponse(
                    message: GoalDetailInlineMessage(
                        title: "Reminders permission needed",
                        body: "Enable Reminders access to create next-step reminders from Ambitions.",
                        state: .warning
                    )
                )
            }

            _ = try await calendarRemindersService.createReminder(for: selection, now: now)
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Reminder created",
                    body: "\"\(selectedStep.title)\" was added to Reminders.",
                    state: .success
                )
            )
        case .createCalendarEvent:
            let selection = nextStepSchedulingSelection(goal: goal, step: selectedStep)
            let authorization = await calendarRemindersService.authorizationState(for: .calendarEvents)
            guard authorization.canWrite else {
                return GoalDetailActionResponse(
                    message: GoalDetailInlineMessage(
                        title: "Use Plan for Calendar access",
                        body: "Plan works without Calendar. To add calendar-aware blocks, open Plan and choose Make Plan calendar-aware first.",
                        state: .warning
                    )
                )
            }

            let conflictReport = await calendarRemindersService.detectConflicts(for: selection, durationMinutes: 45, now: now)
            let event = try await calendarRemindersService.createCalendarEvent(for: selection, durationMinutes: 45, now: now)
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Calendar event created",
                    body: calendarEventMessageBody(for: event.title, report: conflictReport),
                    state: .success
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
            let projectedExplanation = try await goalIntelligenceContext(
                for: detail,
                primaryStepID: selectedStep.id,
                includeWhyNow: true,
                now: now
            )?.explainability.whyThis.compactSummary ?? detail.draft?.metadata.map { metadata in
                explainabilityProjector.makeState(
                    metadata: metadata,
                    applicableSignals: nil,
                    primaryStepID: selectedStep.id,
                    whyNow: learningService.learnedStepInsight(
                        goal: goal,
                        step: selectedStep,
                        snapshot: learningService.buildSnapshot(
                            goals: [goal],
                            evidence: detail.evidence,
                            feedback: history,
                            now: now
                        ),
                        now: now
                    ).whyNow
                ).whyThis.compactSummary
            }
            let explanation = projectedExplanation
                ?? detail.draft.flatMap { draft in
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
            let decision = rescheduleDecision(for: request.kind, goal: goal, step: selectedStep, history: history, now: now)
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
                    summary: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? step.actionability.fallbackMicroStep,
                    timing: timing
                )
            }
            try await repositories.goals.saveGoals([goal])
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Smaller version ready",
                    body: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? selectedStep.actionability.fallbackMicroStep,
                    state: .selected
                )
            )
        case .breakThisDownSmaller:
            let decision = rescheduleDecision(for: request.kind, goal: goal, step: selectedStep, history: history, now: now)
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
                    summary: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? step.actionability.fallbackMicroStep,
                    timing: timing
                )
            }
            try await repositories.goals.saveGoals([goal])
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Broken down smaller",
                    body: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? selectedStep.actionability.fallbackMicroStep,
                    state: .selected
                )
            )
        case .imStuck:
            let decision = rescheduleDecision(for: request.kind, goal: goal, step: selectedStep, history: history, now: now)
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
                    summary: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? step.actionability.fallbackMicroStep,
                    timing: timing
                )
            }
            try await repositories.goals.saveGoals([goal])
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "A calmer next step is ready",
                    body: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? selectedStep.actionability.fallbackMicroStep,
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
                goalID: previousContext?.goalID ?? existingDraft.plannedGoalID,
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
                plan: planned.plan,
                lifeGraph: planned.draft.lifeGraph
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
                plan: starter.plan,
                lifeGraph: starter.draft.lifeGraph
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
            subtitle: "The planner kept the blocker explicit instead of generating performative steps.",
            blockers: draft?.blockers.map(\.reason) ?? ["A blocking condition is still unresolved."]
        )
    }

    func composerContext(
        goalID: String? = nil,
        entrySource: ShellCommandEntrySource,
        clarifiedFields: [MissingFieldKey: String],
        preferredPace: StrategyComposerPaceChoice,
        referenceNow: String
    ) -> GoalEngineOrchestrationContext {
        let strictness: GoalPlanningStrictness
        switch preferredPace {
        case .conservative:
            strictness = .starterFriendly
        case .balanced:
            strictness = .balanced
        case .aggressive:
            strictness = .strict
        }

        return GoalEngineOrchestrationContext(
            goalID: goalID,
            preferredPlanningStrictness: strictness,
            sourceScreen: "goal_composer",
            sourceFlow: entrySource.rawValue,
            clarifiedFields: clarifiedFields,
            referenceNow: referenceNow
        )
    }

    func composerTitle(from title: String, targetDateOverride: String?) -> String {
        guard let targetDateOverride, targetDateOverride.isEmpty == false else {
            return title
        }

        let pattern = #"\b\d{4}-\d{2}-\d{2}\b"#
        guard let range = title.range(of: pattern, options: .regularExpression) else {
            return "\(title) by \(targetDateOverride)"
        }

        var updated = title
        updated.replaceSubrange(range, with: targetDateOverride)
        return updated
    }

    func makeCreateGoalPreview(
        draft: GoalDraft,
        plan: GoalPlan?,
        metadata: GoalOrchestrationMetadata,
        assumptions: [PlanAssumption],
        blockers: [String],
        resultKind: GoalOrchestrationResultKind,
        preferredPace: StrategyComposerPaceChoice,
        entrySource: ShellCommandEntrySource,
        captureID: String?,
        now: Date
    ) -> CreateGoalPreviewState {
        let renderState = renderState(for: resultKind)
        let evaluation = plan?.evaluation
        let sections = plan?.sections ?? []
        let pathSummary = LifeGraphResolver.pathStateSummary(for: draft, plan: plan)
        let pathStages = makePathStages(pathSummary: pathSummary, sections: sections, renderState: renderState)
        let milestonePreview = sections
            .flatMap(\.steps)
            .filter { $0.state != .completed && $0.state != .cancelled }
            .prefix(3)
            .map { makeStepItem(step: $0, goalMode: draft.mode) }

        let persistedDraft = PersistedGoalDraft(
            id: "preview-draft",
            createdAt: DomainTimestamp.string(from: now),
            updatedAt: DomainTimestamp.string(from: now),
            draft: draft,
            classification: nil,
            clarification: metadata.clarification,
            stagedPlan: plan,
            assumptions: assumptions,
            blockers: blockers.enumerated().map { index, reason in
                GoalPlanningBlocker(code: "preview-\(index)", reason: reason, suggestedQuestion: nil)
            },
            metadata: metadata,
            plannedGoalID: nil,
            latestResultKind: resultKind
        )

        return CreateGoalPreviewState(
            normalizedTitle: draft.title,
            summary: draft.summary ?? detailSubtitle(for: draft.mode),
            modeLabel: draft.mode.displayTitle,
            resultKind: resultKind,
            renderState: renderState,
            selectedPace: preferredPace,
            paceOptions: composerPaceOptions(
                selected: preferredPace,
                evaluation: evaluation,
                deadlineGuidance: composerDeadlineGuidance(for: draft.timing, evaluation: evaluation)
            ),
            feasibility: composerFeasibilityState(for: evaluation, timing: draft.timing, mode: draft.mode),
            deadlineGuidance: composerDeadlineGuidance(for: draft.timing, evaluation: evaluation),
            pathStages: pathStages,
            milestonePreview: milestonePreview,
            clarification: clarificationState(from: persistedDraft),
            blocked: blockedState(from: persistedDraft),
            trust: composerTrustState(
                metadata: metadata,
                resultKind: resultKind,
                entrySource: entrySource,
                captureID: captureID
            ),
            planningEvaluation: evaluation
        )
    }

    func composerFeasibilityState(
        for evaluation: PlanningEvaluation?,
        timing: GoalTiming,
        mode: GoalMode
    ) -> StrategyComposerFeasibilityState? {
        guard let evaluation else { return nil }

        let title: String
        let summary: String
        let state: AmbitionVisualState

        switch evaluation.feasibilityLevel {
        case .comfortable:
            title = "Believable path"
            summary = "This setup looks comfortably believable at the current timing."
            state = .success
        case .tight:
            title = "Tight but workable"
            summary = "This path can work, but the timing will need steadier follow-through."
            state = .selected
        case .fragile:
            title = "Fragile setup"
            summary = "This path is understandable, but it likely needs more room or a lighter ask."
            state = .warning
        case .notBelievable:
            title = "Current timing is not believable"
            summary = "Ambitions can show the path, but the deadline probably needs to move or the scope needs to soften."
            state = .warning
        }

        return StrategyComposerFeasibilityState(
            title: title,
            summary: "\(summary) \(timingNote(for: timing, goalMode: mode))",
            details: evaluation.reasons,
            state: state
        )
    }

    func composerPaceOptions(
        selected: StrategyComposerPaceChoice,
        evaluation: PlanningEvaluation?,
        deadlineGuidance: StrategyComposerDeadlineGuidanceState?
    ) -> [StrategyComposerPaceOptionState] {
        StrategyComposerPaceChoice.allCases.map { choice in
            let badgeTitle: String
            let subtitle: String
            let state: AmbitionVisualState

            switch choice {
            case .conservative:
                badgeTitle = deadlineGuidance == nil ? "More room" : "Safer timing"
                subtitle = "Preserve recovery room and keep the path honest."
                state = selected == choice ? .selected : .default
            case .balanced:
                badgeTitle = "Believable"
                subtitle = "Keep the week believable without turning the goal into drift."
                state = selected == choice ? .selected : .default
            case .aggressive:
                badgeTitle = "Tighter"
                subtitle = "Hold the current push and accept less margin for recovery."
                let risky = evaluation?.feasibilityLevel == .fragile || evaluation?.feasibilityLevel == .notBelievable
                state = selected == choice ? (risky ? .warning : .selected) : (risky ? .warning : .default)
            }

            return StrategyComposerPaceOptionState(
                choice: choice,
                title: String(choice.rawValue.prefix(1)).uppercased() + choice.rawValue.dropFirst(),
                subtitle: subtitle,
                badgeTitle: badgeTitle,
                state: state
            )
        }
    }

    func composerDeadlineGuidance(
        for timing: GoalTiming,
        evaluation: PlanningEvaluation?
    ) -> StrategyComposerDeadlineGuidanceState? {
        guard let evaluation,
              evaluation.feasibilityLevel == .fragile || evaluation.feasibilityLevel == .notBelievable,
              let current = parseDate(timing.dueAt ?? timing.targetBy)
        else {
            return nil
        }

        let shiftDays = evaluation.feasibilityLevel == .notBelievable ? 21 : 10
        let revised = Calendar(identifier: .gregorian).date(byAdding: .day, value: shiftDays, to: current) ?? current
        let suggestedDate = Self.iso.string(from: revised)

        return StrategyComposerDeadlineGuidanceState(
            title: "Try a calmer date",
            body: "Moving the date to \(suggestedDate) keeps the goal believable without pretending the current pressure is fine.",
            suggestedDate: suggestedDate,
            badgeTitle: evaluation.feasibilityLevel == .notBelievable ? "Needs more room" : "Could use margin",
            state: .warning
        )
    }

    func composerTrustState(
        metadata: GoalOrchestrationMetadata,
        resultKind: GoalOrchestrationResultKind,
        entrySource: ShellCommandEntrySource,
        captureID: String?
    ) -> StrategyComposerTrustState {
        var lines = [
            "This setup stays local and uses the current goal engine before anything is committed.",
            metadata.reasoning.assumptions.isEmpty
                ? "Ambitions is using the current intake signal directly."
                : "Ambitions is showing its current assumptions instead of hiding them."
        ]

        if let captureID, captureID.isEmpty == false {
            lines.append("This path is seeded from a capture and will only attach that capture after a live goal is created.")
        }

        switch resultKind {
        case .planned, .starterPlanned:
            lines.append("You are looking at a believable first path, not a promise that the plan will never need to adapt.")
        case .clarificationRequired:
            lines.append("Ambitions is pausing before it invents structure from ambiguous input.")
        case .blocked:
            lines.append("The current blocker stays visible so the setup does not fake certainty.")
        }

        return StrategyComposerTrustState(
            title: "Trust framing",
            lines: lines,
            badgeTitle: entrySource == .capturesScreen ? "Capture-led" : "Local first",
            state: .selected
        )
    }

    func renderState(for resultKind: GoalOrchestrationResultKind) -> GoalRenderState {
        switch resultKind {
        case .planned:
            return .active
        case .starterPlanned:
            return .starter
        case .clarificationRequired:
            return .clarification
        case .blocked:
            return .blocked
        }
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
                GoalDetailActionState(kind: .createReminder, title: "Reminder", systemImage: "list.bullet.clipboard", state: .default),
                GoalDetailActionState(kind: .createCalendarEvent, title: "Calendar event", systemImage: "calendar.badge.plus", state: .default),
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
                return "Stay oriented to signal and learning, not just step completion."
            case .recovery:
                return "Keep the next step gentle enough that it still happens."
            default:
                return "Understand the path, the next step, and the evidence that proves it is moving."
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
            subtitle = base.note ?? "Rescheduled."
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
            subtitle = base.note ?? "The next step was unclear."
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
        case .createReminder:
            return "Created reminder from Goal Detail."
        case .createCalendarEvent:
            return "Created calendar event from Goal Detail."
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

    func explainabilitySignals(for context: DetailContext) async throws -> GoalTeachingApplicableSet? {
        if let runtimeContext = try await goalIntelligenceContext(
            for: context,
            primaryStepID: context.primaryStep?.id,
            includeWhyNow: false,
            now: .now
        ) {
            return runtimeContext.applicableSignals
        }
        guard let metadata = context.draft?.metadata else { return nil }
        let goalID = context.goal?.id ?? context.draft?.plannedGoalID ?? metadata.context.goalID
        guard let goalID else { return nil }
        return try await teachingService.applicableSignals(goalID: goalID, metadata: metadata)
    }

    func goalIntelligenceContext(
        for context: DetailContext,
        primaryStepID: String?,
        includeWhyNow: Bool,
        now: Date
    ) async throws -> RuntimeGoalIntelligenceContext? {
        guard let goalIntelligenceService else { return nil }
        return try await goalIntelligenceService.loadContext(
            RuntimeGoalIntelligenceRequest(
                target: context.target,
                primaryStepID: primaryStepID,
                includeWhyNow: includeWhyNow
            ),
            now: now
        )
    }

    func correctionMessage(for signal: GoalTeachingSignal) -> String {
        switch signal.kind {
        case .requirementRelevanceCorrection:
            return "That support relevance correction is now stored through the canonical teaching layer."
        case .contradictionDispositionCorrection:
            return "That contradiction disposition is now stored through the canonical teaching layer."
        case .energyFitCorrection:
            return "That energy-fit correction is now stored through the canonical teaching layer."
        case .interpretationCorrection, .goalSubjectCorrection, .classificationCorrection:
            return "That correction is now stored through the canonical teaching layer."
        }
    }

    func rescheduleDecision(
        for kind: GoalDetailActionKind,
        goal: Goal,
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
                now: now,
                planningEvaluation: goal.plan?.evaluation,
                stepState: step.state,
                incompleteDependencyCount: incompleteDependencyCount(in: goal, for: step),
                pathStateSummary: LifeGraphResolver.pathStateSummary(for: goal),
                learningSummary: learningService.buildSnapshot(
                    goals: [goal],
                    evidence: [],
                    feedback: history,
                    now: now
                ).goalSummaries[goal.id]
            )
        )
    }

    func strategicStatus(
        renderState: GoalRenderState,
        pathSummary: LifePathStateSummary?,
        progressValue: Double,
        progressLabel: String,
        manualPriorityLabel: String,
        supportModeActive: Bool,
        whyNow: String?
    ) -> GoalDetailStrategicStatus {
        let title: String = {
            switch renderState {
            case .active:
                return supportModeActive ? "Support path is in motion" : "Path is in motion"
            case .starter:
                return "Starter path is taking shape"
            case .clarification:
                return "Clarification is the real work right now"
            case .blocked:
                return "The path is waiting on a real blocker"
            case .onHold:
                return "This goal is intentionally quieter"
            case .achieved:
                return "This goal is complete"
            }
        }()

        let summary: String = {
            if let pathSummary {
                if renderState == .blocked || (!pathSummary.blockedPrerequisites.isEmpty || pathSummary.readiness.gapCount > 0) {
                    return "The current stage is visible, but Ambitions is keeping the blocker explicit instead of faking momentum."
                }
                if let activeStage = pathSummary.orderedStages.first(where: { $0.id == pathSummary.activeStageID }) {
                    return "You are in \(activeStage.title), with \(progressLabel.lowercased()) and the next step already surfaced."
                }
            }

            switch renderState {
            case .clarification:
                return "The screen is leading with missing truth so the path can become believable before more decomposition."
            case .blocked:
                return "The constraint is staying visible until the path can restart cleanly."
            case .starter:
                return "The structure is intentionally provisional so early signal can reshape the plan."
            case .achieved:
                return "The path is closed and no longer asking for more movement."
            case .onHold:
                return "This goal is paused without losing the strategic framing."
            case .active:
                return "The path is active and oriented around the smallest step that still changes the goal."
            }
        }()

        return GoalDetailStrategicStatus(
            title: title,
            summary: summary,
            supportingDetail: whyNow ?? "\(manualPriorityLabel) • \(Int(progressValue * 100))% visible progress"
        )
    }

    func nextMovementState(
        primaryStep: Step?,
        suggestions: [GoalDetailStepItem],
        whyNow: String?,
        goalMode: GoalMode,
        renderState: GoalRenderState
    ) -> GoalDetailNextMovement? {
        if let primaryStep {
            return GoalDetailNextMovement(
                title: primaryStep.title,
                summary: primaryStep.summary ?? primaryStep.actionability.fallbackMicroStep,
                timingLabel: timingLabel(for: primaryStep.timing, goalMode: goalMode),
                rationale: whyNow ?? "This is the smallest step that keeps the broader path honest.",
                state: stepVisualState(primaryStep.state)
            )
        }

        if let suggestion = suggestions.first {
            return GoalDetailNextMovement(
                title: suggestion.title,
                summary: suggestion.summary,
                timingLabel: suggestion.timingLabel,
                rationale: whyNow ?? "This is the calmest next step still available from the current plan.",
                state: suggestion.state
            )
        }

        switch renderState {
        case .clarification:
            return GoalDetailNextMovement(
                title: "Answer the missing question",
                summary: "Goal Detail is waiting on one real clarification before it treats the path as trustworthy.",
                timingLabel: "Before new planning",
                rationale: "Clarifying the truth matters more than generating more tactics here.",
                state: .warning
            )
        case .blocked:
            return GoalDetailNextMovement(
                title: "Resolve the blocker",
                summary: "Unblock the constraint before asking the screen for more decomposition.",
                timingLabel: "As soon as reality changes",
                rationale: "Ambitions is refusing to turn uncertainty into performative activity.",
                state: .warning
            )
        case .achieved:
            return nil
        case .starter, .active, .onHold:
            return nil
        }
    }

    func trajectoryState(
        pathSummary: LifePathStateSummary?,
        pathStages: [GoalPathStage],
        sections: [GoalDetailSectionState],
        evidenceLabel: String,
        timingNote: String,
        progressNote: String
    ) -> GoalDetailTrajectoryState {
        let activeStage = pathStages.first(where: { $0.position == .current || $0.position == .blocked })
        let phaseTitle = activeStage?.title ?? sections.first?.title ?? "Path overview"
        let phaseSummary = activeStage?.summary ?? sections.first?.summary ?? "The current path is still forming."
        let milestoneSummary = activeStage?.highlight ?? pathStages.first(where: { $0.position == .upcoming })?.highlight ?? "No milestone highlight yet"
        let momentumSummary: String = {
            if let pathSummary {
                let completed = pathSummary.progression.completedMilestoneIDs.count
                let total = pathSummary.progression.totalMilestoneCount
                if total > 0 {
                    return "\(completed) of \(total) milestones are already visible."
                }
            }

            return evidenceLabel
        }()

        return GoalDetailTrajectoryState(
            phaseTitle: phaseTitle,
            phaseSummary: phaseSummary,
            milestoneSummary: milestoneSummary,
            momentumSummary: momentumSummary,
            timelineSummary: "\(timingNote) \(progressNote)"
        )
    }

    func recentMovementState(
        evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent],
        evidenceLabel: String
    ) -> GoalDetailRecentMovementState {
        let evidenceItems = evidence.prefix(2).map { evidence in
            GoalDetailRecentMovementItem(
                id: "evidence-\(evidence.id)",
                title: evidence.note ?? "Progress signal recorded",
                subtitle: evidence.evidenceKind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                timestamp: evidence.capturedAt,
                categoryLabel: "Evidence",
                state: .success
            )
        }
        let feedbackItems = feedback.prefix(2).map { feedback in
            let item = makeFeedbackItem(feedback)
            return GoalDetailRecentMovementItem(
                id: "feedback-\(item.id)",
                title: item.title,
                subtitle: item.subtitle,
                timestamp: item.timestamp,
                categoryLabel: "Adjustment",
                state: item.state
            )
        }
        let items = Array((evidenceItems + feedbackItems).prefix(4))
        let summary = items.isEmpty ? evidenceLabel : "Recent movement is visible without turning the screen into a history audit."

        return GoalDetailRecentMovementState(
            title: "Recent movement",
            summary: summary,
            items: items
        )
    }

    func makePathStages(
        pathSummary: LifePathStateSummary?,
        sections: [PlanSection],
        renderState: GoalRenderState,
        includeSyntheticFallback: Bool = false
    ) -> [GoalPathStage] {
        if let pathSummary, pathSummary.orderedStages.isEmpty == false {
            return pathSummary.orderedStages.map { stage in
                let milestones = pathSummary.stageMilestones[stage.id] ?? []
                let isCompleted = pathSummary.progression.completedStageIDs.contains(stage.id)
                let isActive = pathSummary.activeStageID == stage.id
                let isBlocked = isActive && (!pathSummary.blockedPrerequisites.isEmpty || pathSummary.readiness.gapCount > 0)
                let highlight = milestones.first(where: { pathSummary.progression.completedMilestoneIDs.contains($0.id) == false })?.title
                    ?? (isBlocked ? pathSummary.blockedPrerequisites.first?.title ?? pathSummary.readiness.gapSignals.first?.title : nil)
                let position: GoalPathStagePosition = isCompleted ? .completed : (isBlocked ? .blocked : (isActive ? .current : .upcoming))

                return GoalPathStage(
                    id: stage.id,
                    title: stage.title,
                    summary: stage.summary ?? "Path stage",
                    stepCountLabel: "\(milestones.count) milestone\(milestones.count == 1 ? "" : "s")",
                    position: position,
                    statusLabel: position.title,
                    highlight: highlight,
                    state: isCompleted ? .success : (isBlocked ? .warning : (isActive ? renderState.visualState : .default))
                )
            }
        }

        let sortedSections = sections.sorted { $0.orderIndex < $1.orderIndex }
        if includeSyntheticFallback && sortedSections.isEmpty {
            let position: GoalPathStagePosition
            let title: String
            let summary: String
            let highlight: String?

            switch renderState {
            case .active:
                position = .current
                title = "Current path"
                summary = "Movement is already live; stay with the next visible step instead of rebuilding the whole plan."
                highlight = "Keep the next step visible"
            case .starter:
                position = .current
                title = "Starter path"
                summary = "The path is still taking shape, but there is enough signal to make the first step visible now."
                highlight = "Take the first visible step"
            case .clarification:
                position = .current
                title = "Clarify the path"
                summary = "The path stays provisional until the missing truth is answered clearly."
                highlight = "Answer the missing question"
            case .blocked:
                position = .blocked
                title = "Blocked path"
                summary = "A real blocker is preventing movement, so the next step is to clear the obstruction rather than force progress."
                highlight = "Resolve the blocker"
            case .onHold:
                position = .upcoming
                title = "Held path"
                summary = "The direction is intentionally quiet for now, but the path remains visible for clean re-entry later."
                highlight = "Re-enter when the timing is real"
            case .achieved:
                position = .completed
                title = "Completed path"
                summary = "The path is closed because the outcome has already landed."
                highlight = "Outcome landed"
            }

            return [
                GoalPathStage(
                    id: "synthetic-\(renderState.rawValue)-path-stage",
                    title: title,
                    summary: summary,
                    stepCountLabel: "Path marker",
                    position: position,
                    statusLabel: position.title,
                    highlight: highlight,
                    state: position == .completed ? .success : renderState.visualState
                )
            ]
        }

        return sortedSections.enumerated().map { index, section in
            let isCompleted = section.steps.allSatisfy { $0.state == .completed }
            let hasActiveStep = section.steps.contains { $0.state != .completed && $0.state != .cancelled }
            let position: GoalPathStagePosition = isCompleted ? .completed : (hasActiveStep && index == 0 ? .current : .upcoming)
            return GoalPathStage(
                id: section.id,
                title: section.title,
                summary: section.summary ?? section.kind.rawValue.replacingOccurrences(of: "_", with: " "),
                stepCountLabel: "\(section.steps.count) step\(section.steps.count == 1 ? "" : "s")",
                position: position,
                statusLabel: position.title,
                highlight: section.steps.first(where: { $0.state != .completed && $0.state != .cancelled })?.title,
                state: isCompleted ? .success : (position == .current ? renderState.visualState : .default)
            )
        }
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
        case .complete, .createReminder, .createCalendarEvent, .askWhyThisMatters, .markNotRelevant, .showPath, .switchToUntimed, .showSupportMode, .raisePriority, .lowerPriority:
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

    func incompleteDependencyCount(in goal: Goal, for step: Step) -> Int {
        let completedStepIDs = Set(goal.plan?.sections.flatMap(\.steps).filter { $0.state == .completed }.map(\.id) ?? [])
        return step.dependencyStepIDs.filter { completedStepIDs.contains($0) == false }.count
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
            plan: updatedPlan,
            lifeGraph: goal.lifeGraph
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
            plan: updatedPlan,
            lifeGraph: goal.lifeGraph
        )
    }

    func nextStepSchedulingSelection(goal: Goal, step: Step) -> NextStepSchedulingSelection {
        NextStepSchedulingSelection(
            goalID: goal.id,
            goalTitle: goal.title,
            stepID: step.id,
            stepTitle: step.title,
            stepSummary: step.summary ?? step.actionability.fallbackMicroStep,
            suggestedDate: parseDate(step.timing.suggestedNextAt ?? step.timing.targetBy ?? step.timing.dueAt)
        )
    }

    func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        return Self.iso.date(from: value) ?? Self.isoFallback.date(from: value) ?? Self.dateOnly.date(from: value)
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

    static let dateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let shortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    func calendarEventMessageBody(for title: String, report: CalendarConflictReport?) -> String {
        guard let report else {
            return "\"\(title)\" was added to Calendar."
        }
        if report.hasConflicts {
            let count = report.conflicts.count
            if let nearby = report.nearbyAvailableWindow {
                return "\"\(title)\" was added to Calendar. It overlaps \(count) event\(count == 1 ? "" : "s"). A clearer opening starts around \(Self.shortTime.string(from: nearby.start))."
            }
            return "\"\(title)\" was added to Calendar. It overlaps \(count) event\(count == 1 ? "" : "s")."
        }
        if report.pressure == .high {
            return "\"\(title)\" was added to Calendar. The day looks tight around that block."
        }
        return "\"\(title)\" was added to Calendar."
    }
}
