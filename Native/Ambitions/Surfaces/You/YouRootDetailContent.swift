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
            YouControlGroup(
                eyebrow: "Sources",
                section: sourcesSection,
                accessibilityIdentifier: "you.source-settings-control-group"
            )
        case .localDataControls, .integrations, .widgets, .exportImport:
            if detail == .localDataControls {
                YouControlGroup(eyebrow: "Local Data", section: localDataStatusSection, accessibilityIdentifier: "you.local-data-status-control-group")
                YouLocalDataControlsControlGroup(profileProjection: profileProjection)
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

    var captureSettingsSection: YouSectionGroup {
        YouSectionGroup(
            title: "Capture",
            subtitle: "Capture settings reflect the current global composer path.",
            items: [
                SettingsItem(id: "capture-input", title: "Input behavior", subtitle: "Capture opens as a full-screen Stage composer.", icon: "keyboard", valueLabel: "Global"),
                SettingsItem(id: "capture-keyboard-tools", title: "Keyboard tools", subtitle: "Use standard iOS keyboard tools in the Capture field.", icon: "keyboard.chevron.compact.down", valueLabel: "System"),
                SettingsItem(id: "capture-attachments", title: "Attachments", subtitle: "Local attachments stay in the Capture flow and are not uploaded from this setting.", icon: "paperclip", valueLabel: "Local"),
                SettingsItem(id: "capture-teaching-reset", title: "Gesture teaching reset", subtitle: "Reset is not exposed in You yet.", icon: "hand.tap", valueLabel: "Unavailable"),
                SettingsItem(id: "capture-permissions", title: "Permission state", subtitle: "No Capture-only cloud or analytics permission is connected.", icon: "lock", valueLabel: "Local"),
            ],
            footer: "This detail does not rebuild Capture or add a half-sheet path."
        )
    }

    var lifeAreasSection: YouSectionGroup {
        YouSectionGroup(
            title: "Life Areas",
            subtitle: "Life Area ownership remains with Goals.",
            items: [
                SettingsItem(id: "life-areas-defaults", title: "Default areas", subtitle: "Work, Body, Home, People, Self, Future, and Open Field are supplied by the Goals Life Area Atlas.", icon: "square.grid.2x2", valueLabel: "Available"),
                SettingsItem(id: "life-areas-customization", title: "Customization", subtitle: "Rename, reorder, hide, and add controls are not exposed from You yet.", icon: "slider.horizontal.3", valueLabel: "Unavailable"),
                SettingsItem(id: "life-areas-route-owner", title: "Where to manage", subtitle: "Open Goals to work with Life Area detail and contextual Capture creation.", icon: "target", valueLabel: "Goals"),
            ],
            footer: "You shows the ownership boundary instead of duplicating Goals controls."
        )
    }

    var localDataStatusSection: YouSectionGroup {
        YouSectionGroup(
            title: "Local Data",
            subtitle: "Personal life data remains local unless a future approved sync architecture changes that.",
            items: [
                SettingsItem(id: "local-data-store", title: "Local store", subtitle: "Goals, captures, proof, receipts, preferences, and local context use on-device storage.", icon: "internaldrive", valueLabel: "On device"),
                SettingsItem(id: "local-data-export", title: "Export", subtitle: "Export is status-only here unless an owning export path proves the action.", icon: "square.and.arrow.up", valueLabel: "Bounded"),
                SettingsItem(id: "local-data-erase", title: "Erase", subtitle: "Broad destructive erase is not exposed from this detail.", icon: "trash.slash", valueLabel: "Unavailable"),
            ],
            footer: "Any destructive local-data action must require confirmation before it becomes available."
        )
    }

    var sourcesSection: YouSectionGroup {
        YouSectionGroup(
            title: "Sources",
            subtitle: "Sources are local or permission-backed unless explicitly shown otherwise.",
            items: [
                SettingsItem(id: "sources-permissions", title: "Permissions", subtitle: "Calendar and notification boundaries are shown where the current app can inspect them.", icon: "checkmark.shield", valueLabel: "Review"),
                SettingsItem(id: "sources-freshness", title: "Freshness", subtitle: "Freshness belongs in source detail and receipts, not on the You root.", icon: "clock.arrow.circlepath", valueLabel: "Detail"),
                SettingsItem(id: "sources-add-remove", title: "Add or remove", subtitle: "No connected external source is faked from this setting.", icon: "minus.plus.batteryblock", valueLabel: "Unavailable"),
            ] + profileProjection.assumptionCorrections.items,
            footer: profileProjection.assumptionCorrections.footer
        )
    }

    var accessibilitySettingsSection: YouSectionGroup {
        YouSectionGroup(
            title: "Accessibility",
            subtitle: "System accessibility settings are respected; release claims remain proof-gated.",
            items: [
                SettingsItem(id: "accessibility-dynamic-type", title: "Dynamic Type", subtitle: "Rows support larger text through native wrapping.", icon: "textformat.size", valueLabel: "System"),
                SettingsItem(id: "accessibility-reduce-motion", title: "Reduce Motion", subtitle: "Stage animation uses the iOS Reduce Motion environment.", icon: "figure.walk.motion", valueLabel: "System"),
                SettingsItem(id: "accessibility-increase-contrast", title: "Increase Contrast", subtitle: "Semantic tokens provide contrast-aware foreground and stroke states.", icon: "circle.lefthalf.filled", valueLabel: "System"),
                SettingsItem(id: "accessibility-haptics", title: "Haptics", subtitle: "Route haptics use the design-system haptic policy.", icon: "iphone.radiowaves.left.and.right", valueLabel: "Policy"),
                SettingsItem(id: "accessibility-icon-labels", title: "Icon labels", subtitle: "Root navigation labels remain VoiceOver-accessible and not visibly persistent.", icon: "character.cursor.ibeam", valueLabel: "VoiceOver"),
                SettingsItem(id: "accessibility-proof-preview", title: "Proof preview", subtitle: "Manual accessibility proof is still pending.", icon: "checkmark.seal", valueLabel: "Pending"),
            ],
            footer: "This is app support status, not public accessibility certification."
        )
    }

    var aboutSection: YouSectionGroup {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"

        return YouSectionGroup(
            title: "About",
            subtitle: "App and local-first status.",
            items: [
                SettingsItem(id: "about-version", title: "Version", subtitle: nil, icon: "number", valueLabel: version),
                SettingsItem(id: "about-build", title: "Build", subtitle: nil, icon: "hammer", valueLabel: build),
                SettingsItem(id: "about-local-first", title: "Local-first core", subtitle: "Core personal life data stays on device by default.", icon: "lock.iphone", valueLabel: "On device"),
                SettingsItem(id: "about-privacy-legal", title: "Privacy & legal", subtitle: "Release privacy and legal approval are not claimed here.", icon: "doc.text", valueLabel: "Pending"),
                SettingsItem(id: "about-diagnostics", title: "Diagnostics export", subtitle: "Diagnostics export is available only where an owning support path proves the action.", icon: "waveform.path.ecg", valueLabel: "Unavailable"),
            ],
            footer: nil
        )
    }

    func durationTitle(for source: DurationSource) -> String {
        switch source {
        case .userSet: "User-set"
        case .userAccepted: "Accepted suggestion"
        case .suggested: "Suggested"
        case .historical: "Historical range"
        case .unset: "Unset"
        case .actual: "Actual"
        }
    }

    func durationSubtitle(for source: DurationSource) -> String {
        switch source {
        case .userSet: "Shown as planned because you set it."
        case .userAccepted: "Shown as planned after you accept it."
        case .suggested: "Always labeled as suggested."
        case .historical: "Always labeled as usually."
        case .unset: "Shown as Duration not set."
        case .actual: "Shown only after completion evidence exists."
        }
    }
}
