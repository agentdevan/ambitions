import AmbitionsDesignSystem
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

struct ProfilePlanningSummary: Sendable {
    let title: String
    let subtitle: String
    let items: [SettingsItem]
}

struct ProfileSectionGroup: Sendable {
    let title: String
    let subtitle: String
    let items: [SettingsItem]
    let footer: String?
}

struct ProfilePreferencesState: Sendable, Equatable {
    let preferredTab: AppTab
    let appearancePreference: AppAppearancePreference
    let accentFamily: AmbitionAccentFamily
    let reviewCadenceDays: Int
    let localOnlyModeEnabled: Bool
}

struct ProfilePreferencesUpdate: Sendable, Equatable {
    let preferredTab: AppTab
    let appearancePreference: AppAppearancePreference
    let accentFamily: AmbitionAccentFamily
    let reviewCadenceDays: Int
    let localOnlyModeEnabled: Bool
}

struct ProfileDashboard: Sendable {
    let title: String
    let subtitle: String
    let initials: String
    let badges: [String]
    let stats: [MetricSummary]
    let planningSummary: ProfilePlanningSummary
    let preferencesSection: ProfileSectionGroup
    let trustSection: ProfileSectionGroup
    let notificationAuthorization: ProfileNotificationAuthorization
    let preferences: ProfilePreferencesState
}
