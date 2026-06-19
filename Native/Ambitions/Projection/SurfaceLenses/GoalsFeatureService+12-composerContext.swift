import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {

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
            badgeTitle: entrySource == .globalCaptureComposer ? "Capture-led" : "Local first",
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
            return "Priority will follow your current direction order until you adjust it."
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
}
