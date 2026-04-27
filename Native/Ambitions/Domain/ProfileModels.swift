import AmbitionsDesignSystem
import Foundation

struct SettingsItem: Identifiable, Sendable, Equatable {
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

struct ProfileStatusPill: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let icon: String?
    let state: AmbitionVisualState
}

struct ProfileHeroState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let dominantTruth: String
    let supportingTruth: String
    let trustWhisper: String
    let status: AmbitionVisualState
    let pills: [ProfileStatusPill]
    let stats: [MetricSummary]
}

struct ProfileAppearanceOption: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let preference: AppAppearancePreference
}

struct ProfileAccentOption: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let family: AmbitionAccentFamily
}

struct ProfilePreviewSwatch: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let eyebrow: String
    let accentFamily: AmbitionAccentFamily
    let appearancePreference: AppAppearancePreference
    let state: AmbitionVisualState
}

struct ProfileAppearanceStudioState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let previewSummary: String
    let modeOptions: [ProfileAppearanceOption]
    let accentOptions: [ProfileAccentOption]
    let previewSwatches: [ProfilePreviewSwatch]
    let footer: String
}

struct ProfileTrustPulseState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let detail: String
    let state: AmbitionVisualState
}

struct ProfileTrustCenterState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let pulse: ProfileTrustPulseState
    let items: [SettingsItem]
    let footer: String
}

struct ProfileControlRoomEntry: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let statusLabel: String
    let state: AmbitionVisualState
}

struct ProfileControlRoomState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let entries: [ProfileControlRoomEntry]
    let footer: String
}

struct ProfileConstitutionRule: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let detail: String
    let statusLabel: String
    let state: AmbitionVisualState
}

struct ProfileConstitutionState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let postureSummary: String
    let rules: [ProfileConstitutionRule]
    let footer: String
}

struct ProfileMemoryControlState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let items: [SettingsItem]
    let footer: String
}

struct ProfileAssumptionCorrectionState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let items: [SettingsItem]
    let footer: String
}

struct ProfileAutomationBoundaryState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let rules: [ProfileConstitutionRule]
    let footer: String
}

struct ProfileReceiptAuditState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let items: [SettingsItem]
    let footer: String
}

struct ProfileReviewsState: Sendable, Equatable {
    let projection: ReviewsV1Projection
    let title: String
    let subtitle: String
    let footer: String
}

struct ProfileContextVaultItem: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let detail: String
}

struct ProfileSignalPolicyItem: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let detail: String
    let state: AmbitionVisualState
}

struct ProfileContextVaultState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let items: [ProfileContextVaultItem]
    let policyItems: [ProfileSignalPolicyItem]
    let footer: String
}

struct ProfileSectionGroup: Sendable, Equatable {
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

struct ProfileDashboard: Sendable, Equatable {
    let hero: ProfileHeroState
    let controlRoom: ProfileControlRoomState
    let constitution: ProfileConstitutionState
    let memoryControls: ProfileMemoryControlState
    let assumptionCorrections: ProfileAssumptionCorrectionState
    let automationBoundary: ProfileAutomationBoundaryState
    let receiptAudit: ProfileReceiptAuditState
    let reviews: ProfileReviewsState
    let appearanceStudio: ProfileAppearanceStudioState
    let trustCenter: ProfileTrustCenterState
    let contextVault: ProfileContextVaultState
    let integrationsSection: ProfileSectionGroup
    let defaultsSection: ProfileSectionGroup
    let accountSection: ProfileSectionGroup
    let notificationAuthorization: ProfileNotificationAuthorization
    let preferences: ProfilePreferencesState
}
