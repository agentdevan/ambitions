import Foundation

struct SettingsItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String?
    let icon: String
    let valueLabel: String?
}

struct ProfileDashboard: Sendable {
    let title: String
    let subtitle: String
    let initials: String
    let badges: [String]
    let stats: [MetricSummary]
    let settingsTitle: String
    let settingsSubtitle: String
    let settings: [SettingsItem]
    let settingsFooter: String
}
