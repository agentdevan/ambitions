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
    let sections: [ProfileTrustCenterSection]
    let receiptSummaries: [ActionReceiptDisplaySummary]
    let footer: String
}

struct ProfileTrustCenterRoute: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let statusLabel: String
    let semanticState: AmbitionSemanticState
    let accessibilityHint: String
}

struct ProfileTrustCenterSection: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let footer: String?
    let routes: [ProfileTrustCenterRoute]
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

struct ProfileSystemCenterItem: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let statusLabel: String
    let semanticState: AmbitionSemanticState
    let accessibilityHint: String
}

struct ProfileSystemCenterSection: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let footer: String?
    let items: [ProfileSystemCenterItem]
}

struct ProfileSystemCenterState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let sections: [ProfileSystemCenterSection]
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

enum ProfileMemoryFreshness: String, Sendable, Equatable {
    case current
    case mayNeedReview
    case basedOnOlderContext

    var label: String {
        switch self {
        case .current: "Current"
        case .mayNeedReview: "May Need Review"
        case .basedOnOlderContext: "Based on Older Context"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .current: .success
        case .mayNeedReview: .warning
        case .basedOnOlderContext: .default
        }
    }
}

struct ProfileMemoryAction: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let statusLabel: String
    let detail: String
    let state: AmbitionVisualState
}

struct ProfileMemoryItem: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let detail: String
    let sourceLabel: String
    let freshness: ProfileMemoryFreshness
    let usedFor: String
    let privacyLabel: String
    let actions: [ProfileMemoryAction]
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
}

struct ProfileMemoryGroup: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let footer: String?
    let items: [ProfileMemoryItem]
}

struct ProfileMemoryControlState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let items: [SettingsItem]
    let groups: [ProfileMemoryGroup]
    let recoverySummary: String
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
    let systemCenter: ProfileSystemCenterState
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
