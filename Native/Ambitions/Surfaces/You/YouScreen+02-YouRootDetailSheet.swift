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
                            onOpenSystemSettings: onOpenSystemSettings,
                            onOpenDetail: nil
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
            eyebrow: "User System Profile",
            section: YouSectionGroup(
                title: "User System Profile",
                subtitle: "Inspectable local inputs, controls, and receipts for what Ambitions can use today.",
                items: [
                    SettingsItem(
                        id: "you-personal-on-device",
                        title: "Personal context",
                        subtitle: "Life context, memory controls, and personal settings are available from User System Profile.",
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
    @Environment(\.ambitionTheme) private var theme
    @State private var selectedReview: YouPrivacyControlReviewKind

    let profileProjection: YouDashboard
    let onOpenDetail: ((YouRootDetail) -> Void)?

    init(profileProjection: YouDashboard, onOpenDetail: ((YouRootDetail) -> Void)?) {
        self.profileProjection = profileProjection
        self.onOpenDetail = onOpenDetail
        _selectedReview = State(initialValue: YouPrivacyControlReviewKind.screenshotInitialSelection())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            reviewSurface

            YouControlGroup(
                eyebrow: "Privacy",
                section: YouSectionGroup(
                    title: "Privacy / Local Data Controls",
                    subtitle: "Local-data controls for what Ambitions stores, shows, and can change on this device.",
                    items: statusItems,
                    footer: "These controls make status inspectable. They do not delete data, claim verified privacy compliance, enable sync, or perform destructive actions from this sheet."
                ),
                accessibilityIdentifier: "you.local-data-controls-control-group"
            )
        }
        .accessibilityIdentifier("you.local-data-control-center")
    }

    var statusItems: [SettingsItem] {
        [
            SettingsItem(
                id: "you-local-data-state",
                title: "Local app state",
                subtitle: "Preferences, captures, proof, receipts, local evidence, and recent event counts come from the current on-device You projection path.",
                icon: "internaldrive",
                valueLabel: "On device"
            ),
            SettingsItem(
                id: "you-local-data-vault",
                title: "Personal vault rows",
                subtitle: "\(personalVaultRowCount) local signal and permission rows show storage, export, reset, delete, provenance, privacy, and permission labels.",
                icon: "lock.shield",
                valueLabel: personalVaultRowCount == 0 ? "Pending" : "On device"
            ),
            SettingsItem(
                id: "you-local-data-receipts",
                title: "Receipt examples",
                subtitle: receiptExampleCount == 0 ? "No local receipt examples are loaded yet." : "\(receiptExampleCount) receipt example\(receiptExampleCount == 1 ? "" : "s") can explain future control outcomes.",
                icon: "doc.text.magnifyingglass",
                valueLabel: receiptExampleCount == 0 ? "Pending" : "Example"
            ),
            SettingsItem(
                id: "you-local-data-no-account",
                title: "No hosted account",
                subtitle: "This build does not require a hosted personal-data account, telemetry loop, external planning dependency, or cloud classification requirement.",
                icon: "person.crop.circle.badge.xmark",
                valueLabel: "On device"
            ),
            SettingsItem(
                id: "you-local-data-export-sync",
                title: "Export/import drill",
                subtitle: "Portable export/import, sync continuity, privacy/legal approval, and disaster recovery proof remain future-owned and unclaimed here.",
                icon: "externaldrive.badge.exclamationmark",
                valueLabel: "Review"
            )
        ]
    }

    var reviewSurface: some View {
        let review = selectedReview.review(
            personalVaultRowCount: personalVaultRowCount,
            learningControlCount: learningControlCount,
            receiptExampleCount: receiptExampleCount
        )

        return VStack(alignment: .leading, spacing: theme.spacing.md) {
            SectionHeader(
                eyebrow: "Controls",
                title: "Review before anything changes",
                subtitle: "Every privacy control shows scope, boundary, receipt expectation, and whether it can act in this build."
            )

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 148), spacing: theme.spacing.xs, alignment: .leading)],
                alignment: .leading,
                spacing: theme.spacing.xs
            ) {
                ForEach(YouPrivacyControlReviewKind.allCases) { kind in
                    YouPrivacyControlReviewButton(
                        review: kind.review(
                            personalVaultRowCount: personalVaultRowCount,
                            learningControlCount: learningControlCount,
                            receiptExampleCount: receiptExampleCount
                        ),
                        isSelected: selectedReview == kind
                    ) {
                        selectedReview = kind
                    }
                }
            }

            YouPrivacyControlReviewPanel(
                review: review,
                onOpenDetail: review.targetDetail.map { target in
                    {
                        if let onOpenDetail {
                            onOpenDetail(target)
                        }
                    }
                }
            )
        }
        .padding(.vertical, theme.spacing.sm)
        .padding(.leading, theme.spacing.sm)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(LivingTabContext.you.accent(in: theme).opacity(0.42))
                .frame(width: 2)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(0.72))
                .frame(height: 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(0.42))
                .frame(height: 1)
        }
        .accessibilityIdentifier("you.privacy-control-review-surface")
        .ambitionPanelAccessibility(
            label: "Local data control review",
            value: review.accessibilityValue,
            hint: "Choose a local privacy control to inspect its scope and boundary."
        )
    }

    var personalVaultRowCount: Int {
        profileProjection.personalVault.sections.flatMap(\.rows).count
    }

    var learningControlCount: Int {
        profileProjection.memoryControls.localLearningControls.count
    }

    var receiptExampleCount: Int {
        profileProjection.receiptAudit.items.count
    }
}

private enum YouPrivacyControlReviewKind: String, CaseIterable, Identifiable {
    case export
    case reset
    case delete
    case account
    case privacy
    case sources
    case history

    var id: String { rawValue }

    static func screenshotInitialSelection(
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> YouPrivacyControlReviewKind {
        guard environment["AmbitionsScreenshotMode"] == "YES",
              let rawValue = environment["AmbitionsYouPrivacyControlReview"],
              let review = YouPrivacyControlReviewKind(rawValue: rawValue)
        else {
            return .export
        }

        return review
    }

    func review(
        personalVaultRowCount: Int,
        learningControlCount: Int,
        receiptExampleCount: Int
    ) -> YouPrivacyControlReview {
        switch self {
        case .export:
            YouPrivacyControlReview(
                kind: self,
                title: "Export summary",
                summary: "Prepare a local review of \(personalVaultRowCount) vault row\(personalVaultRowCount == 1 ? "" : "s") before any file leaves this iPhone.",
                boundary: "Includes counts, labels, source categories, and privacy boundaries. Excludes raw private text, account tokens, R2 requests, and hidden profiles.",
                receipt: "A future export must create a local export-prepared receipt before sharing. This panel does not create a file.",
                statusLabel: "Review only",
                icon: "square.and.arrow.up",
                state: .success,
                handoffTitle: nil,
                targetDetail: nil,
                accessibilityValue: "Export review only. No file is created."
            )
        case .reset:
            YouPrivacyControlReview(
                kind: self,
                title: "Reset learned corrections",
                summary: "\(learningControlCount) local learning control\(learningControlCount == 1 ? "" : "s") can explain what reset would affect before any reuse changes.",
                boundary: "Reset applies to source-tied learning and correction reuse. It does not erase goals, captures, proof, receipts, or raw event history.",
                receipt: "A future reset must require confirmation and record what learning reuse changed.",
                statusLabel: "Confirm first",
                icon: "arrow.counterclockwise.circle",
                state: .warning,
                handoffTitle: nil,
                targetDetail: nil,
                accessibilityValue: "Reset requires confirmation. No data changed."
            )
        case .delete:
            YouPrivacyControlReview(
                kind: self,
                title: "Delete local data",
                summary: "Broad local deletion is intentionally blocked until the owning flow proves backup, confirmation, receipt, and recovery boundaries.",
                boundary: "This panel cannot erase goals, captures, proof, receipts, local context, or preferences.",
                receipt: "A destructive delete flow must create a confirmation receipt and a recovery record before it becomes available.",
                statusLabel: "Unavailable",
                icon: "trash.slash",
                state: .warning,
                handoffTitle: nil,
                targetDetail: nil,
                accessibilityValue: "Delete unavailable. No destructive action exists here."
            )
        case .account:
            YouPrivacyControlReview(
                kind: self,
                title: "Account optionality",
                summary: "No account is required for the core local app. Optional account and sync capabilities remain unconnected here.",
                boundary: "No hosted personal-data account, private graph backend, or cloud classification path is introduced by this control.",
                receipt: "Future account changes must show what stayed local and what capability changed.",
                statusLabel: "No account",
                icon: "person.crop.circle.badge.xmark",
                state: .success,
                handoffTitle: "Open About",
                targetDetail: .about,
                accessibilityValue: "No account required. About detail available."
            )
        case .privacy:
            YouPrivacyControlReview(
                kind: self,
                title: "Privacy boundary",
                summary: "Privacy explains what is local, what needs permission, and what remains unclaimed by release proof.",
                boundary: "Private life graph data is not sent to R2, Source Atlas, hosted AI, or a personal backend from this panel.",
                receipt: "Privacy receipts stay inspectable in the Trust Center and Receipts & History.",
                statusLabel: "Inspect",
                icon: "hand.raised",
                state: .success,
                handoffTitle: "Open Privacy",
                targetDetail: .trustCenter,
                accessibilityValue: "Privacy boundary inspectable."
            )
        case .sources:
            YouPrivacyControlReview(
                kind: self,
                title: "Source settings",
                summary: "Sources separate public reference context from private life data before any planning explanation can reuse it.",
                boundary: "Source Atlas remains public-reference/freshness infrastructure and not private intelligence storage.",
                receipt: "Source detail shows freshness, review state, and whether a reference was used.",
                statusLabel: "Public refs",
                icon: "checkmark.shield",
                state: .success,
                handoffTitle: "Open Sources",
                targetDetail: .sourceSettings,
                accessibilityValue: "Sources inspect public reference boundaries."
            )
        case .history:
            YouPrivacyControlReview(
                kind: self,
                title: "Receipts & History",
                summary: receiptExampleCount == 0 ? "History is available for inspection even when this fixture has no receipt examples yet." : "\(receiptExampleCount) receipt example\(receiptExampleCount == 1 ? "" : "s") can show what changed and what remained private.",
                boundary: "History shows summaries first and keeps sensitive detail behind contextual inspection.",
                receipt: "Control changes must leave a local receipt before stronger claims are made.",
                statusLabel: "Local",
                icon: "doc.text.magnifyingglass",
                state: .success,
                handoffTitle: "Open History",
                targetDetail: .receiptsHistory,
                accessibilityValue: "Receipts and History are local and inspectable."
            )
        }
    }
}

private struct YouPrivacyControlReview: Identifiable {
    let kind: YouPrivacyControlReviewKind
    let title: String
    let summary: String
    let boundary: String
    let receipt: String
    let statusLabel: String
    let icon: String
    let state: AmbitionVisualState
    let handoffTitle: String?
    let targetDetail: YouRootDetail?
    let accessibilityValue: String

    var id: String { kind.rawValue }
}

private struct YouPrivacyControlReviewButton: View {
    @Environment(\.ambitionTheme) private var theme

    let review: YouPrivacyControlReview
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: theme.spacing.xs) {
                Image(systemName: review.icon)
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.stateStyle(for: isSelected ? .selected : review.state).accent)
                    .frame(width: 20)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(review.title)
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(review.statusLabel)
                        .font(theme.typography.micro.weight(.semibold))
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xs)
            .frame(minHeight: 48, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .fill(theme.stateStyle(for: isSelected ? .selected : .default).fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .stroke(theme.stateStyle(for: isSelected ? .selected : .default).stroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("you.privacy-control.\(review.id)-button")
        .accessibilityLabel(review.title)
        .accessibilityValue(review.accessibilityValue)
        .accessibilityHint("Selects this local data control for review.")
    }
}

private struct YouPrivacyControlReviewPanel: View {
    @Environment(\.ambitionTheme) private var theme

    let review: YouPrivacyControlReview
    let onOpenDetail: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: review.icon)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.stateStyle(for: review.state).accent)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(review.title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(review.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)
                TagPill(review.statusLabel, state: review.state)
            }

            Divider().overlay(theme.colors.strokeSubtle)

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                reviewLine(title: "Boundary", text: review.boundary, icon: "lock.shield")
                reviewLine(title: "Receipt", text: review.receipt, icon: "doc.text.magnifyingglass")
            }

            if let handoffTitle = review.handoffTitle, let onOpenDetail {
                Button(action: onOpenDetail) {
                    Text(handoffTitle)
                        .frame(maxWidth: .infinity)
                }
                    .buttonStyle(AmbitionButtonStyle(tier: .secondary, state: .default))
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(handoffTitle)
                    .accessibilityIdentifier("you.privacy-control.\(review.id).handoff-button")
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .accessibilityIdentifier("you.privacy-control.review.\(review.id)")
        .ambitionPanelAccessibility(
            label: review.title,
            value: "\(review.statusLabel). \(review.boundary). \(review.receipt)",
            hint: "Selected local data control review. No destructive action happens from this panel."
        )
    }

    func reviewLine(title: String, text: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.accentWarm)
                .frame(width: 20)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Text(text)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
