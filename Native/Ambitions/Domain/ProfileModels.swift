import Foundation

struct SettingsItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String?
    let icon: String
    let valueLabel: String?
}

struct ProfilePreferencesState: Sendable, Equatable {
    let preferredTab: AppTab
    let reviewCadenceDays: Int
    let localOnlyModeEnabled: Bool
}

struct ProfilePreferencesUpdate: Sendable, Equatable {
    let preferredTab: AppTab
    let reviewCadenceDays: Int
    let localOnlyModeEnabled: Bool
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
    let preferences: ProfilePreferencesState
}
