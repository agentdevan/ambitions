import Foundation

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
    let stats: [MetricSummary]
    let summary: String
    let trendTitle: String
    let trendSubtitle: String
    let timeframeLabel: String
    let trendPoints: [TrendPoint]
    let trendSummary: String
    let activitiesTitle: String
    let activitiesSubtitle: String
    let activities: [ActivitySummary]
}
