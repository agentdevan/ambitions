import AmbitionsDesignSystem
import Foundation
import SwiftUI
import UIKit

struct YouPrivateModeControlRow: View {
    @Environment(\.ambitionTheme) private var theme

    let control: YouPrivateModeControl

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                Text(control.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)

                Spacer(minLength: theme.spacing.sm)

                TagPill(control.statusLabel, state: control.state)
            }

            Text(control.summary)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: theme.spacing.xs) {
                TagPill(control.privacyLabel, icon: "lock.shield", state: .default)
                TagPill(control.controlLabel, icon: "hand.tap", state: control.state)
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(control.title)
        .accessibilityValue("\(control.statusLabel). \(control.privacyLabel). \(control.controlLabel). \(control.summary)")
    }
}

struct YouSourceAtlasKnowledgeSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let sourceAtlasKnowledge: YouSourceAtlasKnowledgeState

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Source Atlas",
                    title: sourceAtlasKnowledge.title,
                    subtitle: sourceAtlasKnowledge.subtitle
                )

                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    ForEach(sourceAtlasKnowledge.sections) { section in
                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                            SectionHeader(title: section.title, subtitle: section.subtitle)

                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                ForEach(section.rows) { row in
                                    YouSourceAtlasKnowledgeRowView(row: row)
                                }
                            }

                            if let footer = section.footer {
                                Text(footer)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textTertiary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }

                Text(sourceAtlasKnowledge.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("you.source-atlas-knowledge-card")
        .ambitionPanelAccessibility(
            label: sourceAtlasKnowledge.title,
            value: "\(sourceAtlasKnowledge.sections.count) source sections",
            hint: "Inspect what Ambitions used for goal knowledge and how to review it."
        )
    }
}

struct YouSourceAtlasKnowledgeRowView: View {
    @Environment(\.ambitionTheme) private var theme

    let row: YouSourceAtlasKnowledgeRow

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: row.icon)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentPrimary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(row.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(row.usedWhat)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(row.whyUsed)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)

                TagPill(row.runtimeUseState.label, state: row.runtimeUseState.visualState)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.spacing.xs) {
                    TagPill(row.sourceName, state: row.state)
                    TagPill(row.sourceStateLabel, state: row.state)
                    TagPill(row.freshnessStateLabel, state: row.state)
                    TagPill(row.riskStateLabel, state: row.state)
                    TagPill(row.reviewNeedLabel, state: row.reviewNeedLabel == "Needs Review" ? .warning : .success)
                }
            }

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text("Correction: \(row.correctionPath)")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Review: \(row.reviewPath)")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
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
}

struct YouMemoryItemRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: YouMemoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentPrimary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.detail)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(item.usedFor)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)
            }

            HStack(spacing: theme.spacing.xs) {
                TagPill(item.freshness.label, state: item.freshness.visualState)
                TagPill(item.sourceLabel, state: .default)
                TagPill(item.privacyLabel, state: .default)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ForEach(item.actions) { action in
                    HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                        TagPill(action.title, state: action.state)
                        Text(action.statusLabel)
                            .font(theme.typography.caption.weight(.semibold))
                            .foregroundStyle(theme.colors.textSecondary)
                        Text(action.detail)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility(
            label: item.accessibilityLabel,
            value: item.accessibilityValue,
            hint: item.accessibilityHint
        )
    }
}

struct YouNarrativeMemoryRow: View {
    @Environment(\.ambitionTheme) private var theme

    let memory: YouNarrativeMemory

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: "text.book.closed")
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentPrimary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(memory.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(memory.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(memory.usedFor)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                TagPill(memory.freshness.label, state: memory.freshness.visualState)
                TagPill(memory.sourceLabel, state: .default)
                TagPill(memory.sensitiveStatusLabel, state: .default)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ForEach(memory.actions) { action in
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        TagPill(action.title, state: action.state)
                        Text(action.statusLabel)
                            .font(theme.typography.caption.weight(.semibold))
                            .foregroundStyle(theme.colors.textSecondary)
                        Text(action.detail)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility(
            label: memory.accessibilityLabel,
            value: memory.accessibilityValue,
            hint: memory.accessibilityHint
        )
    }
}

struct YouMemoryPatternRow: View {
    @Environment(\.ambitionTheme) private var theme

    let pattern: YouMemoryPattern

    var body: some View {
        ObjectStageGlance(state: pattern.state) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack(alignment: .firstTextBaseline) {
                    Text(pattern.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Spacer()
                    TagPill(pattern.reviewLabel, state: pattern.state)
                }
                Text(pattern.summary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(pattern.sourceLabel)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
    }
}

struct YouAutomationBoundarySurface: View {
    @Environment(\.ambitionTheme) private var theme

    let boundary: YouAutomationBoundaryState

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Boundaries",
                    title: boundary.title,
                    subtitle: boundary.subtitle
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(boundary.rules) { rule in
                        YouRuleRow(rule: rule)
                    }
                }

                Text(boundary.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("you.automation-boundary-card")
        .ambitionPanelAccessibility()
    }
}
