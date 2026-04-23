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

struct InsightsHeroPill: Identifiable, Sendable {
    let id: String
    let title: String
    let icon: String
    let visualState: AmbitionVisualState
}

struct InsightsHeroAction: Sendable {
    let title: String
    let subtitle: String
    let systemImage: String
    let visualState: AmbitionVisualState
    let goalTarget: GoalRouteTarget?
    let planRoute: PlanRouteTarget?
    let insightsRoute: InsightsRouteTarget?
}

struct InsightsHeroState: Sendable {
    let eyebrow: String
    let title: String
    let subtitle: String
    let dominantTruth: String
    let editorialSummary: String
    let trustWhisper: String
    let postureLabel: String
    let visualState: AmbitionVisualState
    let contextPills: [InsightsHeroPill]
    let primaryAction: InsightsHeroAction
}

struct InsightsContinuityRibbon: Sendable {
    let title: String
    let detail: String
    let icon: String
    let visualState: AmbitionVisualState
    let goalTarget: GoalRouteTarget?
    let planRoute: PlanRouteTarget?
    let insightsRoute: InsightsRouteTarget?
}

struct InsightsCompareMetric: Identifiable, Sendable {
    let id: String
    let title: String
    let currentLabel: String
    let previousLabel: String
    let deltaLabel: String
    let visualState: AmbitionVisualState
}

struct InsightsComparePeriodState: Sendable {
    let title: String
    let subtitle: String
    let summary: String
    let metrics: [InsightsCompareMetric]
}

struct InsightsPatternCluster: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let emphasisLabel: String
    let deltaLabel: String
    let visualState: AmbitionVisualState
    let points: [TrendPoint]
    let goalTarget: GoalRouteTarget?
    let planRoute: PlanRouteTarget?
}

struct InsightsReviewConstellationItem: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let signalLabel: String
    let visualState: AmbitionVisualState
    let goalTarget: GoalRouteTarget?
    let planRoute: PlanRouteTarget?
}

struct InsightsReviewConstellationState: Sendable {
    let title: String
    let subtitle: String
    let items: [InsightsReviewConstellationItem]
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

struct InsightsTimelineItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let timestamp: String
    let icon: String
    let badge: String?
    let visualState: AmbitionVisualState
    let goalTarget: GoalRouteTarget?
    let planRoute: PlanRouteTarget?
}

struct InsightsHistoryLayerState: Sendable {
    let title: String
    let subtitle: String
    let summaryTitle: String
    let summaryDetail: String
    let previewItems: [InsightsTimelineItem]
    let timelineItems: [InsightsTimelineItem]
}

struct InsightsDashboard: Sendable {
    let title: String
    let subtitle: String
    let posture: InsightsPostureSummary
    let hero: InsightsHeroState
    let continuityRibbon: InsightsContinuityRibbon?
    let stats: [MetricSummary]
    let summary: String
    let changeSummaries: [InsightsChangeSummary]
    let goalStatuses: [InsightsGoalStatusItem]
    let comparePeriod: InsightsComparePeriodState
    let patternClusters: [InsightsPatternCluster]
    let reviewConstellation: InsightsReviewConstellationState
    let historyLayer: InsightsHistoryLayerState
    let trendTitle: String
    let trendSubtitle: String
    let timeframeLabel: String
    let trendPoints: [TrendPoint]
    let trendSummary: String
    let activitiesTitle: String
    let activitiesSubtitle: String
    let activities: [ActivitySummary]
}
