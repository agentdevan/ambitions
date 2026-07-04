import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTodayService {
    func adjustmentPayload(
        draft: PersistedGoalDraft?,
        goal: Goal,
        step: Step,
        history: [GoalFeedbackEvent]
    ) -> GoalAdaptivePlanAdjustmentPayload? {
        guard let draft else { return nil }
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
                GoalPlannedResult(
                    draft: draft.draft,
                    plan: plan,
                    lint: plan.lint,
                    metadata: metadata
                )
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

    func makeHeader(
        mode: TodayExperienceMode,
        userDisplayName: String,
        now: Date,
        activeGoals: [Goal],
        actionableCount: Int,
        clarificationCount: Int,
        blockedCount: Int
    ) -> TodayHeaderState {
        let hour = clock.calendar.component(.hour, from: now)
        let trimmedName = userDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let greeting: String
        switch hour {
        case 0..<5: greeting = trimmedName.isEmpty ? "Still up" : "Still up, \(trimmedName)"
        case 5..<12: greeting = trimmedName.isEmpty ? "Good morning" : "Good morning, \(trimmedName)"
        case 12..<17: greeting = trimmedName.isEmpty ? "Good afternoon" : "Good afternoon, \(trimmedName)"
        default: greeting = trimmedName.isEmpty ? "Good evening" : "Good evening, \(trimmedName)"
        }

        let subtitle: String
        switch mode {
        case .empty:
            subtitle = "Today becomes useful as soon as one real goal or draft exists. Nothing here is faking urgency."
        case .seeded:
            subtitle = "Today is already reading real native plan, evidence, and feedback records, with starter data standing in until personal history takes over."
        case .active:
            subtitle = "Today is reading live native goals, drafts, evidence, and feedback to decide what deserves attention now."
        }

        var pills = [
            TodayPillState(id: "goals", title: "\(activeGoals.count) active goals", icon: "scope", state: .selected),
            TodayPillState(id: "steps", title: "\(actionableCount) live steps", icon: "bolt.fill", state: .default)
        ]
        if clarificationCount > 0 {
            pills.append(TodayPillState(id: "clarify", title: "\(clarificationCount) question\(clarificationCount == 1 ? "" : "s")", icon: "questionmark.circle", state: .warning))
        }
        if blockedCount > 0 {
            pills.append(TodayPillState(id: "blocked", title: "\(blockedCount) blocker\(blockedCount == 1 ? "" : "s")", icon: "exclamationmark.triangle", state: .warning))
        }
        if mode == .seeded {
            pills.append(TodayPillState(id: "seeded", title: "Starter data ready", icon: "sparkles", state: .celebration))
        }

        return TodayHeaderState(
            greeting: greeting,
            title: "Today",
            subtitle: subtitle,
            contextPills: pills
        )
    }

    func makeDailyTargets(
        mode: TodayExperienceMode,
        goals: [Goal],
        actionableSteps: [Step],
        draftsByGoalID: [String: PersistedGoalDraft],
        completion: (done: Int, total: Int),
        shellSummaries: [TodayActionTarget: GoalShellSummaryState]
    ) -> TodayDailyTargetsState {
        let completionLabel: String
        if completion.total == 0 {
            completionLabel = "No fake completion bars"
        } else {
            completionLabel = "\(Int((Double(completion.done) / Double(max(completion.total, 1))) * 100))% through visible plan work"
        }

        let items = actionableSteps.prefix(3).compactMap { step -> TodayTargetItem? in
            guard let goal = goals.first(where: { $0.plan?.sections.flatMap(\.steps).contains(where: { $0.id == step.id }) == true }) else {
                return nil
            }
            let draft = draftsByGoalID[goal.id]
            let state: AmbitionVisualState = draft?.latestResultKind == .starterPlanned ? .selected : .default
            return TodayTargetItem(
                id: step.id,
                title: step.title,
                subtitle: goal.title,
                timingLabel: timingLabel(for: step.timing, goalMode: goal.mode),
                statusLabel: statusLabel(for: step, draft: draft),
                progress: progressValue(for: step),
                state: state,
                primaryAction: TodayInlineAction(
                    kind: .complete,
                    title: "Complete",
                    systemImage: "checkmark",
                    state: .success,
                    target: TodayActionTarget(goalID: goal.id, stepID: step.id, draftID: draft?.id)
                ),
                secondaryAction: TodayInlineAction(
                    kind: .defer,
                    title: "Defer",
                    systemImage: "clock.arrow.circlepath",
                    state: .default,
                    target: TodayActionTarget(goalID: goal.id, stepID: step.id, draftID: draft?.id)
                ),
                shellSummary: shellSummaries[TodayActionTarget(goalID: goal.id, stepID: step.id, draftID: draft?.id)]
            )
        }

        return TodayDailyTargetsState(
            title: mode == .empty ? "No live targets yet" : "Daily targets",
            subtitle: mode == .empty
                ? "Once a goal exists, Today will surface only the few steps worth acting on."
                : "This is the smallest useful set of live work from the native planner and repository layers.",
            completionLabel: completionLabel,
            items: items,
            emptyMessage: items.isEmpty ? "Import, seed, or create a goal and Today will immediately fill from persisted steps and draft states." : nil
        )
    }

    func makeFocus(
        clarificationDrafts: [PersistedGoalDraft],
        blockedDrafts: [PersistedGoalDraft],
        rankedSelections: [PlanningNextStepSelection],
        actionableSteps: [Step],
        goals: [Goal],
        draftsByGoalID: [String: PersistedGoalDraft],
        feedback: [GoalFeedbackEvent],
        evidence: [ProgressEvidence],
        shellSummaries: [TodayActionTarget: GoalShellSummaryState]
    ) -> TodayFocusState {
        if let draft = clarificationDrafts.first, let clarification = draft.clarification {
            return .clarification(
                TodayFocusClarificationState(
                    title: draft.draft.title,
                    subtitle: "A short clarification here will unlock a better plan than pretending certainty.",
                    questions: clarification.questions.prefix(2).map {
                        TodayClarificationQuestionState(
                            id: $0.id,
                            prompt: $0.prompt,
                            rationale: $0.rationale,
                            gentleDefault: $0.skipSafeDefault
                        )
                    },
                    actions: [
                        TodayInlineAction(
                            kind: .openDetail,
                            title: "Answer",
                            systemImage: "arrow.right.circle",
                            state: .selected,
                            target: TodayActionTarget(draftID: draft.id)
                        )
                    ]
                )
            )
        }

        if let draft = blockedDrafts.first {
            return .blocked(
                TodayFocusBlockedState(
                    title: draft.draft.title,
                    subtitle: "There is a blocker, but Today still offers a recommended step instead of a dead end.",
                    blockerSummary: draft.blockers.first?.reason ?? "Planning is blocked until one missing piece is clarified.",
                    nextBestAction: draft.blockers.first?.suggestedQuestion ?? draft.clarification?.questions.first?.prompt ?? "Open the draft and answer the smallest missing question.",
                    actions: [
                        TodayInlineAction(
                            kind: .openDetail,
                            title: "Open detail",
                            systemImage: "arrow.right.circle",
                            state: .warning,
                            target: TodayActionTarget(draftID: draft.id)
                        )
                    ]
                )
            )
        }

        guard let step = actionableSteps.first,
              let goal = goals.first(where: { $0.plan?.sections.flatMap(\.steps).contains(where: { $0.id == step.id }) == true }) else {
            return .empty(
                TodayEmptyPanelState(
                    title: "Nothing needs a push",
                    message: "Today stays calm when there is no clear next step. Untimed work can wait until it actually fits.",
                    actions: []
                )
            )
        }

        let draft = draftsByGoalID[goal.id]
        let target = TodayActionTarget(goalID: goal.id, stepID: step.id, draftID: draft?.id)
        let progress = focusProgress(for: step, feedback: feedback, evidence: evidence)
        let selection = rankedSelections.first(where: { $0.goal.id == goal.id && $0.step.id == step.id })
        let shellSummary = shellSummaries[target]

        if draft?.latestResultKind == .starterPlanned {
            return .starter(
                TodayFocusStarterState(
                    title: step.title,
                    subtitle: goal.title,
                    reassurance: "This plan was built from safe assumptions so you can start without technical warning energy.",
                    timingLabel: timingLabel(for: step.timing, goalMode: goal.mode),
                    assumptions: draft?.assumptions.prefix(3).map(\.summary) ?? [],
                    actions: [
                        TodayInlineAction(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success, target: target),
                        TodayInlineAction(kind: .split, title: "Split", systemImage: "scissors", state: .selected, target: target),
                        TodayInlineAction(kind: .defer, title: "Defer", systemImage: "clock.arrow.circlepath", state: .default, target: target),
                        TodayInlineAction(kind: .protectLater, title: "Adjust plan", systemImage: "calendar.badge.clock", state: .default, target: target),
                        TodayInlineAction(kind: .askWhyThisMatters, title: "Why this matters", systemImage: "questionmark.circle", state: .default, target: target),
                        TodayInlineAction(kind: .openDetail, title: "Open detail", systemImage: "arrow.right.circle", state: .default, target: target)
                    ],
                    shellSummary: shellSummary
                )
            )
        }

        return .planned(
            TodayFocusPlannedState(
                title: step.title,
                subtitle: goal.title,
                reason: selection?.candidate.whyNow?.conciseReason ?? focusReason(for: goal, step: step),
                timingLabel: timingLabel(for: step.timing, goalMode: goal.mode),
                energyLabel: shellSummary?.indicators.first(where: { $0.kind == .energy })?.title ?? energyLabel(for: goal.mode),
                progress: progress,
                supportingText: supportingText(for: goal, step: step),
                actions: [
                    TodayInlineAction(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success, target: target),
                    TodayInlineAction(kind: .defer, title: "Defer", systemImage: "clock.arrow.circlepath", state: .default, target: target),
                    TodayInlineAction(kind: .reschedule, title: "Reschedule", systemImage: "forward.fill", state: .warning, target: target),
                    TodayInlineAction(kind: .split, title: "Split", systemImage: "scissors", state: .selected, target: target),
                    TodayInlineAction(kind: .protectLater, title: "Adjust plan", systemImage: "calendar.badge.clock", state: .default, target: target),
                    TodayInlineAction(kind: .askWhyThisMatters, title: "Why this matters", systemImage: "questionmark.circle", state: .default, target: target),
                    TodayInlineAction(kind: .openDetail, title: "Open detail", systemImage: "arrow.right.circle", state: .default, target: target)
                ],
                shellSummary: shellSummary
            )
        )
    }

    func makeFreeTime(
        goals: [Goal],
        actionableSteps: [Step],
        draftsByGoalID: [String: PersistedGoalDraft]
    ) -> TodayFreeTimeState {
        let opportunities = actionableSteps.compactMap { step -> TodayOpportunityState? in
            guard let goal = goals.first(where: { $0.plan?.sections.flatMap(\.steps).contains(where: { $0.id == step.id }) == true }) else {
                return nil
            }
            guard goal.timing.tempo == .untimed || goal.mode == .delegatedSupport || goal.mode == .learning || goal.mode == .exploration else {
                return nil
            }
            let state: AmbitionVisualState = goal.mode == .delegatedSupport ? .selected : .default
            return TodayOpportunityState(
                id: step.id,
                title: step.title,
                subtitle: opportunitySubtitle(for: goal),
                timingLabel: timingLabel(for: step.timing, goalMode: goal.mode),
                state: state,
                action: TodayInlineAction(
                    kind: .quickLog,
                    title: "Quick log",
                    systemImage: "plus.bubble",
                    state: .success,
                    target: TodayActionTarget(goalID: goal.id, stepID: step.id, draftID: draftsByGoalID[goal.id]?.id)
                )
            )
        }

        return TodayFreeTimeState(
            title: opportunities.isEmpty ? "Free time can stay open" : "Free time opportunities",
            subtitle: opportunities.isEmpty
                ? "Nothing here is pretending a flexible goal is late."
                : "These are valid steps when the day opens up, especially for untimed, delegated, or exploratory work.",
            opportunities: Array(opportunities.prefix(3))
        )
    }

}
