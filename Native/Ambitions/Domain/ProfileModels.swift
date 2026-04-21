import Foundation

struct SettingsItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String?
    let icon: String
    let valueLabel: String?
}

struct ProfileNotificationAuthorization: Sendable, Equatable {
    let statusLabel: String
    let detail: String
    let canRequestAuthorization: Bool
    let actionTitle: String?
}

struct ProfilePreferencesState: Sendable, Equatable {
    let preferredTab: AppTab
    let appearancePreference: AppAppearancePreference
    let reviewCadenceDays: Int
    let localOnlyModeEnabled: Bool
}

struct ProfilePreferencesUpdate: Sendable, Equatable {
    let preferredTab: AppTab
    let appearancePreference: AppAppearancePreference
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
    let notificationAuthorization: ProfileNotificationAuthorization
    let preferences: ProfilePreferencesState
}
