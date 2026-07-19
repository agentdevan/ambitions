import AmbitionsDesignSystem
import Foundation

struct SettingsItem: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String?
    let icon: String
    let valueLabel: String?
}

struct YouNotificationAuthorization: Sendable, Equatable {
    let statusLabel: String
    let detail: String
    let canRequestAuthorization: Bool
    let actionTitle: String?
}

struct YouStatusPill: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let icon: String?
    let state: AmbitionVisualState
}

struct YouHeroState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let dominantTruth: String
    let supportingTruth: String
    let trustWhisper: String
    let status: AmbitionVisualState
    let pills: [YouStatusPill]
    let stats: [MetricSummary]
}

struct YouAppearanceOption: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let preference: AppAppearancePreference
}

struct YouAccentOption: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let family: AmbitionAccentFamily
}

enum YouAppearanceObjectPreviewKind: String, Sendable, Equatable {
    case startHere
    case realityRail
    case lifeShape
    case receiptDrawer
}

struct YouPreviewSwatch: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let eyebrow: String
    let objectKind: YouAppearanceObjectPreviewKind
    let accentFamily: AmbitionAccentFamily
    let appearancePreference: AppAppearancePreference
    let state: AmbitionVisualState
    let accessibilityLabel: String
}

struct YouAppearanceStudioState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let previewSummary: String
    let modeOptions: [YouAppearanceOption]
    let accentOptions: [YouAccentOption]
    let previewSwatches: [YouPreviewSwatch]
    let footer: String
}

struct YouTrustPulseState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let detail: String
    let state: AmbitionVisualState
}

struct YouTrustDataMapItem: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let dataTypes: String
    let sourceLabel: String
    let controlLabel: String
    let privacyLabel: String
    let statusLabel: String
    let semanticState: AmbitionSemanticState
}

struct YouTrustCenterState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let pulse: YouTrustPulseState
    let items: [SettingsItem]
    let dataMap: [YouTrustDataMapItem]
    let sections: [YouTrustCenterSection]
    let receiptSummaries: [ActionReceiptDisplaySummary]
    let footer: String
}

struct YouTrustCenterRoute: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let statusLabel: String
    let semanticState: AmbitionSemanticState
    let accessibilityHint: String
}

struct YouTrustCenterSection: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let footer: String?
    let routes: [YouTrustCenterRoute]
}

struct YouControlRoomEntry: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let statusLabel: String
    let state: AmbitionVisualState
}

struct YouControlRoomState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let entries: [YouControlRoomEntry]
    let footer: String
}

struct YouSystemCenterItem: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let statusLabel: String
    let semanticState: AmbitionSemanticState
    let accessibilityHint: String
}

struct YouSystemCenterSection: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let footer: String?
    let items: [YouSystemCenterItem]
}

struct YouSystemCenterState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let sections: [YouSystemCenterSection]
    let footer: String
}

struct YouConstitutionRule: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let detail: String
    let statusLabel: String
    let state: AmbitionVisualState
}

struct YouConstitutionState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let postureSummary: String
    let rules: [YouConstitutionRule]
    let footer: String
}

enum YouMemoryFreshness: String, Sendable, Equatable {
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

struct YouMemoryAction: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let statusLabel: String
    let detail: String
    let state: AmbitionVisualState
}

struct YouMemoryItem: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let detail: String
    let sourceLabel: String
    let freshness: YouMemoryFreshness
    let usedFor: String
    let privacyLabel: String
    let actions: [YouMemoryAction]
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
}

struct YouMemoryGroup: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let footer: String?
    let items: [YouMemoryItem]
}

struct YouNarrativeMemory: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let summary: String
    let sourceLabel: String
    let freshness: YouMemoryFreshness
    let usedFor: String
    let sensitiveStatusLabel: String
    let actions: [YouMemoryAction]
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
}

struct YouMemoryPattern: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let summary: String
    let sourceLabel: String
    let reviewLabel: String
    let state: AmbitionVisualState
}

struct YouMemoryLensItem: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let summary: String
    let sourceLabel: String
    let sourceAgeLabel: String
    let whyRemembered: String
    let privacyShutterLabel: String
    let reviewLabel: String
    let correctionLabel: String
    let rejectionLabel: String
    let state: AmbitionVisualState
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
}

enum YouRuntimeInspectionKind: String, Sendable, Equatable, CaseIterable {
    case learned
    case used
    case ignored
    case changed

    var label: String {
        switch self {
        case .learned: "Learned"
        case .used: "Used"
        case .ignored: "Ignored"
        case .changed: "Changed"
        }
    }
}

struct YouRuntimeInspectionItem: Identifiable, Sendable, Equatable {
    let id: String
    let kind: YouRuntimeInspectionKind
    let title: String
    let summary: String
    let sourceLabel: String
    let controlLabel: String
    let privacyLabel: String
    let state: AmbitionVisualState
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
}

struct YouLocalLearningControl: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let summary: String
    let sourceLabel: String
    let availabilityLabel: String
    let receiptLabel: String
    let boundaryLabel: String
    let state: AmbitionVisualState
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
}

struct YouPersonalizationConsentState: Sendable, Equatable {
    let title: String
    let summary: String
    let sourceLabel: String
    let sensitiveMemoryLabel: String
    let hiddenMemoryLabel: String
    let controlLabel: String
}

struct YouPrivateModeControl: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let summary: String
    let statusLabel: String
    let privacyLabel: String
    let controlLabel: String
    let state: AmbitionVisualState
}
