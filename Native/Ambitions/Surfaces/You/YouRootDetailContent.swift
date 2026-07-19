import AmbitionsDesignSystem
import Foundation
import SwiftUI

struct YouRootDetailContent: View {
    let detail: YouRootDetail
    let profileProjection: YouDashboard
    @Binding var appearancePreference: AppAppearancePreference
    @Binding var accentFamily: AmbitionAccentFamily
    @Binding var preferredTab: AmbitionsSurface
    @Binding var reviewCadenceDays: Int
    let isSaving: Bool
    let hasUnsavedChanges: Bool
    let onSavePreferences: () -> Void
    let onEnableNotifications: () -> Void
    let notificationPermissionState: DegradedStatePresentation?
    let onOpenSystemSettings: () -> Void
    let onOpenDetail: ((YouRootDetail) -> Void)?

    var body: some View {
        switch detail {
        case .sessionDefaults:
            YouConstitutionSurface(constitution: profileProjection.constitution)
        case .personalization:
            YouConstitutionSurface(constitution: profileProjection.constitution)
        case .personalRuntime:
            YouPersonalRuntimeStatusControlGroup(profileProjection: profileProjection)
            YouMemoryControlsSurface(memoryControls: profileProjection.memoryControls)
            YouLifeContextSurface(lifeContext: profileProjection.lifeContext)
            YouSourceAtlasKnowledgeSurface(sourceAtlasKnowledge: profileProjection.sourceAtlasKnowledge)
            YouPersonalVaultSurface(personalVault: profileProjection.personalVault)
            YouEverythingSearchSurface(search: profileProjection.everythingSearch)
        case .appearance:
            YouAppearanceStudioSurface(
                studio: profileProjection.appearanceStudio,
                appearancePreference: $appearancePreference,
                accentFamily: $accentFamily,
                isSaving: isSaving,
                hasUnsavedChanges: hasUnsavedChanges,
                onSave: onSavePreferences
            )
        case .whatAmbitionsKnows:
            YouLifeContextSurface(lifeContext: profileProjection.lifeContext)
            YouSourceAtlasKnowledgeSurface(sourceAtlasKnowledge: profileProjection.sourceAtlasKnowledge)
            YouEverythingSearchSurface(search: profileProjection.everythingSearch)
            YouMemoryControlsSurface(memoryControls: profileProjection.memoryControls)
            YouPersonalVaultSurface(personalVault: profileProjection.personalVault)
            YouContextVaultSurface(contextVault: profileProjection.contextVault)
        case .trustCenter:
            YouTrustCenterSurface(
                trustCenter: profileProjection.trustCenter,
                notificationActionTitle: profileProjection.notificationAuthorization.actionTitle,
                onEnableNotifications: onEnableNotifications
            )
            YouPersonalVaultSurface(personalVault: profileProjection.personalVault)
            YouAutomationBoundarySurface(boundary: profileProjection.automationBoundary)
        case .receiptsHistory:
            YouCrossSurfaceProofReviewSurface(state: profileProjection.crossSurfaceProofReview)
            YouTrustHistoryCenterSurface(history: profileProjection.trustHistoryCenter)
            YouControlGroup(
                eyebrow: "Receipts",
                section: YouSectionGroup(
                    title: profileProjection.receiptAudit.title,
                    subtitle: profileProjection.receiptAudit.subtitle,
                    items: profileProjection.receiptAudit.items,
                    footer: profileProjection.receiptAudit.footer
                ),
                accessibilityIdentifier: "you.receipts-control-group"
            )
        case .corrections:
            YouControlGroup(
                eyebrow: "Corrections",
                section: YouSectionGroup(
                    title: profileProjection.assumptionCorrections.title,
                    subtitle: profileProjection.assumptionCorrections.subtitle,
                    items: profileProjection.assumptionCorrections.items,
                    footer: profileProjection.assumptionCorrections.footer
                ),
                accessibilityIdentifier: "you.corrections-control-group"
            )
        case .reviews:
            YouReviewsSurface(reviews: profileProjection.reviews)
        case .proof:
            YouControlGroup(
                eyebrow: "History",
                section: YouSectionGroup(
                    title: "History",
                    subtitle: "Progress evidence stays local and feeds reviews.",
                    items: profileProjection.reviews.projection.progressLines.map {
                        SettingsItem(id: "proof-\($0.id)", title: $0.title, subtitle: $0.detail, icon: "checkmark.seal", valueLabel: $0.sourceLabel)
                    },
                    footer: "Proof remains reviewable before it is reused."
                ),
                accessibilityIdentifier: "you.proof-control-group"
            )
        case .archive:
            YouControlGroup(eyebrow: "Archive", section: profileProjection.accountSection, accessibilityIdentifier: "you.archive-control-group")
        case .scheduleAvailability:
            YouAvailabilityCenterSurface(center: profileProjection.availabilityCenter)
            if let section = profileProjection.planningDefaultsCenter.section(id: "schedule-availability") {
                YouPlanningDefaultsSectionSurface(section: section, accessibilityIdentifier: "you.schedule-availability-card")
            }
        case .planBehavior:
            if let section = profileProjection.planningDefaultsCenter.section(id: "planning-defaults") {
                YouPlanningDefaultsSectionSurface(section: section, accessibilityIdentifier: "you.plan-behavior-card")
            }
        case .lifeAreas:
            YouControlGroup(
                eyebrow: "Life Areas",
                section: lifeAreasSection,
                accessibilityIdentifier: "you.life-areas-control-group"
            )
        case .automationTrust:
            if let section = profileProjection.planningDefaultsCenter.section(id: "automation-trust") {
                YouPlanningDefaultsSectionSurface(section: section, accessibilityIdentifier: "you.automation-trust-card")
            }
        case .vacationAwayTime:
            if let section = profileProjection.planningDefaultsCenter.section(id: "vacation-away-time") {
                YouPlanningDefaultsSectionSurface(section: section, accessibilityIdentifier: "you.vacation-away-card")
            }
        case .durations:
            YouControlGroup(
                eyebrow: "Planning Behavior",
                section: YouSectionGroup(
                    title: "Durations",
                    subtitle: "Guessed durations are never presented as fact.",
                    items: DurationSource.allCases.map {
                        SettingsItem(id: "duration-\($0.rawValue)", title: durationTitle(for: $0), subtitle: durationSubtitle(for: $0), icon: "timer", valueLabel: nil)
                    },
                    footer: "Examples: 30 min planned, Suggested: 15-20 min, Usually 10-30 min, Duration not set."
                ),
                accessibilityIdentifier: "you.durations-control-group"
            )
        case .notifications:
            if let notificationPermissionState {
                DegradedStateSurface(
                    state: notificationPermissionState,
                    primaryAccessibilityIdentifier: "you.notification-permission.primary",
                    secondaryAccessibilityIdentifier: "you.notification-permission.secondary",
                    onPrimaryAction: onEnableNotifications,
                    onSecondaryAction: onOpenSystemSettings
                )
            }
            YouControlGroup(eyebrow: "Notifications", section: profileProjection.integrationsSection, accessibilityIdentifier: "you.notifications-control-group")
        case .capturePreferences:
            YouControlGroup(eyebrow: "Capture", section: captureSettingsSection, accessibilityIdentifier: "you.capture-preferences-control-group")
        case .sourceSettings:
            SourceInspectionView(presentation: sourceSettingsInspectionPresentation)
            YouControlGroup(
                eyebrow: "Sources",
                section: sourcesSection,
                accessibilityIdentifier: "you.source-settings-control-group"
            )
        case .localDataControls, .integrations, .widgets, .exportImport:
            if detail == .localDataControls {
                YouLocalDataControlsControlGroup(
                    profileProjection: profileProjection,
                    onOpenDetail: onOpenDetail
                )
                YouControlGroup(eyebrow: "Local Data", section: localDataStatusSection, accessibilityIdentifier: "you.local-data-status-control-group")
                YouPersonalVaultSurface(personalVault: profileProjection.personalVault)
                YouMemoryControlsSurface(memoryControls: profileProjection.memoryControls)
                YouControlGroup(eyebrow: "Permission edges", section: profileProjection.integrationsSection, accessibilityIdentifier: "you.local-data-permissions-control-group")
            } else {
                YouControlGroup(eyebrow: "System configuration", section: profileProjection.integrationsSection, accessibilityIdentifier: "you.integrations-control-group")
            }
        case .accessibility:
            YouControlGroup(
                eyebrow: "Accessibility",
                section: accessibilitySettingsSection,
                accessibilityIdentifier: "you.accessibility-control-group"
            )
        case .support:
            YouControlGroup(eyebrow: "Help", section: profileProjection.accountSection, accessibilityIdentifier: "you.support-control-group")
        case .about:
            YouControlGroup(eyebrow: "About", section: aboutSection, accessibilityIdentifier: "you.about-control-group")
        }
    }

}
