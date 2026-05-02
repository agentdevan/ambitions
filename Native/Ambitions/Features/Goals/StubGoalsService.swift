import Foundation

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
