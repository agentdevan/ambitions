import AmbitionsDesignSystem
import Foundation

struct InsightsPostureSummary: Sendable {
    let title: String
    let detail: String
    let label: String
    let visualState: AmbitionVisualState
}

struct InsightsChangeSummary: Identifiable, Sendable {
    let id: String
    let title: String
    let detail: String
    let valueLabel: String
    let icon: String
    let visualState: AmbitionVisualState
}

struct InsightsGoalStatusItem: Identifiable, Sendable {
    let id: String
    let target: GoalRouteTarget?
    let title: String
    let summary: String
    let statusLabel: String
    let visualState: AmbitionVisualState
}

struct TrendPoint: Identifiable, Sendable {
    let id: String
    let label: String
    let value: Double
}

struct ActivitySummary: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let timestamp: String
    let icon: String
    let badge: String?
}

struct InsightsDashboard: Sendable {
    let title: String
    let subtitle: String
    let posture: InsightsPostureSummary
    let stats: [MetricSummary]
    let summary: String
    let changeSummaries: [InsightsChangeSummary]
    let goalStatuses: [InsightsGoalStatusItem]
    let trendTitle: String
    let trendSubtitle: String
    let timeframeLabel: String
    let trendPoints: [TrendPoint]
    let trendSummary: String
    let activitiesTitle: String
    let activitiesSubtitle: String
    let activities: [ActivitySummary]
}
