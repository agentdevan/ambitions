import Foundation

struct RepositoryBackedInsightsService: InsightsServicing {
    let repositories: AppRepositories

    func loadInsightsDashboard() async throws -> InsightsDashboard {
        let snapshot = try await loadSnapshot()
        return makeDashboard(snapshot: snapshot)
    }
}

private extension RepositoryBackedInsightsService {
    struct Snapshot {
        let goals: [Goal]
        let drafts: [PersistedGoalDraft]
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]
    }

    func loadSnapshot() async throws -> Snapshot {
        async let goals = repositories.goals.listGoals()
        async let drafts = repositories.drafts.listDrafts()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)

        return try await Snapshot(
            goals: goals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback
        )
    }

    func makeDashboard(snapshot: Snapshot) -> InsightsDashboard {
        let now = Date()
        let weekStart = Calendar.current.date(byAdding: .day, value: -6, to: Calendar.current.startOfDay(for: now)) ?? now
        let weekEvidence = snapshot.evidence.filter { parseDate($0.capturedAt).map { $0 >= weekStart } ?? false }
        let weekFeedback = snapshot.feedback.filter { parseDate($0.base.occurredAt).map { $0 >= weekStart } ?? false }
        let activeGoals = snapshot.goals.filter { $0.state == .active }
        let habitGoals = snapshot.goals.filter { goal in
            guard let step = HabitGoalSemantics.preferredStep(in: goal) else { return goal.mode == .habit }
            return goal.mode == .habit || HabitGoalSemantics.isHabitLike(goal: goal, step: step)
        }
        let completionCount = weekEvidence.filter { $0.evidenceKind == .stepCompleted || $0.evidenceKind == .habitCompletion }.count
        let minimumCount = weekEvidence.filter { $0.evidenceKind == .habitMinimumVersion }.count
        let quickLogCount = weekEvidence.filter { $0.evidenceKind == .habitQuickLog || $0.evidenceKind == .sessionLogged }.count
        let blockedCount = snapshot.drafts.filter { $0.latestResultKind == .blocked || $0.latestResultKind == .clarificationRequired }.count
        let frictionCount = weekFeedback.filter(isFriction).count
        let adaptationCount = weekFeedback.filter(isAdaptationSignal).count
        let totalSignals = max(1, completionCount + minimumCount + quickLogCount + frictionCount)
        let completionQuality = min(100, Int((Double(completionCount + minimumCount) / Double(totalSignals)) * 100))
        let recoverySpeed = adaptationCount == 0 ? 0 : Double(completionCount + minimumCount) / Double(adaptationCount)
        let consistency = habitGoals.isEmpty ? 0 : min(100, Int((Double(completionCount + minimumCount + quickLogCount) / Double(max(habitGoals.count * 3, 1))) * 100))

        let trendPoints = dailyTrendPoints(from: snapshot.evidence, feedback: snapshot.feedback, start: weekStart)
        let activities = recentActivities(snapshot: snapshot, now: now)

        return InsightsDashboard(
            title: "Behavior grounded in evidence",
            subtitle: "Real goals, habits, feedback, and recovery signals are shaping this readout.",
            stats: [
                MetricSummary(id: "insights-focus", title: "Focus quality", value: "\(completionQuality)", detail: "Completion vs friction this week", icon: "scope"),
                MetricSummary(id: "insights-consistency", title: "Consistency", value: "\(consistency)%", detail: habitGoals.isEmpty ? "No recurring loops yet" : "Habit follow-through this week", icon: "repeat"),
                MetricSummary(id: "insights-recovery", title: "Recovery speed", value: adaptationLabel(recoverySpeed), detail: "Completions after correction signals", icon: "waveform.path.ecg"),
                MetricSummary(id: "insights-care", title: "Needs care", value: "\(blockedCount)", detail: "Blocked or clarification-first goals", icon: "exclamationmark.triangle")
            ],
            summary: summaryText(
                activeGoalCount: activeGoals.count,
                blockedCount: blockedCount,
                completionCount: completionCount,
                minimumCount: minimumCount,
                frictionCount: frictionCount
            ),
            trendTitle: "Last 7 days",
            trendSubtitle: "A calm read on completions, minimum versions, and friction.",
            timeframeLabel: "Last 7 days",
            trendPoints: trendPoints,
            trendSummary: trendSummary(points: trendPoints),
            activitiesTitle: "Recent signals",
            activitiesSubtitle: "The most recent evidence and correction events that explain the current read.",
            activities: activities
        )
    }

    func dailyTrendPoints(from evidence: [ProgressEvidence], feedback: [GoalFeedbackEvent], start: Date) -> [TrendPoint] {
        (0..<7).compactMap { offset in
            guard let day = Calendar.current.date(byAdding: .day, value: offset, to: start) else { return nil }
            let label = dayLabel(for: day)
            let dayEvidence = evidence.filter { parseDate($0.capturedAt).map { Calendar.current.isDate($0, inSameDayAs: day) } ?? false }
            let dayFeedback = feedback.filter { parseDate($0.base.occurredAt).map { Calendar.current.isDate($0, inSameDayAs: day) } ?? false }
            let positive = dayEvidence.reduce(0.0) { partial, item in
                switch item.evidenceKind {
                case .stepCompleted, .habitCompletion:
                    return partial + 1
                case .habitMinimumVersion:
                    return partial + 0.7
                case .habitQuickLog, .sessionLogged, .reflectionLogged, .delegatedUpdate, .observationLogged, .milestoneReached:
                    return partial + 0.35
                }
            }
            let friction = dayFeedback.reduce(0.0) { partial, event in
                partial + (isFriction(event) ? 0.55 : 0.0)
            }
            return TrendPoint(
                id: "trend-\(offset)",
                label: label,
                value: max(0.1, min(1, (positive - friction + 1.2) / 2.4))
            )
        }
    }

    func recentActivities(snapshot: Snapshot, now: Date) -> [ActivitySummary] {
        let evidenceActivities = snapshot.evidence
            .sorted { $0.capturedAt > $1.capturedAt }
            .prefix(4)
            .map { evidence in
                ActivitySummary(
                    id: evidence.id,
                    title: evidenceTitle(for: evidence),
                    subtitle: goalTitle(for: evidence.goalID, goals: snapshot.goals),
                    timestamp: relativeTimestamp(for: evidence.capturedAt, now: now),
                    icon: evidenceIcon(for: evidence),
                    badge: evidenceBadge(for: evidence)
                )
            }

        let feedbackActivities = snapshot.feedback
            .sorted { $0.base.occurredAt > $1.base.occurredAt }
            .prefix(4)
            .map { event in
                ActivitySummary(
                    id: event.base.id,
                    title: feedbackTitle(for: event),
                    subtitle: stepTitle(for: event.stepID, goals: snapshot.goals),
                    timestamp: relativeTimestamp(for: event.base.occurredAt, now: now),
                    icon: feedbackIcon(for: event),
                    badge: feedbackBadge(for: event)
                )
            }

        return Array((evidenceActivities + feedbackActivities).sorted { $0.timestamp > $1.timestamp }.prefix(6))
    }

    func summaryText(activeGoalCount: Int, blockedCount: Int, completionCount: Int, minimumCount: Int, frictionCount: Int) -> String {
        if blockedCount > 0 {
            return "There are \(blockedCount) goals asking for clarification or unblock work. The most useful momentum is coming from small completions and minimum versions, not volume theater."
        }
        if frictionCount > completionCount {
            return "Friction outweighed completions this week, so the healthiest response is to shrink the next step and remove pressure rather than add more commitments."
        }
        if minimumCount > 0 {
            return "Minimum-version follow-through is carrying momentum. The pattern suggests smaller asks are helping the plan stay honest."
        }
        return activeGoalCount == 0
            ? "Insights will become richer as live goals, evidence, and habit history accumulate."
            : "Real evidence is accumulating against the current portfolio, and the plan quality looks strongest when the next move stays specific and visible."
    }

    func trendSummary(points: [TrendPoint]) -> String {
        guard let first = points.first?.value, let last = points.last?.value else {
            return "The trend will become more meaningful as more evidence lands."
        }
        if last > first + 0.1 {
            return "The week improved as visible evidence accumulated and friction stayed manageable."
        }
        if first > last + 0.1 {
            return "Signal softened later in the week, which usually means the next move needs less pressure and more clarity."
        }
        return "The week stayed relatively steady. Consistency is coming more from repeatable scope than from bursts."
    }

    func adaptationLabel(_ value: Double) -> String {
        if value == 0 { return "Quiet" }
        if value < 1 { return "Slow" }
        if value < 1.8 { return "Steady" }
        return "Fast"
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
            .first(where: { $0.id == stepID })?.title ?? "Plan correction"
    }

    func evidenceTitle(for evidence: ProgressEvidence) -> String {
        switch evidence.evidenceKind {
        case .stepCompleted, .habitCompletion:
            return "Completed work"
        case .habitMinimumVersion:
            return "Minimum version logged"
        case .habitQuickLog:
            return "Habit signal captured"
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

    func parseDate(_ value: String) -> Date? {
        Self.iso.date(from: value) ?? Self.isoFallback.date(from: value)
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
