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
    @Binding var preferredTab: AmbitionsSurface
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
                        YouRootDetailContent(
                            detail: detail,
                            profileProjection: dashboard,
                            appearancePreference: $appearancePreference,
                            accentFamily: $accentFamily,
                            preferredTab: $preferredTab,
                            reviewCadenceDays: $reviewCadenceDays,
                            isSaving: isSaving,
                            hasUnsavedChanges: hasUnsavedChanges,
                            onSavePreferences: onSavePreferences,
                            onEnableNotifications: onEnableNotifications,
                            notificationPermissionState: notificationPermissionState,
                            onOpenSystemSettings: onOpenSystemSettings
                        )
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
                        subtitle: "Display preferences, default starting surface, review cadence, local evidence, captures, and recent event ledger counts come from the current on-device You projection path.",
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
