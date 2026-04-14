import Foundation

struct DashboardProgressItem: Identifiable, Sendable {
    let id: String
    let title: String
    let detail: String?
    let progress: Double
    let trailingValue: String?
    let statusLabel: String?
}

struct FocusSession: Sendable {
    let headline: String
    let subtitle: String
    let reason: String
    let durationLabel: String
    let energyLabel: String
    let progress: Double
    let supportSteps: [String]
}

struct FreeTimeSuggestion: Sendable {
    let title: String
    let subtitle: String
    let windowLabel: String
    let suggestionTitle: String
    let suggestionDetail: String
}

struct TodayDashboard: Sendable {
    let title: String
    let subtitle: String
    let completionLabel: String
    let targets: [DashboardProgressItem]
    let focus: FocusSession
    let freeTime: FreeTimeSuggestion
}
