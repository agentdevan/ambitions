import AmbitionsDesignSystem
import Foundation
import SwiftUI
import UIKit

// Mutation/accessibility/proof contract: preview swatch actions mutate appearance preference state, visibly update the preview stage, and announce the applied setting.
struct YouPreviewSwatchSurface: View {
    let swatch: YouPreviewSwatch
    let appearancePreference: AppAppearancePreference
    let accentFamily: AmbitionAccentFamily

    var body: some View {
        let selectedTheme = appearancePreference.resolveTheme(systemColorScheme: .dark, accentFamily: accentFamily)

        VStack(alignment: .leading, spacing: selectedTheme.spacing.xs) {
            Text(swatch.eyebrow)
                .font(selectedTheme.typography.micro)
                .foregroundStyle(selectedTheme.colors.accentWarm)
            Text(swatch.title)
                .font(selectedTheme.typography.bodyEmphasized)
                .foregroundStyle(selectedTheme.colors.textPrimary)
            Text(swatch.subtitle)
                .font(selectedTheme.typography.caption)
                .foregroundStyle(selectedTheme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            YouObjectPreviewMiniature(kind: swatch.objectKind, previewTheme: selectedTheme)

            TagPill(
                appearancePreference.title,
                icon: "circle.lefthalf.filled",
                state: swatch.state
            )
        }
        .padding(selectedTheme.spacing.sm)
        .frame(maxWidth: .infinity, minHeight: 158, alignment: .topLeading)
        .background(
            AmbitionTokenRoundrect(cornerRadius: selectedTheme.radius.lg)
                .fill(selectedTheme.surfaces.heroGradient)
        )
        .overlay(
            AmbitionTokenRoundrect(cornerRadius: selectedTheme.radius.lg)
                .stroke(selectedTheme.colors.strokeSubtle, lineWidth: 1)
        )
        .ambitionPanelAccessibility(
            label: swatch.accessibilityLabel,
            value: "\(appearancePreference.title) mode, \(accentFamily.title) accent.",
            hint: "Shows how the selected appearance applies to this Ambitions object preview."
        )
    }
}

struct YouObjectPreviewMiniature: View {
    let kind: YouAppearanceObjectPreviewKind
    let previewTheme: AmbitionTheme

    var body: some View {
        switch kind {
        case .startHere:
            VStack(alignment: .leading, spacing: 6) {
                Capsule().fill(previewTheme.colors.accentWarm.opacity(0.9)).frame(width: 52, height: 5)
                AmbitionTokenRoundrect(cornerRadius: previewTheme.radius.sm)
                    .fill(previewTheme.colors.accentPrimary.opacity(0.82))
                    .frame(height: 22)
                HStack(spacing: 5) {
                    Capsule().fill(previewTheme.colors.textSecondary.opacity(0.35)).frame(height: 5)
                    Capsule().fill(previewTheme.colors.textSecondary.opacity(0.22)).frame(width: 36, height: 5)
                }
            }
            .accessibilityHidden(true)

        case .realityRail:
            HStack(alignment: .center, spacing: 8) {
                VStack(spacing: 5) {
                    Circle().fill(previewTheme.colors.accentPrimary).frame(width: 7, height: 7)
                    Rectangle().fill(previewTheme.colors.strokeSubtle).frame(width: 2, height: 20)
                    Circle().fill(previewTheme.colors.accentWarm.opacity(0.85)).frame(width: 7, height: 7)
                    Rectangle().fill(previewTheme.colors.strokeSubtle).frame(width: 2, height: 20)
                    Circle().fill(previewTheme.colors.textTertiary.opacity(0.8)).frame(width: 7, height: 7)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Capsule().fill(previewTheme.colors.accentPrimary.opacity(0.75)).frame(height: 8)
                    Capsule().fill(previewTheme.colors.surfaceOverlay.opacity(0.9)).frame(height: 8)
                    Capsule().fill(previewTheme.colors.surfaceOverlay.opacity(0.65)).frame(height: 8)
                }
            }
            .accessibilityHidden(true)

        case .lifeShape:
            HStack(alignment: .bottom, spacing: 5) {
                Capsule().fill(previewTheme.colors.surfaceOverlay).frame(width: 12, height: 22)
                Capsule().fill(previewTheme.colors.accentPrimary.opacity(0.7)).frame(width: 12, height: 38)
                Capsule().fill(previewTheme.colors.accentWarm.opacity(0.82)).frame(width: 12, height: 28)
                Capsule().fill(previewTheme.colors.surfaceOverlay).frame(width: 12, height: 46)
                Capsule().fill(previewTheme.colors.accentPrimary.opacity(0.45)).frame(width: 12, height: 32)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityHidden(true)

        case .receiptDrawer:
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(previewTheme.typography.micro)
                        .foregroundStyle(previewTheme.colors.accentPrimary)
                    Capsule().fill(previewTheme.colors.textSecondary.opacity(0.35)).frame(height: 6)
                }
                HStack(spacing: 5) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(previewTheme.typography.micro)
                        .foregroundStyle(previewTheme.colors.accentWarm)
                    Capsule().fill(previewTheme.colors.surfaceOverlay.opacity(0.9)).frame(height: 6)
                }
                AmbitionTokenRoundrect(cornerRadius: previewTheme.radius.sm)
                    .fill(previewTheme.colors.strokeSubtle.opacity(0.7))
                    .frame(height: 1)
            }
            .accessibilityHidden(true)
        }
    }
}

struct YouTrustCenterSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let trustCenter: YouTrustCenterState
    let notificationActionTitle: String?
    let onEnableNotifications: () -> Void

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Trust",
                    title: trustCenter.title,
                    subtitle: trustCenter.subtitle
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text(trustCenter.pulse.title)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.accentWarm)
                    Text(trustCenter.pulse.subtitle)
                        .font(theme.typography.titleCompact)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(trustCenter.pulse.detail)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                .padding(theme.spacing.md)
                .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
                .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(trustCenter.items) { item in
                        YouSettingRow(item: item)
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(
                        eyebrow: "Data map",
                        title: "What this surface can explain",
                        subtitle: "A compact inventory of local context, permissions, receipts, and future-owned edges."
                    )

                    ForEach(trustCenter.dataMap) { item in
                        YouTrustDataMapRow(item: item)
                    }
                }
                .accessibilityIdentifier("you.trust-data-map")

                GroupedNavigationList {
                    ForEach(trustCenter.sections) { section in
                        GroupedNavigationSection(title: section.title, footer: section.footer) {
                            ForEach(section.routes) { route in
                                GroupedNavigationRow(
                                    title: route.title,
                                    subtitle: route.subtitle,
                                    systemImage: route.icon,
                                    badge: GroupedNavigationBadge(route.statusLabel, state: route.semanticState),
                                    accessibilityLabel: route.title,
                                    accessibilityValue: route.statusLabel,
                                    accessibilityHint: route.accessibilityHint,
                                    action: {}
                                )
                            }
                        }
                    }
                }

                WhyThisAffordance(
                    summary: "Receipts explain what changed, why it changed, and when review, correction, or undo is available.",
                    evidence: "The surface stays local, inspectable, and explicit about context freshness instead of implying hosted intelligence.",
                    onOpen: {}
                )

                ReceiptDrawer(
                    title: "Receipt drawer",
                    subtitle: "Receipt drawer keeps context freshness, privacy, correction, undo, and review paths visible.",
                    sections: trustReceiptDrawerSections,
                    onReview: { _ in },
                    onUndo: { _ in }
                )

                ProofSpine(
                    title: "Proof trail",
                    subtitle: "Proof stays attached to context freshness, privacy, correction, and review state.",
                    beads: trustProofTrailBeads
                )

                TrustReceiptStack(
                    title: "Recent trust receipts",
                    subtitle: "Privacy-safe summaries of what changed, why, and whether correction or undo is available.",
                    items: trustReceiptStackItems
                )

                if let notificationActionTitle {
                    Button(notificationActionTitle, action: onEnableNotifications)
                        .buttonStyle(AmbitionButtonStyle(tier: .secondary, state: .default))
                        .accessibilityIdentifier("you.enable-notifications-button")
                }

                Text(trustCenter.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("you.trust-center-card")
    }

    var trustReceiptStackItems: [TrustReceiptStackItem] {
        trustCenter.receiptSummaries.map { receipt in
            TrustReceiptStackItem(
                id: receipt.id,
                title: receipt.title,
                summary: receipt.summary,
                sourceLabel: receipt.sourceDomain.trustReceiptSourceLabel,
                freshnessLabel: receipt.safetyState.trustReceiptFreshnessLabel,
                undoLabel: receipt.undoAvailability.trustReceiptUndoLabel,
                correctionLabel: receipt.correctionAvailability.trustReceiptCorrectionLabel,
                nextActionLabel: receipt.nextActionTitle,
                state: receipt.trustReceiptVisualState
            )
        }
    }

    var trustReceiptDrawerSections: [ReceiptDrawerSection] {
        let receipts = trustCenter.receiptSummaries
        guard receipts.isEmpty == false else { return [] }

        return [
            ReceiptDrawerSection(
                id: "recent-receipts",
                title: "Recent receipts",
                subtitle: "What changed, why, and what remains reviewable or reversible.",
                items: receipts.prefix(3).map(\.trustReceiptLayerItem)
            ),
            ReceiptDrawerSection(
                id: "recovery-receipts",
                title: "Recovery and review",
                subtitle: "Local-only, blocked, and confirmation-gated paths stay visible.",
                items: receipts.suffix(max(0, receipts.count - 3)).map(\.trustReceiptLayerItem)
            )
        ]
    }

    var trustProofTrailBeads: [ProofBead] {
        trustCenter.receiptSummaries.prefix(5).map(\.proofTrailBead)
    }
}

struct YouTrustDataMapRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: YouTrustDataMapItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                Text(item.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)

                Spacer(minLength: theme.spacing.sm)

                Text(item.statusLabel)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .padding(.horizontal, theme.spacing.sm)
                    .padding(.vertical, theme.spacing.xxxs)
                    .background(Capsule().fill(theme.colors.surfaceOverlay))
            }

            Text(item.dataTypes)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(item.sourceLabel) · \(item.controlLabel) · \(item.privacyLabel)")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.title)
        .accessibilityValue("\(item.statusLabel). \(item.dataTypes). \(item.sourceLabel). \(item.controlLabel). \(item.privacyLabel).")
    }
}
