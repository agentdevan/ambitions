import AmbitionsDesignSystem
import Foundation
import SwiftUI
import UIKit

// Mutation/accessibility/proof contract: detail sheet actions mutate user preferences through the profile service, return a visible User System Profile update, and announce save state.
struct YouRootDetailSheet: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    let detail: YouRootDetail
    let dashboard: YouDashboard?
    @Binding var appearancePreference: AppAppearancePreference
    @Binding var accentFamily: AmbitionAccentFamily
    @Binding var preferredTab: AppTab
    @Binding var reviewCadenceDays: Int
    let isSaving: Bool
    let hasUnsavedChanges: Bool
    let onSavePreferences: () -> Void
    let onEnableNotifications: () -> Void
    let notificationPermissionState: DegradedStatePresentation?
    let onOpenSystemSettings: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                    if let dashboard {
                        detailContent(for: dashboard)
                    } else {
                        AsyncStateCard(.loading(lines: 6))
                    }
                }
                .padding(.horizontal, theme.spacing.lg)
                .padding(.vertical, theme.spacing.md)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    func detailContent(for profileProjection: YouDashboard) -> some View {
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
            YouControlGroup(eyebrow: "Capture Preferences", section: profileProjection.integrationsSection, accessibilityIdentifier: "you.capture-preferences-control-group")
        case .sourceSettings:
            YouControlGroup(
                eyebrow: "Source Settings",
                section: YouSectionGroup(
                    title: profileProjection.assumptionCorrections.title,
                    subtitle: profileProjection.assumptionCorrections.subtitle,
                    items: profileProjection.assumptionCorrections.items,
                    footer: profileProjection.assumptionCorrections.footer
                ),
                accessibilityIdentifier: "you.source-settings-control-group"
            )
        case .localDataControls, .integrations, .widgets, .exportImport:
            if detail == .localDataControls {
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
                section: YouSectionGroup(
                    title: "Accessibility",
                    subtitle: "Claims stay locked until manual verification is recorded.",
                    items: profileProjection.trustCenter.items.filter { $0.title.localizedCaseInsensitiveContains("Accessibility") },
                    footer: "This is an internal evidence status, not a public accessibility claim."
                ),
                accessibilityIdentifier: "you.accessibility-control-group"
            )
        case .support:
            YouControlGroup(eyebrow: "Help", section: profileProjection.accountSection, accessibilityIdentifier: "you.support-control-group")
        case .about:
            YouControlGroup(eyebrow: "About", section: profileProjection.accountSection, accessibilityIdentifier: "you.about-control-group")
        }
    }

    func vacationAvailabilitySubtitle(for behavior: VacationAvailabilityBehavior) -> String {
        switch behavior {
        case .unavailable: "Ambitions keeps this time out of planning unless you mark part of it open."
        case .protected: "Ambitions preserves the time and stays light."
        case .flexible: "Ambitions may suggest light use after you confirm it."
        case .open: "Ambitions may treat selected time as usable for planning."
        }
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

struct YouPersonalRuntimeStatusControlGroup: View {
    let profileProjection: YouDashboard

    var body: some View {
        YouControlGroup(
            eyebrow: "Personal system",
            section: YouSectionGroup(
                title: "Personal system",
                subtitle: "Inspectable local inputs, controls, and receipts for what Ambitions can use today.",
                items: [
                    SettingsItem(
                        id: "you-personal-on-device",
                        title: "Personal context",
                        subtitle: "Life context, memory controls, and personal settings are available from this profile.",
                        icon: "internaldrive",
                        valueLabel: "On device"
                    ),
                    SettingsItem(
                        id: "you-personal-runtime-controls",
                        title: "Edit, reset, disable, delete, export controls",
                        subtitle: "\(profileProjection.memoryControls.localLearningControls.count) local learning controls and \(profileProjection.personalVault.sections.flatMap(\.rows).count) vault rows expose user-owned control labels without silently mutating data.",
                        icon: "slider.horizontal.3",
                        valueLabel: "user-owned"
                    ),
                    SettingsItem(
                        id: "you-personal-runtime-receipts",
                        title: "Receipt behavior",
                        subtitle: "Review history explains what changed, when it changed, and what stayed protected.",
                        icon: "doc.text.magnifyingglass",
                        valueLabel: profileProjection.receiptAudit.items.isEmpty ? "Pending" : "Example"
                    ),
                    SettingsItem(
                        id: "you-personal-runtime-pending",
                        title: "No hidden automation",
                        subtitle: "Broader learning, deletion, sync, export, and import stay unavailable until their controls are ready.",
                        icon: "hand.raised",
                        valueLabel: "Pending"
                    )
                ],
                footer: "This drill-down is inspection and control posture only. It is not a hosted account, cloud planning layer, marketing audit page, or release/privacy approval claim."
            ),
            accessibilityIdentifier: "you.personal-runtime-status-control-group"
        )
    }
}

struct YouLocalDataControlsControlGroup: View {
    let profileProjection: YouDashboard

    var body: some View {
        YouControlGroup(
            eyebrow: "Privacy",
            section: YouSectionGroup(
                title: "Privacy / Local Data Controls",
                subtitle: "Local-data controls for what Ambitions stores, shows, and can change on this device.",
                items: [
                    SettingsItem(
                        id: "you-local-data-state",
                        title: "Local app state",
                        subtitle: "Display preferences, default landing tab, review cadence, local evidence, captures, and recent event ledger counts come from the current on-device You projection path.",
                        icon: "internaldrive",
                        valueLabel: "On device"
                    ),
                    SettingsItem(
                        id: "you-local-data-vault",
                        title: "Personal vault rows",
                        subtitle: "\(profileProjection.personalVault.sections.flatMap(\.rows).count) local signal and permission rows show source, storage, export, reset, delete, provenance, privacy, and permission labels.",
                        icon: "lock.shield",
                        valueLabel: profileProjection.personalVault.sections.flatMap(\.rows).isEmpty ? "Pending" : "On device"
                    ),
                    SettingsItem(
                        id: "you-local-data-receipts",
                        title: "Policy receipt examples",
                        subtitle: "Examples show how review history will appear when enough local activity exists.",
                        icon: "doc.text.magnifyingglass",
                        valueLabel: "Example"
                    ),
                    SettingsItem(
                        id: "you-local-data-no-account",
                        title: "No hosted account",
                        subtitle: "This build does not introduce a hosted personal-data account, telemetry loop, external planning dependency, or cloud classification requirement.",
                        icon: "person.crop.circle.badge.xmark",
                        valueLabel: "On device"
                    ),
                    SettingsItem(
                        id: "you-local-data-export-sync",
                        title: "Export/import drill pending",
                        subtitle: "Portable export/import, sync continuity, privacy/legal approval, and disaster recovery proof remain future-owned and unclaimed here.",
                        icon: "externaldrive.badge.exclamationmark",
                        valueLabel: "Pending"
                    )
                ],
                footer: "These controls make status inspectable. They do not delete data, claim verified privacy compliance, enable sync, or perform destructive actions from this sheet."
            ),
            accessibilityIdentifier: "you.local-data-controls-control-group"
        )
    }
}
