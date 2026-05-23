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

struct YouMemoryControlState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let items: [SettingsItem]
    let consent: YouPersonalizationConsentState
    let privateModeControls: [YouPrivateModeControl]
    let groups: [YouMemoryGroup]
    let narrativeMemories: [YouNarrativeMemory]
    let conservativePatterns: [YouMemoryPattern]
    let memoryLensItems: [YouMemoryLensItem]
    let runtimeInspectionItems: [YouRuntimeInspectionItem]
    let localLearningControls: [YouLocalLearningControl]
    let recoverySummary: String
    let footer: String

    init(
        title: String,
        subtitle: String,
        items: [SettingsItem],
        consent: YouPersonalizationConsentState,
        privateModeControls: [YouPrivateModeControl],
        groups: [YouMemoryGroup],
        narrativeMemories: [YouNarrativeMemory],
        conservativePatterns: [YouMemoryPattern],
        memoryLensItems: [YouMemoryLensItem],
        runtimeInspectionItems: [YouRuntimeInspectionItem] = [],
        localLearningControls: [YouLocalLearningControl] = [],
        recoverySummary: String,
        footer: String
    ) {
        self.title = title
        self.subtitle = subtitle
        self.items = items
        self.consent = consent
        self.privateModeControls = privateModeControls
        self.groups = groups
        self.narrativeMemories = narrativeMemories
        self.conservativePatterns = conservativePatterns
        self.memoryLensItems = memoryLensItems
        self.runtimeInspectionItems = runtimeInspectionItems
        self.localLearningControls = localLearningControls
        self.recoverySummary = recoverySummary
        self.footer = footer
    }
}

struct YouAssumptionCorrectionState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let items: [SettingsItem]
    let footer: String
}

struct YouAutomationBoundaryState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let rules: [YouConstitutionRule]
    let footer: String
}

struct YouReceiptAuditState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let items: [SettingsItem]
    let footer: String
}

enum YouTrustHistoryCategory: String, Sendable, Equatable, CaseIterable {
    case receipts
    case proof
    case changes
    case sourceReview
    case privacy
    case automation

    var title: String {
        switch self {
        case .receipts: "Receipts"
        case .proof: "Proof"
        case .changes: "Changes"
        case .sourceReview: "Source Review"
        case .privacy: "Privacy"
        case .automation: "Automation"
        }
    }
}

struct YouTrustHistoryItem: Identifiable, Sendable, Equatable {
    let id: String
    let category: YouTrustHistoryCategory
    let title: String
    let summary: String
    let sourceLabel: String
    let reviewLabel: String
    let privacyLabel: String
    let reversibilityLabel: String
    let state: AmbitionVisualState
}

struct YouTrustHistoryCenterState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let items: [YouTrustHistoryItem]
    let footer: String

    static let empty = YouTrustHistoryCenterState(
        title: "Trust History",
        subtitle: "Receipts, proof, source review, changes, privacy, and automation boundaries stay reviewable from You.",
        items: [],
        footer: "This is a review surface, not a feed. Detail stays behind the owning surface."
    )
}

struct YouReviewsState: Sendable, Equatable {
    let projection: ReviewsV1Projection
    let title: String
    let subtitle: String
    let footer: String
}

struct YouContextVaultItem: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let detail: String
}

struct YouSignalPolicyItem: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let detail: String
    let state: AmbitionVisualState
}

struct YouContextVaultState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let items: [YouContextVaultItem]
    let policyItems: [YouSignalPolicyItem]
    let footer: String
}

enum YouLifeContextUpdateTarget: String, Sendable, Equatable {
    case profile
    case historicalFact
    case opportunityContext
    case eligibilityPathway
}

enum YouLifeContextRuntimeUseState: String, Sendable, Equatable, CaseIterable {
    case used
    case needsReview = "needs_review"
    case notUsed = "not_used"

    var label: String {
        switch self {
        case .used:
            return "Used"
        case .needsReview:
            return "Needs review"
        case .notUsed:
            return "Not used"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .used:
            return .success
        case .needsReview:
            return .warning
        case .notUsed:
            return .default
        }
    }
}

struct YouLifeContextFactRow: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let detail: String
    let sourceLabel: String
    let freshness: YouMemoryFreshness
    let runtimeUseState: YouLifeContextRuntimeUseState
    let whereUsed: String
    let editPath: String
    let pausePath: String
    let deletePath: String
    let reviewPath: String
    let confirmPath: String
    let editLabel: String
    let pauseLabel: String
    let deleteLabel: String
    let reviewLabel: String
    let confirmLabel: String
    let updateTargets: [YouLifeContextUpdateTarget]
    let captureRouteContext: CaptureBackgroundFactRoute
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
}

struct YouLifeContextSection: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let factRows: [YouLifeContextFactRow]
}

struct YouLifeContextState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let intro: String
    let summaryItems: [SettingsItem]
    let sections: [YouLifeContextSection]
    let footer: String

    static let empty = YouLifeContextState(
        title: "Life Context",
        subtitle: "Catch Me Up stays ready even before the first bundle is filled out.",
        intro: "Start with the basics, then add the facts that shape fit, safety, and opportunity without turning this into a demographic profile.",
        summaryItems: [],
        sections: [],
        footer: "Catch Me Up stays under What Ambitions Knows and keeps edit, pause, and delete paths visible where facts are shown."
    )
}

struct YouSectionGroup: Sendable, Equatable {
    let title: String
    let subtitle: String
    let items: [SettingsItem]
    let footer: String?
}

struct YouPreferencesState: Sendable, Equatable {
    let preferredTab: AppTab
    let appearancePreference: AppAppearancePreference
    let accentFamily: AmbitionAccentFamily
    let reviewCadenceDays: Int
    let localOnlyModeEnabled: Bool
}

struct YouPreferencesUpdate: Sendable, Equatable {
    let preferredTab: AppTab
    let appearancePreference: AppAppearancePreference
    let accentFamily: AmbitionAccentFamily
    let reviewCadenceDays: Int
    let localOnlyModeEnabled: Bool
}

struct YouDashboard: Sendable, Equatable {
    let hero: YouHeroState
    let systemCenter: YouSystemCenterState
    let controlRoom: YouControlRoomState
    let constitution: YouConstitutionState
    let memoryControls: YouMemoryControlState
    let assumptionCorrections: YouAssumptionCorrectionState
    let automationBoundary: YouAutomationBoundaryState
    let planningDefaultsCenter: YouPlanningDefaultsCenterState
    let availabilityCenter: YouAvailabilityCenterState
    let receiptAudit: YouReceiptAuditState
    let trustHistoryCenter: YouTrustHistoryCenterState
    let crossSurfaceProofReview: YouCrossSurfaceProofReviewState
    let reviews: YouReviewsState
    let appearanceStudio: YouAppearanceStudioState
    let trustCenter: YouTrustCenterState
    let contextVault: YouContextVaultState
    let lifeContext: YouLifeContextState
    let integrationsSection: YouSectionGroup
    let defaultsSection: YouSectionGroup
    let accountSection: YouSectionGroup
    let notificationAuthorization: YouNotificationAuthorization
    let preferences: YouPreferencesState

    init(
        hero: YouHeroState,
        systemCenter: YouSystemCenterState,
        controlRoom: YouControlRoomState,
        constitution: YouConstitutionState,
        memoryControls: YouMemoryControlState,
        assumptionCorrections: YouAssumptionCorrectionState,
        automationBoundary: YouAutomationBoundaryState,
        planningDefaultsCenter: YouPlanningDefaultsCenterState = .empty,
        availabilityCenter: YouAvailabilityCenterState = .empty,
        receiptAudit: YouReceiptAuditState,
        trustHistoryCenter: YouTrustHistoryCenterState = .empty,
        crossSurfaceProofReview: YouCrossSurfaceProofReviewState = .empty,
        reviews: YouReviewsState,
        appearanceStudio: YouAppearanceStudioState,
        trustCenter: YouTrustCenterState,
        contextVault: YouContextVaultState,
        lifeContext: YouLifeContextState = .empty,
        integrationsSection: YouSectionGroup,
        defaultsSection: YouSectionGroup,
        accountSection: YouSectionGroup,
        notificationAuthorization: YouNotificationAuthorization,
        preferences: YouPreferencesState
    ) {
        self.hero = hero
        self.systemCenter = systemCenter
        self.controlRoom = controlRoom
        self.constitution = constitution
        self.memoryControls = memoryControls
        self.assumptionCorrections = assumptionCorrections
        self.automationBoundary = automationBoundary
        self.planningDefaultsCenter = planningDefaultsCenter
        self.availabilityCenter = availabilityCenter
        self.receiptAudit = receiptAudit
        self.trustHistoryCenter = trustHistoryCenter
        self.crossSurfaceProofReview = crossSurfaceProofReview
        self.reviews = reviews
        self.appearanceStudio = appearanceStudio
        self.trustCenter = trustCenter
        self.contextVault = contextVault
        self.lifeContext = lifeContext
        self.integrationsSection = integrationsSection
        self.defaultsSection = defaultsSection
        self.accountSection = accountSection
        self.notificationAuthorization = notificationAuthorization
        self.preferences = preferences
    }
}
