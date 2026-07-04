import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTodayService {
    func makeMilestone(
        goals: [Goal],
        draftsByGoalID: [String: PersistedGoalDraft],
        shellSummaries: [TodayActionTarget: GoalShellSummaryState]
    ) -> TodayMilestoneState {
        let ordered = goals.sorted { lhs, rhs in
            timingSortKey(for: lhs.timing) < timingSortKey(for: rhs.timing)
        }
        guard let goal = ordered.first else {
            return TodayMilestoneState(
                title: "Milestone prompt",
                subtitle: "No active milestone yet",
                prompt: "Once a goal exists, Today will pull the next milestone cue from the real plan.",
                confidenceLabel: "Waiting on first goal",
                action: nil,
                shellSummary: nil
            )
        }

        let pathSummary = LifeGraphResolver.pathStateSummary(for: goal)
        let pathPrompt: String?
        if let summary = pathSummary, let prerequisite = summary.blockedPrerequisites.first {
            pathPrompt = prerequisite.title
        } else if let summary = pathSummary,
                  let nextMilestoneID = summary.progression.nextMilestoneID,
                  let milestoneTitle = goal.lifeGraph?.milestones.first(where: { $0.id == nextMilestoneID })?.title {
            pathPrompt = milestoneTitle
        } else if let summary = pathSummary, let gap = summary.readiness.gapSignals.first {
            pathPrompt = gap.title
        } else {
            pathPrompt = nil
        }

        let sortedSections = goal.plan?.sections.sorted { $0.orderIndex < $1.orderIndex } ?? []
        let upcomingPrompt = sortedSections
            .first(where: { $0.kind == .upcoming || $0.kind == .review })?
            .steps
            .first?.title
        let fallbackPrompt = sortedSections.flatMap(\.steps).dropFirst().first?.title
        let prompt = pathPrompt
            ?? upcomingPrompt
            ?? fallbackPrompt
            ?? goal.summary
            ?? "Open the goal and confirm the next milestone."

        let target = TodayActionTarget(goalID: goal.id, draftID: draftsByGoalID[goal.id]?.id)
        return TodayMilestoneState(
            title: goal.title,
            subtitle: "Milestone prompt",
            prompt: prompt,
            confidenceLabel: draftsByGoalID[goal.id]?.latestResultKind == .starterPlanned ? "Starter path" : "Live plan",
            action: TodayInlineAction(
                kind: .openDetail,
                title: "Open detail",
                systemImage: "flag.checkered.2.crossed",
                state: .selected,
                target: target
            ),
            shellSummary: shellSummaries[target]
        )
    }

    func makeMomentum(
        activeGoals: [Goal],
        evidence: [ProgressEvidence],
        completedToday: Int,
        frictionCount: Int
    ) -> TodayMomentumState {
        let supportGoals = activeGoals.filter { $0.mode == .delegatedSupport }.count
        let loggedMinutes = evidence.compactMap(\.minutesInvested).reduce(0, +)
        let note: String
        if frictionCount == 0 {
            note = "Today is quiet on friction so far. Keep the scope small and visible."
        } else if supportGoals > 0 {
            note = "Supportive goals are in the mix, so momentum is being framed without punitive language."
        } else {
            note = "Friction is present but visible, which is better than invisible drift."
        }

        return TodayMomentumState(
            title: "Momentum",
            subtitle: "Progress summary",
            metrics: [
                TodayMetricState(id: "done", title: "Completed today", value: "\(completedToday)", detail: "Recorded from native evidence", icon: "checkmark.circle.fill", state: completedToday > 0 ? .success : .default),
                TodayMetricState(id: "active", title: "Active goals", value: "\(activeGoals.count)", detail: "Live in the repository", icon: "scope", state: .selected),
                TodayMetricState(id: "time", title: "Logged minutes", value: "\(loggedMinutes)", detail: "Captured evidence", icon: "timer", state: .default),
                TodayMetricState(id: "friction", title: "Friction signals", value: "\(frictionCount)", detail: "Feedback worth respecting", icon: "waveform.path.ecg", state: frictionCount > 0 ? .warning : .success)
            ],
            note: note
        )
    }

    func makeQuickCapture(goal: Goal?, step: Step?) -> TodayQuickCaptureState {
        let target = TodayActionTarget(goalID: goal?.id, stepID: step?.id)
        return TodayQuickCaptureState(
            title: "Quick capture",
            subtitle: "Ask for help when the next step is still too large or too vague.",
            prompt: "Use quick log when progress happened without a clean completion event.",
            helpText: "If the active step feels heavy, ask for a smaller step before the day turns into avoidance.",
            actions: [
                TodayInlineAction(kind: .quickLog, title: "Quick log", systemImage: "plus.bubble", state: .success, target: target),
                TodayInlineAction(kind: .askForHelp, title: "Ask for help", systemImage: "lifepreserver", state: .default, target: target)
            ]
        )
    }

    func makeReflection(
        now: Date,
        completedToday: [String],
        activeGoals: [Goal],
        feedback: [GoalFeedbackEvent]
    ) -> TodayReflectionState {
        let hour = clock.calendar.component(.hour, from: now)
        let prompt = hour >= 18
            ? "What helped today feel lighter than it could have?"
            : "When tonight arrives, what do you want to feel good about?"

        let frictionHighlights = feedback.prefix(2).map { feedbackSummary(for: $0) }
        let highlights = completedToday.prefix(2) + frictionHighlights

        return TodayReflectionState(
            title: "End-of-day reflection",
            subtitle: "A calm close matters more than squeezing in one more noisy panel.",
            prompt: prompt,
            highlights: Array(highlights),
            actions: [
                TodayInlineAction(
                    kind: .quickLog,
                    title: "Quick log",
                    systemImage: "square.and.pencil",
                    state: .default,
                    target: TodayActionTarget(goalID: activeGoals.first?.id, stepID: activeGoals.first?.plan?.sections.flatMap(\.steps).first?.id)
                )
            ]
        )
    }

    func todayCompletionTitles(snapshot: Snapshot, now: Date) -> [String] {
        let dayStart = clock.calendar.startOfDay(for: now)
        return snapshot.feedback.compactMap { event -> String? in
            guard case .completed(let base, _, _, _) = event else { return nil }
            guard let occurredAt = parseDate(base.occurredAt), occurredAt >= dayStart else { return nil }
            return stepTitle(for: base.stepID, goals: snapshot.goals)
        }
    }

    func stepTitle(for stepID: String, goals: [Goal]) -> String? {
        goals.lazy
            .compactMap { $0.plan?.sections.flatMap(\.steps).first(where: { $0.id == stepID })?.title }
            .first
    }

    func feedbackSummary(for event: GoalFeedbackEvent) -> String {
        switch event {
        case let .skipped(base, _):
            return "Skipped: \(base.note ?? "Not today.")"
        case let .delayed(base, _, _):
            return "Delayed: \(base.note ?? "Made room without dropping it.")"
        case let .confused(base, _):
            return "Clarify: \(base.note ?? "The next step needs cleaner language.")"
        case let .notRelevant(base):
            return "Relevance check: \(base.note ?? "Something drifted.")"
        case .completed, .edited, .tooBig, .tooEasy, .askedForSmallerVersion, .askedWhyThisMatters:
            return "Signal captured from Today."
        }
    }

    func timingSortKey(for timing: GoalTiming, goalMode: GoalMode? = nil) -> String {
        if goalMode == .delegatedSupport {
            return timing.suggestedNextAt ?? "9999-12-31T23:59:59Z"
        }
        return timing.dueAt ?? timing.targetBy ?? timing.windowStart ?? timing.suggestedNextAt ?? "9999-12-31T23:59:59Z"
    }

    func timingLabel(for timing: GoalTiming, goalMode: GoalMode) -> String {
        switch goalMode {
        case .delegatedSupport:
            return timing.suggestedNextAt == nil ? "Support when helpful" : "Good support window"
        default:
            switch timing.tempo {
            case .untimed:
                return "No deadline"
            case .ongoing:
                return timing.repeatEveryDays.map { "Every \($0) day\($0 == 1 ? "" : "s")" } ?? "Keep it gentle"
            case .targetWindow:
                return timing.targetBy.map { "Target by \($0)" } ?? "Flexible window"
            case .deadlineBased:
                return timing.dueAt.map { "Due \($0)" } ?? "Time-bound"
            }
        }
    }

    func statusLabel(for step: Step, draft: PersistedGoalDraft?) -> String {
        if step.state == .blocked { return "Blocked" }
        if draft?.latestResultKind == .starterPlanned { return "Starter plan" }
        return "Planned"
    }

    func progressValue(for step: Step) -> Double {
        switch step.state {
        case .completed: return 1
        case .active: return 0.8
        case .blocked: return 0.22
        case .planned: return 0.48
        case .cancelled: return 0.08
        }
    }

    func focusProgress(for step: Step, feedback: [GoalFeedbackEvent], evidence: [ProgressEvidence]) -> Double {
        let stepFeedbackCount = feedback.filter { $0.stepID == step.id }.count
        let stepEvidenceCount = evidence.filter { $0.stepID == step.id }.count
        let base = progressValue(for: step)
        let bonus = min(0.32, Double(stepFeedbackCount + stepEvidenceCount) * 0.06)
        return min(0.96, base + bonus)
    }

    func focusReason(for goal: Goal, step: Step) -> String {
        if goal.mode == .delegatedSupport {
            return "This step supports \(goal.actor.displayName) without turning the relationship into compliance work."
        }
        if TimeRitualGoalSemantics.isRitualLike(goal: goal, step: step) {
            return "Consistency matters more than intensity here. A smaller clean repetition is better than a loud miss."
        }
        return step.summary ?? goal.summary ?? "This is the cleanest next step from the current native plan."
    }

    func energyLabel(for mode: GoalMode) -> String {
        switch mode {
        case .habit, .maintenance:
            return "Steady"
        case .recovery:
            return "Gentle"
        case .delegatedSupport:
            return "Supportive"
        case .exploration, .learning:
            return "Curious"
        default:
            return "Deliberate"
        }
    }

    func supportingText(for goal: Goal, step: Step) -> [String] {
        var items = [timingLabel(for: step.timing, goalMode: goal.mode)]
        items.append(contentsOf: step.actionability.evidenceOfCompletion.prefix(2))
        if TimeRitualGoalSemantics.isRitualLike(goal: goal, step: step) {
            items.append("Minimum version: \(step.actionability.fallbackMicroStep)")
        }
        if goal.mode == .delegatedSupport {
            items.append("Keep the other person as the owner of execution.")
        }
        return items
    }

    func opportunitySubtitle(for goal: Goal) -> String {
        switch goal.mode {
        case .delegatedSupport:
            return "A non-punitive support step"
        case .learning:
            return "A good flexible learning session"
        case .exploration:
            return "A low-pressure experiment"
        default:
            return goal.summary ?? "A calm use of spare time"
        }
    }

    func rescheduleDecision(
        for kind: TodayActionKind,
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
                ).goalSummaries[goal.id],
                sharedLifeSummary: sharedLifeService.buildSnapshot(
                    goals: [goal],
                    evidence: [],
                    feedback: history,
                    now: now
                ).goalSummaries[goal.id]
            )
        )
    }

    func rescheduleTrigger(for kind: TodayActionKind) -> RescheduleTrigger? {
        switch kind {
        case .startStepSession, .pauseStepSession, .stopStepSession:
            return nil
        case .defer:
            return .delay
        case .reschedule:
            return .skip
        case .split:
            return .askForSmallerStep
        case .askForHelp:
            return .stuck
        case .complete, .closeActionClosure, .createReminder, .createCalendarEvent, .askWhyThisMatters, .markNotRelevant, .openDetail, .openTime, .protectLater, .quickLog, .dismissCelebration:
            return nil
        }
    }

    func note(for kind: TodayActionKind, step: Step) -> String {
        switch kind {
        case .startStepSession:
            return "Started step from Today."
        case .pauseStepSession:
            return "Paused Step session from Today."
        case .stopStepSession:
            return "Stopped Step session from Today."
        case .complete:
            return "Completed from Today."
        case .defer:
            return "Deferred from Today to reduce pressure."
        case .reschedule:
            return "Rescheduled from Today without punitive language."
        case .split:
            return "Asked for a smaller version from Today."
        case .askWhyThisMatters:
            return "Asked why this matters from Today."
        case .protectLater:
            return "Rescheduled from Today."
        case .quickLog:
            return "Quick log from Today."
        case .createReminder:
            return "Created reminder from Today."
        case .createCalendarEvent:
            return "Created calendar event from Today."
        case .markNotRelevant:
            return "Marked not relevant from Today."
        case .closeActionClosure:
            return "Closed the loop from Today."
        case .openDetail, .openTime, .askForHelp, .dismissCelebration:
            return step.title
        }
    }

}
