import AmbitionsDesignSystem
import Foundation
import SwiftUI
import UIKit

struct YouContextVaultSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let contextVault: YouContextVaultState

    var body: some View {
        ProductObjectFrame {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Optional context",
                    title: contextVault.title,
                    subtitle: contextVault.subtitle
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(contextVault.items) { item in
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            Image(systemName: item.icon)
                                .foregroundStyle(theme.colors.accentPrimary)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                Text(item.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(item.subtitle)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                Text(item.detail)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textTertiary)
                            }
                            Spacer()
                        }
                        .padding(theme.spacing.sm)
                        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(
                        title: "Signal policy",
                        subtitle: "Keep optional context understandable before later compliance work deepens the control layer."
                    )

                    ForEach(contextVault.policyItems) { item in
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            TagPill(item.title, state: item.state)
                            Text(item.detail)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                    }
                }

                Text(contextVault.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("you.context-vault-card")
    }
}

struct YouPersonalVaultSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let personalVault: YouPersonalVaultState

    var body: some View {
        ProductObjectFrame {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Privacy",
                    title: personalVault.title,
                    subtitle: personalVault.subtitle
                )

                ForEach(personalVault.sections) { section in
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: section.id.localizedCaseInsensitiveContains("permission") ? "Permissions Center" : "Sensitive Local Signals",
                            title: section.title,
                            subtitle: section.subtitle
                        )

                        ForEach(section.rows) { row in
                            YouPersonalVaultRowView(row: row)
                        }
                    }
                }

                Text(personalVault.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("you.personal-vault-card")
        .ambitionPanelAccessibility(
            label: personalVault.title,
            value: "\(personalVault.sections.count) sections, \(personalVault.sections.flatMap(\.rows).count) rows, \(personalVault.sections.flatMap(\.rows).filter { $0.kind == .permission }.count) permission rows.",
            hint: "Review the local signal rows, permission labels, and export/reset/delete boundaries."
        )
    }
}

struct YouPersonalVaultRowView: View {
    @Environment(\.ambitionTheme) private var theme

    let row: YouPersonalVaultRow

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: iconName)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentPrimary)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(row.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(row.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)
                TagPill(row.kind.label, state: row.state)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.spacing.xs) {
                    TagPill(row.sourceLabel, icon: "doc.text.magnifyingglass", state: .default)
                    TagPill(row.storageLabel, icon: "internaldrive", state: row.state)
                    TagPill(row.exportLabel, icon: "square.and.arrow.up", state: row.state)
                    TagPill(row.resetLabel, icon: "arrow.counterclockwise", state: .default)
                    TagPill(row.deleteLabel, icon: "trash.slash", state: .warning)
                    TagPill(row.provenanceLabel, icon: "text.badge.checkmark", state: .default)
                    TagPill(row.privacyPolicyLabel, icon: "hand.raised", state: .default)
                    TagPill(row.permissionLabel, icon: "lock.shield", state: row.state)
                }
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility(
            label: row.accessibilityLabel,
            value: row.accessibilityValue,
            hint: row.accessibilityHint
        )
    }

    var iconName: String {
        switch row.kind {
        case .signal:
            return "brain.head.profile"
        case .permission:
            return "lock.shield"
        }
    }
}

struct YouControlGroup: View {
    @Environment(\.ambitionTheme) private var theme

    let eyebrow: String
    let section: YouSectionGroup
    let accessibilityIdentifier: String

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            SectionHeader(eyebrow: eyebrow, title: section.title, subtitle: section.subtitle)

            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                ForEach(section.items) { item in
                    YouSettingRow(item: item)
                }
            }

            if let footer = section.footer {
                Text(footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
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
        .accessibilityIdentifier(accessibilityIdentifier)
        .ambitionPanelAccessibility(
            label: section.title,
            value: "\(section.items.count) controls",
            hint: "Review this You control group."
        )
    }
}
