import AmbitionsDesignSystem
import Foundation

struct YouPersonalVaultRow: Identifiable, Sendable, Equatable {
    let id: String
    let kind: YouPersonalVaultRowKind
    let title: String
    let summary: String
    let sourceLabel: String
    let storageLabel: String
    let exportLabel: String
    let resetLabel: String
    let deleteLabel: String
    let provenanceLabel: String
    let privacyPolicyLabel: String
    let permissionLabel: String
    let state: AmbitionVisualState
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
}

struct YouPersonalVaultSection: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let rows: [YouPersonalVaultRow]
}

struct YouPersonalVaultState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let sections: [YouPersonalVaultSection]
    let footer: String

    static let empty = YouPersonalVaultState(
        title: "Personal Vault",
        subtitle: "Sensitive local signal rows and permission labels stay visible before stronger control work lands.",
        sections: [],
        footer: "Personal Vault stays local-first, inspectable, and explicit about what is not complete yet."
    )
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
    let activityLabel: String
    let lastAffectedLabel: String
    let runtimePermissionLabel: String
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

    init(
        id: String,
        title: String,
        detail: String,
        sourceLabel: String,
        freshness: YouMemoryFreshness,
        runtimeUseState: YouLifeContextRuntimeUseState,
        activityLabel: String = "Active",
        lastAffectedLabel: String = "This run",
        runtimePermissionLabel: String = "Allowed",
        whereUsed: String,
        editPath: String,
        pausePath: String,
        deletePath: String,
        reviewPath: String,
        confirmPath: String,
        editLabel: String,
        pauseLabel: String,
        deleteLabel: String,
        reviewLabel: String,
        confirmLabel: String,
        updateTargets: [YouLifeContextUpdateTarget],
        captureRouteContext: CaptureBackgroundFactRoute,
        accessibilityLabel: String,
        accessibilityValue: String,
        accessibilityHint: String
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.sourceLabel = sourceLabel
        self.freshness = freshness
        self.runtimeUseState = runtimeUseState
        self.activityLabel = activityLabel
        self.lastAffectedLabel = lastAffectedLabel
        self.runtimePermissionLabel = runtimePermissionLabel
        self.whereUsed = whereUsed
        self.editPath = editPath
        self.pausePath = pausePath
        self.deletePath = deletePath
        self.reviewPath = reviewPath
        self.confirmPath = confirmPath
        self.editLabel = editLabel
        self.pauseLabel = pauseLabel
        self.deleteLabel = deleteLabel
        self.reviewLabel = reviewLabel
        self.confirmLabel = confirmLabel
        self.updateTargets = updateTargets
        self.captureRouteContext = captureRouteContext
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityValue = accessibilityValue
        self.accessibilityHint = accessibilityHint
    }
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
        subtitle: "Help Ambitions plan from your real life.",
        intro: "Age, schedule, travel, access, history, and constraints help Ambitions make plans that actually fit.",
        summaryItems: [],
        sections: [],
        footer: "Catch Me Up stays under What Ambitions Knows and keeps edit, pause, delete, and confirm paths visible where facts are shown."
    )
}

struct YouSectionGroup: Sendable, Equatable {
    let title: String
    let subtitle: String
    let items: [SettingsItem]
    let footer: String?
}

struct YouPreferencesState: Sendable, Equatable {
    let preferredTab: AmbitionsSurface
    let appearancePreference: AppAppearancePreference
    let accentFamily: AmbitionAccentFamily
    let reviewCadenceDays: Int
    let localOnlyModeEnabled: Bool
}

struct YouPreferencesUpdate: Sendable, Equatable {
    let preferredTab: AmbitionsSurface
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
    let personalVault: YouPersonalVaultState
    let everythingSearch: YouEverythingSearchState
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
    let sourceAtlasKnowledge: YouSourceAtlasKnowledgeState
    let lifeContext: YouLifeContextState
    let integrationsSection: YouSectionGroup
    let defaultsSection: YouSectionGroup
    let accountSection: YouSectionGroup
    let notificationAuthorization: YouNotificationAuthorization
    let preferences: YouPreferencesState

    var userSystemProfile: UserSystemProfile {
        let profileRoutes = systemCenter.sections.flatMap(\.items)
        let learningControls = memoryControls.localLearningControls.map(\.title)
        let personalVaultRows = personalVault.sections.flatMap(\.rows).map(\.title)
        let resetRoutes = memoryControls.localLearningControls.filter {
            $0.title.localizedCaseInsensitiveContains("reset") ||
            $0.title.localizedCaseInsensitiveContains("disable") ||
            $0.title.localizedCaseInsensitiveContains("delete")
        }.map(\.title)

        return UserSystemProfile(
            displayName: hero.title,
            planningDefaults: profileRoutes
                .filter { $0.id == "schedule-availability" || $0.id == "plan-behavior" || $0.id == "vacation-away-time" }
                .map(\.title),
            notificationPreferences: [notificationAuthorization.statusLabel],
            appearancePreferences: [
                preferences.appearancePreference.title,
                preferences.accentFamily.title,
                preferences.preferredTab.title
            ],
            privacyPreferences: trustCenter.dataMap.map(\.privacyLabel),
            permissions: integrationsSection.items.map { "\($0.title): \($0.valueLabel ?? "Review")" },
            connectedSources: personalVaultRows,
            historyPreferences: learningControls,
            exportSharePreferences: accountSection.items.map(\.title),
            securityControls: trustCenter.sections.flatMap(\.routes).map(\.title),
            localAuthenticationSettings: resetRoutes,
            accountState: accountSection.items.first?.valueLabel ?? "Local-only",
            referencePackState: sourceAtlasKnowledge.sections.isEmpty ? "Not connected" : sourceAtlasKnowledge.title
        )
    }

    var userSystemProfileInspectionSummary: String {
        userSystemProfile.inspectionSummary
    }

    init(
        hero: YouHeroState,
        systemCenter: YouSystemCenterState,
        controlRoom: YouControlRoomState,
        constitution: YouConstitutionState,
        memoryControls: YouMemoryControlState,
        personalVault: YouPersonalVaultState,
        everythingSearch: YouEverythingSearchState = .empty,
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
        sourceAtlasKnowledge: YouSourceAtlasKnowledgeState = .empty,
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
        self.personalVault = personalVault
        self.everythingSearch = everythingSearch
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
        self.sourceAtlasKnowledge = sourceAtlasKnowledge
        self.lifeContext = lifeContext
        self.integrationsSection = integrationsSection
        self.defaultsSection = defaultsSection
        self.accountSection = accountSection
        self.notificationAuthorization = notificationAuthorization
        self.preferences = preferences
    }
}
