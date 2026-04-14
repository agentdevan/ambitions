import Foundation

struct MetricSummary: Identifiable, Sendable {
    let id: String
    let title: String
    let value: String
    let detail: String?
    let icon: String
}

struct HabitSummary: Identifiable, Sendable {
    let id: String
    let title: String
    let detail: String?
    let progress: Double
    let trailingValue: String?
    let statusLabel: String?
}

struct StreakSummary: Sendable {
    let title: String
    let subtitle: String
    let stats: [MetricSummary]
    let recoveryNote: String
}

struct HabitsDashboard: Sendable {
    let title: String
    let subtitle: String
    let stats: [MetricSummary]
    let habits: [HabitSummary]
    let streak: StreakSummary
}
