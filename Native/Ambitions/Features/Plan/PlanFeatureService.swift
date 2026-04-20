import AmbitionsDesignSystem
import Foundation

struct RepositoryBackedPlanService: PlanServicing {
    let repositories: AppRepositories

    func loadPlanDashboard(now: Date) async throws -> PlanDashboard {
        let snapshot = try await loadSnapshot()
        return makeDashboard(snapshot: snapshot, now: now)
    }
}

private extension RepositoryBackedPlanService {
    struct Snapshot {
        let goals: [Goal]
        let drafts: [PersistedGoalDraft]
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]
        let captures: [Capture]
    }

    struct StepContext {
        let goal: Goal
        let step: Step
        let dateKey: String
    }

    func loadSnapshot() async throws -> Snapshot {
        async let goals = repositories.goals.listGoals()
        async let drafts = repositories.drafts.listDrafts()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)
        async let captures = repositories.captures.listCaptures()

        return try await Snapshot(
            goals: goals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback,
            captures: captures
        )
    }

    func makeDashboard(snapshot: Snapshot, now: Date) -> PlanDashboard {
        let activeGoals = snapshot.goals.filter { $0.state == .active || $0.state == .paused }
        let openCaptures = snapshot.captures.filter { $0.status != .archived }
        let blockedDrafts = snapshot.drafts.filter { $0.latestResultKind == .blocked }
        let clarificationDrafts = snapshot.drafts.filter { $0.latestResultKind == .clarificationRequired }
        let weekContexts = weekStepContexts(goals: activeGoals, now: now)
        let activeGoalCoverage = Set(weekContexts.map(\.goal.id)).count
        let habitGoals = activeGoals.filter { goal in
            guard let step = HabitGoalSemantics.preferredStep(in: goal) else { return goal.mode == .habit }
            return goal.mode == .habit || HabitGoalSemantics.isHabitLike(goal: goal, step: step)
        }
        let mode: PlanDashboardMode = activeGoals.isEmpty && snapshot.drafts.isEmpty && openCaptures.isEmpty ? .empty : .active
        let posture = postureState(
            evaluations: activeGoals.compactMap { $0.plan?.evaluation },
            blockedCount: blockedDrafts.count,
            clarificationCount: clarificationDrafts.count,
            openCaptureCount: openCaptures.count,
            weekStepCount: weekContexts.count,
            mode: mode
        )

        return PlanDashboard(
            mode: mode,
            title: mode == .empty ? "Shape the week around real goals" : "This week has a visible shape",
            subtitle: mode == .empty
                ? "Plan will stay honest as goals, captures, and routine work enter the local store."
                : "Active goals, open planning pressure, and repeatable routines are gathered here before the day gets crowded.",
            timeframeLabel: timeframeLabel(now: now),
            posture: posture,
            metrics: [
                MetricSummary(id: "plan-goal-coverage", title: "Goal coverage", value: "\(activeGoalCoverage)/\(max(activeGoals.count, 1))", detail: activeGoals.isEmpty ? "No active goals yet" : "Active goals with visible work", icon: "target"),
                MetricSummary(id: "plan-week-work", title: "Visible work", value: "\(weekContexts.count)", detail: "Current steps in this weekly view", icon: "calendar"),
                MetricSummary(id: "plan-pressure", title: "Planning pressure", value: "\(blockedDrafts.count + clarificationDrafts.count + openCaptures.count)", detail: "Captures, blockers, and clarification", icon: "exclamationmark.triangle"),
                MetricSummary(id: "plan-routines", title: "Routines", value: "\(habitGoals.count)", detail: "Habit-like goals stay under Plan", icon: "repeat")
            ],
            focusItems: focusItems(from: weekContexts),
            pressureItems: pressureItems(
                blockedDrafts: blockedDrafts,
                clarificationDrafts: clarificationDrafts,
                openCaptures: openCaptures,
                feedback: snapshot.feedback
            ),
            secondaryDestinations: [
                PlanSecondaryDestination(
                    id: "plan-habits",
                    title: "Routines and habits",
                    detail: habitGoals.isEmpty
                        ? "No repeatable loops are live yet. When they exist, they stay subordinate to weekly shaping here."
                        : "Review the repeatable loops that can steady or crowd this week.",
                    valueLabel: "\(habitGoals.count)",
                    icon: AppTab.habits.systemImage,
                    visualState: habitGoals.isEmpty ? .default : .selected
                )
            ],
            emptyTitle: mode == .empty ? "No weekly plan pressure yet" : nil,
            emptyMessage: mode == .empty ? "Create a goal or capture an idea, and Plan will show what needs shaping without inventing work." : nil
        )
    }

    func weekStepContexts(goals: [Goal], now: Date) -> [StepContext] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .day, value: 7, to: start) ?? now

        var contexts: [StepContext] = []

        for goal in goals {
            let sections = goal.plan?.sections ?? []
            let steps = sections.flatMap(\.steps)
            for step in steps {
                guard step.state != .completed && step.state != .cancelled else { continue }
                let key = dateKey(for: step.timing)
                if let date = parseDate(key), date < start || date > end {
                    continue
                }
                contexts.append(StepContext(goal: goal, step: step, dateKey: key ?? "9999-12-31T23:59:59Z"))
            }
        }

        return contexts.sorted { lhs, rhs in
            if lhs.dateKey == rhs.dateKey {
                return lhs.step.title.localizedCaseInsensitiveCompare(rhs.step.title) == .orderedAscending
            }
            return lhs.dateKey < rhs.dateKey
        }
    }

    func focusItems(from contexts: [StepContext]) -> [PlanFocusItem] {
        Array(contexts.prefix(6)).map { context in
            PlanFocusItem(
                id: "\(context.goal.id)-\(context.step.id)",
                target: GoalRouteTarget(goalID: context.goal.id),
                title: context.step.title,
                subtitle: context.step.summary ?? context.step.actionability.fallbackMicroStep,
                timingLabel: timingLabel(for: context.step.timing),
                statusLabel: context.step.state.rawValue.capitalized,
                goalLabel: context.goal.title,
                visualState: context.step.state == .blocked ? .warning : .selected
            )
        }
    }

    func pressureItems(
        blockedDrafts: [PersistedGoalDraft],
        clarificationDrafts: [PersistedGoalDraft],
        openCaptures: [Capture],
        feedback: [GoalFeedbackEvent]
    ) -> [PlanPressureItem] {
        let frictionCount = feedback.filter(isFriction).count
        return [
            PlanPressureItem(
                id: "plan-pressure-captures",
                title: "Open captures",
                detail: openCaptures.isEmpty ? "The inbox is not adding planning pressure right now." : "Captured ideas are waiting to be seeded, attached, or archived.",
                valueLabel: "\(openCaptures.count)",
                icon: AppTab.captures.systemImage,
                visualState: openCaptures.isEmpty ? .success : .warning
            ),
            PlanPressureItem(
                id: "plan-pressure-clarity",
                title: "Planning questions",
                detail: clarificationDrafts.isEmpty && blockedDrafts.isEmpty ? "No draft is currently blocked on missing shape." : "Some drafts need clarification before the week can treat them as real work.",
                valueLabel: "\(clarificationDrafts.count + blockedDrafts.count)",
                icon: "questionmark.bubble",
                visualState: clarificationDrafts.isEmpty && blockedDrafts.isEmpty ? .success : .warning
            ),
            PlanPressureItem(
                id: "plan-pressure-friction",
                title: "Recent friction",
                detail: frictionCount == 0 ? "No correction or drift signals are pressing on the plan yet." : "Correction signals suggest this week may need smaller asks.",
                valueLabel: "\(frictionCount)",
                icon: "waveform.path.ecg",
                visualState: frictionCount == 0 ? .default : .selected
            )
        ]
    }

    func postureState(
        evaluations: [PlanningEvaluation],
        blockedCount: Int,
        clarificationCount: Int,
        openCaptureCount: Int,
        weekStepCount: Int,
        mode: PlanDashboardMode
    ) -> PlanPostureState {
        guard mode == .active else {
            return PlanPostureState(
                title: "The week is open",
                detail: "There is no active local planning pressure yet.",
                label: "Quiet",
                visualState: .default
            )
        }

        if blockedCount + clarificationCount > 0 {
            return PlanPostureState(
                title: "Clarify before adding more",
                detail: "Some planning work is paused on explicit questions or blockers.",
                label: "Needs shaping",
                visualState: .warning
            )
        }

        if evaluations.contains(where: { $0.feasibilityLevel == .notBelievable || $0.feasibilityLevel == .fragile }) {
            return PlanPostureState(
                title: "The plan is fragile",
                detail: "Existing planning evaluations are warning that this week needs gentler scope.",
                label: "Fragile",
                visualState: .warning
            )
        }

        if evaluations.contains(where: { $0.feasibilityLevel == .tight }) || openCaptureCount > 0 {
            return PlanPostureState(
                title: "The week is believable but tight",
                detail: "The current plan can hold, but open captures or tight evaluations need review.",
                label: "Tight",
                visualState: .selected
            )
        }

        return PlanPostureState(
            title: weekStepCount == 0 ? "Goals are active, but the week is light" : "The week looks believable",
            detail: weekStepCount == 0 ? "Active goals exist, but no current step is pressing into this weekly view." : "Existing planning evaluations are not warning about the current shape.",
            label: "Believable",
            visualState: .success
        )
    }

    func timeframeLabel(now: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate("MMM d")
        let start = Calendar.current.startOfDay(for: now)
        let end = Calendar.current.date(byAdding: .day, value: 6, to: start) ?? start
        return "\(formatter.string(from: start))-\(formatter.string(from: end))"
    }

    func timingLabel(for timing: GoalTiming) -> String {
        if let dueAt = timing.dueAt {
            return "Due \(shortDate(dueAt))"
        }
        if let targetBy = timing.targetBy {
            return "Target \(shortDate(targetBy))"
        }
        if let suggestedNextAt = timing.suggestedNextAt {
            return "Suggested \(shortDate(suggestedNextAt))"
        }
        if let repeatEveryDays = timing.repeatEveryDays {
            return "Every \(repeatEveryDays) days"
        }
        return "Flexible"
    }

    func dateKey(for timing: GoalTiming) -> String? {
        timing.dueAt ?? timing.targetBy ?? timing.suggestedNextAt ?? timing.startsOn
    }

    func shortDate(_ value: String) -> String {
        guard let date = parseDate(value) else { return value }
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate("MMM d")
        return formatter.string(from: date)
    }

    func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        if let date = ISO8601DateFormatter().date(from: value) {
            return date
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }

    func isFriction(_ event: GoalFeedbackEvent) -> Bool {
        switch event {
        case .skipped, .confused, .tooBig, .notRelevant, .askedForSmallerVersion:
            return true
        default:
            return false
        }
    }
}
