import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {

    func loadOverview() async throws -> GoalsOverview {
        return try await GoalsOverviewProjector().makeOverview(from: self)
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
        let prepared = try await prepareGoalCreation(request, now: now)
        return try await commitPreparedGoalCreation(prepared, now: now)
    }

    func commitPreparedGoalCreation(
        _ prepared: PreparedGoalCreation,
        now: Date
    ) async throws -> CreateGoalResponse {
        let receipt = try await saveGoalCreation(goal: prepared.goal, draft: prepared.draft, now: now)
        return CreateGoalResponse(
            target: prepared.response.target,
            blueprint: prepared.response.blueprint,
            resultKind: prepared.response.resultKind,
            planningEvaluation: prepared.response.planningEvaluation,
            unitOfWorkReceipt: receipt
        )
    }


    func prepareGoalCreation(_ request: CreateGoalRequest, now: Date) async throws -> PreparedGoalCreation {
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
            return PreparedGoalCreation(
                response: CreateGoalResponse(target: GoalRouteTarget(goalID: goalID, draftID: draftID), blueprint: blueprint(from: planned.draft), resultKind: .planned, planningEvaluation: planned.plan.evaluation),
                goal: goal,
                draft: storedDraft
            )
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
            return PreparedGoalCreation(
                response: CreateGoalResponse(target: GoalRouteTarget(goalID: goalID, draftID: draftID), blueprint: blueprint(from: starter.draft), resultKind: .starterPlanned, planningEvaluation: starter.plan.evaluation),
                goal: goal,
                draft: storedDraft
            )
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
            return PreparedGoalCreation(
                response: CreateGoalResponse(target: GoalRouteTarget(draftID: draftID), blueprint: blueprint(from: required.draft), resultKind: .clarificationRequired, planningEvaluation: nil),
                goal: nil,
                draft: storedDraft
            )
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
            return PreparedGoalCreation(
                response: CreateGoalResponse(target: GoalRouteTarget(draftID: draftID), blueprint: blueprint(from: blocked.draft), resultKind: .blocked, planningEvaluation: nil),
                goal: nil,
                draft: storedDraft
            )
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
}
