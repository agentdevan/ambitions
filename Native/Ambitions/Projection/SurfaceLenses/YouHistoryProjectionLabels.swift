import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedInsightsService {
    func summaryText(activeGoalCount: Int, blockedCount: Int, completionCount: Int, minimumCount: Int, frictionCount: Int) -> String {
        if blockedCount > 0 {
            return "Some goals are asking for clarification before this reflection can claim much more. The strongest signal is still coming from small visible wins, not volume."
        }
        if frictionCount > completionCount {
            return "Friction outweighed completions this week, so the healthiest response is to shrink the next step and remove pressure rather than add more commitments."
        }
        if minimumCount > 0 {
            return "Minimum-version follow-through is carrying momentum. The pattern suggests smaller asks are helping the plan stay honest."
        }
        return activeGoalCount == 0
            ? "Reflection will become richer as live goals, evidence, and history accumulate."
            : "Real evidence is accumulating against the current portfolio, and the plan quality looks strongest when the next step stays specific and visible."
    }

    func trendSummary(points: [TrendPoint]) -> String {
        guard let first = points.first?.value, let last = points.last?.value else {
            return "The trend will become more meaningful as more evidence lands."
        }
        if last > first + 0.1 {
            return "The week improved as visible evidence accumulated and friction stayed manageable."
        }
        if first > last + 0.1 {
            return "Signal softened later in the week, which usually means the next step needs less pressure and more clarity."
        }
        return "The week stayed relatively steady. Consistency is coming more from repeatable scope than from bursts."
    }

    func consistency(for habits: [Goal], metrics: PeriodMetrics) -> Int {
        guard habits.isEmpty == false else { return 0 }
        return min(100, Int((Double(metrics.visibleFollowThrough + metrics.quickLogCount) / Double(max(habits.count * 3, 1))) * 100))
    }

    func adaptationLabel(_ current: PeriodMetrics, previous: PeriodMetrics) -> String {
        let delta = current.adaptationCount - previous.adaptationCount
        if current.adaptationCount == 0 { return "Quiet" }
        if delta > 0 { return "Building" }
        if delta < 0 { return "Slower" }
        return "Steady"
    }

    func compareLabel(_ delta: Int, positive: String, negative: String) -> String {
        if delta > 0 { return "\(abs(delta)) \(positive)" }
        if delta < 0 { return "\(abs(delta)) \(negative)" }
        return "Same as last week"
    }

    func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }

    func relativeTimestamp(for value: String, now: Date) -> String {
        guard let date = parseDate(value) else { return value }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: now)
    }

    func goalTitle(for goalID: String, goals: [Goal]) -> String {
        goals.first(where: { $0.id == goalID })?.title ?? "Goal context"
    }

    func stepTitle(for stepID: String, goals: [Goal]) -> String {
        goals
            .flatMap { $0.plan?.sections.flatMap(\.steps) ?? [] }
            .first(where: { $0.id == stepID })?.title ?? "Goal correction"
    }

    func evidenceTitle(for evidence: ProgressEvidence) -> String {
        switch evidence.evidenceKind {
        case .stepCompleted, .habitCompletion:
            return "Completed work"
        case .habitMinimumVersion:
            return "Minimum version logged"
        case .habitQuickLog:
            return "Ritual signal captured"
        case .sessionLogged:
            return "Session logged"
        case .reflectionLogged:
            return "Reflection captured"
        case .delegatedUpdate:
            return "Support update captured"
        case .observationLogged:
            return "Observation recorded"
        case .milestoneReached:
            return "Milestone reached"
        }
    }

    func evidenceIcon(for evidence: ProgressEvidence) -> String {
        switch evidence.evidenceKind {
        case .stepCompleted, .habitCompletion:
            return "checkmark.circle.fill"
        case .habitMinimumVersion:
            return "leaf.fill"
        case .habitQuickLog:
            return "plus.bubble.fill"
        default:
            return "sparkles"
        }
    }

    func evidenceBadge(for evidence: ProgressEvidence) -> String? {
        switch evidence.evidenceKind {
        case .habitMinimumVersion:
            return "Minimum"
        case .habitQuickLog:
            return "Quick log"
        case .stepCompleted, .habitCompletion:
            return "Win"
        default:
            return nil
        }
    }

    func evidenceState(for evidence: ProgressEvidence) -> AmbitionVisualState {
        switch evidence.evidenceKind {
        case .stepCompleted, .habitCompletion:
            return .success
        case .habitMinimumVersion:
            return .selected
        case .habitQuickLog, .sessionLogged:
            return .default
        default:
            return .default
        }
    }

    func feedbackTitle(for event: GoalFeedbackEvent) -> String {
        switch event {
        case .skipped:
            return "Skipped without punishment"
        case .delayed:
            return "Timing softened"
        case .confused:
            return "Help requested"
        case .tooBig, .askedForSmallerVersion:
            return "Step was shrunk"
        case .notRelevant:
            return "Plan correction flagged"
        case .askedWhyThisMatters:
            return "Rationale requested"
        case .edited:
            return "Step language adjusted"
        case .tooEasy:
            return "Low-signal step noticed"
        case .completed:
            return "Completion feedback logged"
        }
    }

    func feedbackIcon(for event: GoalFeedbackEvent) -> String {
        switch event {
        case .completed:
            return "checkmark.circle"
        case .notRelevant:
            return "nosign"
        case .confused:
            return "lifepreserver"
        default:
            return "arrow.triangle.branch"
        }
    }

    func feedbackBadge(for event: GoalFeedbackEvent) -> String? {
        switch event {
        case .confused:
            return "Help"
        case .notRelevant:
            return "Correction"
        case .askedForSmallerVersion, .tooBig:
            return "Adapted"
        default:
            return nil
        }
    }

    func feedbackState(for event: GoalFeedbackEvent) -> AmbitionVisualState {
        switch event {
        case .completed:
            return .success
        case .askedForSmallerVersion, .delayed, .edited, .askedWhyThisMatters:
            return .selected
        case .skipped, .confused, .tooBig, .notRelevant:
            return .warning
        case .tooEasy:
            return .default
        }
    }

    func isFriction(_ event: GoalFeedbackEvent) -> Bool {
        switch event {
        case .skipped, .confused, .tooBig, .notRelevant:
            return true
        default:
            return false
        }
    }

    func isAdaptationSignal(_ event: GoalFeedbackEvent) -> Bool {
        switch event {
        case .delayed, .askedForSmallerVersion, .tooBig, .confused, .notRelevant, .askedWhyThisMatters:
            return true
        default:
            return false
        }
    }

    func goalStatusRank(_ state: AmbitionVisualState) -> Int {
        switch state {
        case .pressed:
            return 5
        case .disabled:
            return 6
        case .loading:
            return 7
        case .warning:
            return 0
        case .selected:
            return 1
        case .success:
            return 2
        case .celebration:
            return 3
        case .default:
            return 4
        }
    }

    func parseDate(_ value: String?) -> Date? {
        guard let value, value.isEmpty == false else { return nil }
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: value) {
            return date
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }
}
