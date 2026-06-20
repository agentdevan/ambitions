import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedInsightsService {
    func makeDashboard(snapshot: Snapshot) -> InsightsDashboard {
        let calendar = Calendar.current
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        let currentWindow = PeriodWindow(
            start: calendar.date(byAdding: .day, value: -6, to: todayStart) ?? todayStart,
            end: calendar.date(byAdding: .day, value: 1, to: todayStart) ?? now
        )
        let previousWindow = PeriodWindow(
            start: calendar.date(byAdding: .day, value: -7, to: currentWindow.start) ?? currentWindow.start,
            end: currentWindow.start
        )

        let activeGoals = snapshot.goals.filter { $0.state == .active }
        let habitGoals = snapshot.goals.filter { goal in
            guard let step = TimeRitualGoalSemantics.preferredStep(in: goal) else { return goal.mode == .habit }
            return goal.mode == .habit || TimeRitualGoalSemantics.isRitualLike(goal: goal, step: step)
        }

        let currentEvidence = evidence(in: currentWindow, from: snapshot.evidence)
        let previousEvidence = evidence(in: previousWindow, from: snapshot.evidence)
        let currentFeedback = feedback(in: currentWindow, from: snapshot.feedback)
        let previousFeedback = feedback(in: previousWindow, from: snapshot.feedback)

        let currentMetrics = metrics(evidence: currentEvidence, feedback: currentFeedback)
        let previousMetrics = metrics(evidence: previousEvidence, feedback: previousFeedback)
        let blockedCount = snapshot.drafts.filter { $0.latestResultKind == .blocked || $0.latestResultKind == .clarificationRequired }.count

        let trendPoints = dailyTrendPoints(from: snapshot.evidence, feedback: snapshot.feedback, start: currentWindow.start)
        let momentumPoints = weightedPoints(from: currentEvidence, feedback: currentFeedback, start: currentWindow.start, positiveKinds: [.stepCompleted, .ritualCompletion, .ritualMinimumVersion], frictionWeight: 0.45)
        let driftPoints = weightedPoints(from: currentEvidence, feedback: currentFeedback, start: currentWindow.start, positiveKinds: [.askedWhyThisMattersProxy], frictionWeight: 0.9, mode: .drift)
        let adaptationPoints = weightedPoints(from: currentEvidence, feedback: currentFeedback, start: currentWindow.start, positiveKinds: [.ritualMinimumVersion], frictionWeight: 0.2, mode: .adaptation)

        let goalStatuses = goalStatuses(goals: activeGoals, feedback: currentFeedback, evidence: currentEvidence)
        let timelineItems = timelineItems(snapshot: snapshot, now: now)
        let posture = postureSummary(
            activeGoalCount: activeGoals.count,
            blockedCount: blockedCount,
            completionCount: currentMetrics.completionCount,
            minimumCount: currentMetrics.minimumCount,
            frictionCount: currentMetrics.frictionCount,
            adaptationCount: currentMetrics.adaptationCount
        )
        let summary = summaryText(
            activeGoalCount: activeGoals.count,
            blockedCount: blockedCount,
            completionCount: currentMetrics.completionCount,
            minimumCount: currentMetrics.minimumCount,
            frictionCount: currentMetrics.frictionCount
        )
        let compare = comparePeriodState(current: currentMetrics, previous: previousMetrics)
        let reviewConstellation = reviewConstellationState(
            goalStatuses: goalStatuses,
            blockedCount: blockedCount,
            current: currentMetrics,
            topGoalTarget: goalStatuses.first?.target
        )
        let continuityRibbon = continuityRibbonState(
            blockedCount: blockedCount,
            current: currentMetrics,
            goalStatuses: goalStatuses
        )

        return InsightsDashboard(
            title: "Reflection OS",
            subtitle: "A calm narrative read on what your behavior is teaching the system right now.",
            posture: posture,
            hero: heroState(
                posture: posture,
                summary: summary,
                current: currentMetrics,
                previous: previousMetrics,
                goalStatuses: goalStatuses,
                compare: compare
            ),
            continuityRibbon: continuityRibbon,
            stats: [
                MetricSummary(id: "insights-focus", title: "Follow-through", value: "\(currentMetrics.visibleFollowThrough)", detail: "Completions and minimum versions this week", icon: "checkmark.circle"),
                MetricSummary(id: "insights-consistency", title: "Consistency", value: "\(consistency(for: habitGoals, metrics: currentMetrics))%", detail: habitGoals.isEmpty ? "No recurring loops yet" : "Ritual rhythm this week", icon: "repeat"),
                MetricSummary(id: "insights-recovery", title: "Adaptation", value: adaptationLabel(currentMetrics, previous: previousMetrics), detail: "How quickly corrections turned back into movement", icon: "arrow.triangle.branch"),
                MetricSummary(id: "insights-care", title: "Needs care", value: "\(blockedCount)", detail: "Open clarification or blocked drafts", icon: "lifepreserver")
            ],
            summary: summary,
            changeSummaries: changeSummaries(
                blockedCount: blockedCount,
                frictionCount: currentMetrics.frictionCount,
                adaptationCount: currentMetrics.adaptationCount,
                completionCount: currentMetrics.completionCount,
                minimumCount: currentMetrics.minimumCount
            ),
            goalStatuses: goalStatuses,
            comparePeriod: compare,
            patternClusters: patternClusters(
                current: currentMetrics,
                previous: previousMetrics,
                trendPoints: trendPoints,
                momentumPoints: momentumPoints,
                driftPoints: driftPoints,
                adaptationPoints: adaptationPoints,
                goalStatuses: goalStatuses
            ),
            reviewConstellation: reviewConstellation,
            historyLayer: historyLayerState(
                timeline: timelineItems,
                current: currentMetrics,
                compare: compare
            ),
            trendTitle: "Pattern truth",
            trendSubtitle: "Microcharts support the read. They do not replace it.",
            timeframeLabel: "This week",
            trendPoints: trendPoints,
            trendSummary: trendSummary(points: trendPoints),
            activitiesTitle: "Recent history",
            activitiesSubtitle: "Recent evidence and corrections that explain why this read matters now.",
            activities: timelineItems.map {
                ActivitySummary(
                    id: $0.id,
                    title: $0.title,
                    subtitle: $0.subtitle,
                    timestamp: $0.timestamp,
                    icon: $0.icon,
                    badge: $0.badge
                )
            }
        )
    }
}
